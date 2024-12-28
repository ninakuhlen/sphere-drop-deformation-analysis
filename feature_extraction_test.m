addpath('src\image_processing\');
addpath('src\visualization\');

videoFile = VideoFile("30_deg_view_B.avi");
videoFile.setROI(200, "width", "symmetrical"); % 200
videoFile.setROI(-100, "height", "from center");
disp(videoFile);

pre = ImageProcessor();
disp(pre);

reconstructor = GeometryReconstructor(videoFile, 50, 62, {"coveredDistance", 320, "translationVelocity", 3.2});
[nPixels, error] = reconstructor.calculateStretchFactor(reconstructor.voxelDimensions);
disp(reconstructor);

figure;
% Frames einzeln auslesen und anzeigen
index = 0;

frameStack = zeros(videoFile.resolution(1), videoFile.resolution(2), videoFile.nFrames);


while true
    try
        frame = videoFile.getFrame();
    catch ME
        break;
    end

    frameStruct = pre.asImageStruct(frame);
    frameStruct = pre.asGrayscale(frameStruct);
    frameStruct = pre.meanFilter(frameStruct, 0, "<=");

    % stretch filtered values to range 0 to 255 again
    frameStruct = pre.asGrayscale(frameStruct);

    % set zero values to nan
    frameStruct = pre.threshold(frameStruct, 0, "==");

    % [largestSlope, binIndex] = findLargestHistogramSlopeWithEnvelope(frame, 256);
    %frame(frame > 252) = NaN;


    % mask = compareFrames(frame, previousFrame, 50);
    % filteredFrame = double(frame) .* double(mask);

    % frame = imadjust(frame, [], [], 0.45);
    % frame = imadjust(frame, [], [], 2);


    frameStack(:,:,end-index) = frameStruct.image;
    index = index + 1;

    % show filtered frame
    imshow(frameStruct.image);
    pause(1 / videoFile.frameRate);
end

modeA = "sum";
modeB = "median";
axis = "depth";
projectionDepthA = pre.projectFrames(frameStack, modeA, axis);
projectionDepthB = pre.projectFrames(frameStack, modeB, axis);

projectionDepthA = pre.asGrayscale(projectionDepthA);
projectionDepthB = pre.asGrayscale(projectionDepthB);

axis = "height";
projectionHeightA = pre.projectFrames(frameStack, modeA, axis);
projectionHeightB = pre.projectFrames(frameStack, modeB, axis);

projectionHeightA = pre.asGrayscale(projectionHeightA);
projectionHeightB = pre.asGrayscale(projectionHeightB);

axis = "width";
projectionWidthA = pre.projectFrames(frameStack, modeA, axis);
projectionWidthB = pre.projectFrames(frameStack, modeB, axis);


% q = quantile(projectionHeightB.image, [0.05 0.25 0.5 0.75 0.95], "all")
% [largestSlope, binIndex] = findLargestHistogramSlopeWithEnvelope(projectionHeightB.image, 256);
% t1 = imbinarize(projectionHeightB.image);

% t2 = imbinarize(projectionHeightB.image, q(5)/255);
% t1 = pre.asImageStruct(t1);
% t2 = pre.asImageStruct(t2);
% multiPlot(t1, t2);
% 
% projectionHeightA.image = meanFilter(projectionHeightA.image, -1);

multiPlot(projectionDepthA, projectionDepthB, projectionHeightA, projectionHeightB, projectionWidthA, projectionWidthB);

stretchedProjection = pre.stretchImage(projectionHeightA, "height", nPixels);

[roiImage, ~] = pre.selectROI(stretchedProjection);
roiImage = pre.asGrayscale(roiImage);
max(roiImage.image, [], "all")
min(roiImage.image, [], "all")
[largestSlope, binIndex] = findLargestHistogramSlopeWithEnvelope(roiImage.image, 256);

binarizedImage = imbinarize(roiImage.image);

kernelSize = 9;
iterations = 5;
filterKernel = strel("square", kernelSize);
for i = 0:iterations
    name = "Opening Iteration: " + num2str(i);
    figure("Name", name);
    imshow(binarizedImage);
    binarizedImage = imerode(binarizedImage, filterKernel);
end

pause;

close all;
clc;


function binaryMask = compareFrames(frame1, frame2, threshold)
% Vergleicht zwei Frames und erstellt eine binäre Maske basierend auf einem Schwellenwert.
%
% Eingabe:
%   frame1     - Der erste Frame (z. B. ein Graustufenbild)
%   frame2     - Der zweite Frame (z. B. ein Graustufenbild)
%   threshold  - Der Schwellenwert für die Abweichung (z. B. ein Wert zwischen 0 und 255)
%
% Ausgabe:
%   binaryMask - Eine binäre Maske, in der Pixel mit Abweichung > threshold mit 1 markiert sind.

% Überprüfen, ob die Frames die gleiche Größe haben
if ~isequal(size(frame1), size(frame2))
    error('Die beiden Frames müssen die gleiche Größe haben.');
end

% Berechne die absolute Differenz zwischen den beiden Frames
pixelDifference = abs(double(frame1) - double(frame2));

% Erstelle die binäre Maske basierend auf dem Schwellenwert
binaryMask = pixelDifference > threshold;
end



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






function [largestSlope, binIndex] = findLargestHistogramSlopeLog(inputImage, nBins)
% Berechne das Histogramm des Bildes
[counts, binEdges] = imhist(inputImage, nBins);

% Frequenzen logarithmisch skalieren, um relative Unterschiede zu betonen
logCounts = counts; %log10(counts + 1); % +1, um log(0) zu vermeiden

% Berechne die Mittelpunkte der Bins
binCenters = binEdges(1:end-1); % Eine weniger als logCounts

% Berechne die Differenzen zwischen den logarithmischen Werten
slopes = diff(logCounts);

% Finde den Index des größten Gefälles
[largestSlope, binIndex] = min(slopes);

% Visualisierung (optional)
bar(binCenters, logCounts(1:end-1), 'FaceColor', [0.5, 0.5, 0.8]); % Gleiche Länge sicherstellen
hold on;
plot(binCenters(binIndex:binIndex+1), logCounts(binIndex:binIndex+1), 'r', 'LineWidth', 2);
title('Logarithmisch skaliertes Histogramm mit größtem Gefälle');
xlabel('Grauwert');
ylabel('Logarithmische Häufigkeit (log_{10})');
legend('Histogramm', 'Größtes Gefälle');
hold off;
end


function [largestSlope, binIndex] = findLargestHistogramSlopeWithEnvelope(inputImage, nBins)
% Berechne das Histogramm des Bildes
[counts, binCenters] = imhist(inputImage, nBins);

[t, em] = otsuthresh(counts);
t * 255

% Frequenzen logarithmisch skalieren
logCounts = log10(counts + 1); % +1, um log(0) zu vermeiden

% Sicherstellen, dass die Länge von binCenters und logCounts übereinstimmt
if length(binCenters) ~= length(logCounts)
    error('Die Länge von binCenters und logCounts stimmt nicht überein.');
end

% Passe eine Einhüllende an die logarithmierten Werte an (Savitzky-Golay-Filter)
smoothedCounts = sgolayfilt(logCounts, 3, 11); % Grad 3, Fenstergröße 11

[globalMinValue, globalMinIndex] = min(smoothedCounts)

% Berechne die Differenzen der geglätteten Werte
slopes = diff(smoothedCounts);

% Finde den Index des größten Gefälles
[largestSlope, binIndex] = min(slopes);

% Visualisierung
% figure;
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


