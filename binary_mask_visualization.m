clear all;
clc;

addpath('src\image_processing\');
addpath('src\visualization\');

showVideo = false;

videoFile = VideoFile("30_deg_view_A.avi");
videoFile.setROI(200, "width", "symmetrical"); % 200
videoFile.setROI(-100, "height", "from center");
% disp(videoFile);

pre = ImageProcessor();
% disp(pre);

reconstructor = GeometryReconstructor(videoFile, 50, 62, {"coveredDistance", 320, "translationVelocity", 3.2});
[nPixels, error] = reconstructor.calculateStretchFactor(reconstructor.voxelDimensions);
disp(reconstructor);

if showVideo
    videoWindow = figure("Name", "Video");
end

frameStack = videoFile.createFrameContainer(1);

%% Recording

while true
    try
        frame = videoFile.getFrame();
    catch ME
        break;
    end

    frameStruct = pre.asImageStruct(frame);
    frameStruct = pre.asGrayscale(frameStruct);

    % gamma correction: brighten (g < 1), darken (g > 1)
    % frameStruct.image = imadjust(frameStruct.image, [], [], 0.75);
    frameStruct.image = medfilt2(frameStruct.image, [15 15], "symmetric");
    
    % mean filtering
    frameStruct = pre.meanFilter(frameStruct, 0, "<=");

    % stretch filtered values to range 0 to 255 again
    frameStruct = pre.asGrayscale(frameStruct);

    % set zero values to nan
    frameStruct = pre.threshold(frameStruct, 0, "==");

    frameStack(:,:,end - videoFile.frameIndex + 1) = frameStruct.image;
    
    if showVideo
        % show filtered frame
        imshow(frameStruct.image);
        set(videoWindow, "Name", "Frame " + num2str(videoFile.frameIndex) + "/" + num2str(videoFile.nFrames));
        pause(1 / videoFile.frameRate);
    end
end

%% Projection

modeA = "sum";
modeB = "min";
axis = "height";
projectionA = pre.projectFrames(frameStack, modeA, axis);
projectionB = pre.projectFrames(frameStack, modeB, axis);

projectionA = pre.asGrayscale(projectionA);
projectionB = pre.asGrayscale(projectionB);

multiPlot(projectionA, projectionB);

stretchedProjection = pre.stretchImage(projectionA, "height", nPixels);

findLargestHistogramSlopeWithEnvelope(stretchedProjection.image, 256);

% mask = uint8(imbinarize(stretchedProjection.image, 182/255) * 255);
mask = uint8(imbinarize(stretchedProjection.image) * 255);

figure("Name", "Binary Mask", "NumberTitle","off");
imshow(mask);

pause;
close all;

function multiPlot(varargin)

% number of images
nImages = nargin;
nRows = floor(sqrt(nImages));
nColumns = ceil(nImages / nRows);

% create figure and display images
figure("Name", "Images", "NumberTitle", "off");

for i = 1:nImages
    subplot(nRows, nColumns, i);
    imshow(varargin{i}.image);
    title(varargin{i}.title);
    xlabel(varargin{i}.xLabel);
    ylabel(varargin{i}.yLabel);
end
end


function [largestSlope, binIndex] = findLargestHistogramSlopeWithEnvelope(inputImage, nBins)
% Berechne das Histogramm des Bildes
[counts, binCenters] = imhist(inputImage, nBins);

[t, ~] = otsuthresh(counts);

% Frequenzen logarithmisch skalieren
logCounts = log10(counts + 1); % +1, um log(0) zu vermeiden

% Sicherstellen, dass die Länge von binCenters und logCounts übereinstimmt
if length(binCenters) ~= length(logCounts)
    error('Die Länge von binCenters und logCounts stimmt nicht überein.');
end

% Passe eine Einhüllende an die logarithmierten Werte an (Savitzky-Golay-Filter)
smoothedCounts = sgolayfilt(logCounts, 3, 11); % Grad 3, Fenstergröße 11

% [globalMinValue, globalMinIndex] = min(smoothedCounts);

% Berechne die Differenzen der geglätteten Werte
slopes = diff(smoothedCounts);

% Finde den Index des größten Gefälles
[largestSlope, binIndex] = min(slopes);

% Visualisierung
figure("Name", "Log Histogram, Otsu recognized: " + num2str(t * 255));
bar(binCenters, logCounts, 'FaceColor', [0.5, 0.5, 0.8]); % Original-Histogramm
hold on;
plot(binCenters, smoothedCounts, 'r', 'LineWidth', 2); % Einhüllende
if binIndex < length(binCenters)
    plot(binCenters(binIndex:binIndex+1), smoothedCounts(binIndex:binIndex+1), 'g', 'LineWidth', 2); % Größtes Gefälle
end
title('Logarithmisch skaliertes Histogramm mit Einhüllender');
xlabel('Grauwert');
ylabel('Logarithmische Häufigkeit (log_{10})');
legend('Histogramm', 'Einhüllende', 'Größtes Gefälle');
hold off;
end