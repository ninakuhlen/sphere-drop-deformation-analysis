clear all;
clc;

addpath('src\image_processing\');
addpath('src\visualization\');


showVideo = false;

videoFile = VideoFile("30_deg_view_A.avi");
videoFile.setROI(200, "width", "symmetrical"); % 200

videoFile.setROI(-100, "height", "from center");
disp(videoFile);

pre = ImageProcessor();
disp(pre);

reconstructor = GeometryReconstructor(videoFile, 50, 62, {"coveredDistance", 300, "translationVelocity", 3.2});
[nPixels, error] = reconstructor.calculateStretchFactor(reconstructor.voxelDimensions);
disp(reconstructor);

if showVideo
    videoWindow = figure("Name", "Video");
end

frameStack = videoFile.createFrameContainer(1);

while true
    try
        frame = videoFile.getFrame();
    catch ME
        break;
    end

    frameStruct = pre.asImageStruct(frame);
    frameStruct = pre.asGrayscale(frameStruct);

    % gamma correction: brighten (g < 1), darken (g > 1)
    frameStruct.image = imadjust(frameStruct.image, [], [], 0.5);
    frameStruct.image = medfilt2(frameStruct.image, [15 15], "symmetric");
    
    % mean filtering
    frameStruct = pre.meanFilter(frameStruct, 0, "<=");

    % stretch filtered values to range 0 to 255 again
    % frameStruct = pre.asGrayscale(frameStruct);

    % set zero values to nan
    % frameStruct = pre.threshold(frameStruct, 0, "==");

    frameStack(:,:,end - videoFile.frameIndex + 1) = frameStruct.image;
    
    if showVideo
        % show filtered frame
        imshow(frameStruct.image);
        set(videoWindow, "Name", "Frame " + num2str(videoFile.frameIndex) + "/" + num2str(videoFile.nFrames));
        pause(1 / videoFile.frameRate);
    end
end


modeA = "sum";
modeB = "min";
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

% stretchedProjection.image = medfilt2(stretchedProjection.image, [45, 25], "symmetric");
[roiImage, ~] = pre.selectROI(stretchedProjection);
roiImage = pre.asGrayscale(roiImage);

[largestSlope, binIndex] = findLargestHistogramSlopeWithEnvelope(roiImage.image, 256);

roiImage.image = medfilt2(roiImage.image, [3, 3], "symmetric")
binarizedImage = imbinarize(roiImage.image);

% colorImage = pre.asColor(pre.asImageStruct(binarizedImage));
% colorImage

%% morphedImage = multistepOpening(binarizedImage, 31);

% Überprüfen, ob das Eingabebild binarisiert ist.
if ~islogical(binarizedImage)
    error('Das Eingabebild muss binarisiert (logisch) sein.');
end

kernelShape = "disk";
kernelSize = 15;
morphFigure = figure;

morphedImage = pre.multiStepMorphing(binarizedImage, kernelShape, kernelSize, "shrink", "erode", morphFigure, binarizedImage);
[~] = pre.multiStepMorphing(morphedImage, kernelShape, kernelSize, "grow", "dilate", morphFigure, binarizedImage);


% initial dilation
% filterKernel = strel(kernelShape, kernelSize);
% morphedImage = imdilate(binarizedImage, filterKernel);




%drawMinBoundCircle(morphedImage);
pause;

close all;
clear all;
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


function fitBlob(binaryImage, kernelSize)


end



function morphedImage = multistepOpening(binarizedImage, initialKernelSize)

% Überprüfen, ob das Eingabebild binarisiert ist.
if ~islogical(binarizedImage)
    error('Das Eingabebild muss binarisiert (logisch) sein.');
end

kernelShape = "disk";

% Originalbild als Hintergrund
originalImage = repmat(binarizedImage, [1, 1, 3]);

% Kernel-Größe und Iteration initialisieren
kernelSize = 3;
iteration = 1;

% initial dilation
filterKernel = strel(kernelShape, kernelSize);
morphedImage = imdilate(binarizedImage, filterKernel);

figure("Name", "Multistep Opening");

% Schleife, bis die Kernel-Größe kleiner als 3 ist
while kernelSize <= initialKernelSize
    % Morphologische Operationen: Erosion
    filterKernel = strel(kernelShape, kernelSize);
    morphedImage = imclose(morphedImage, filterKernel);

    % Ergebnis als farbliche Hervorhebung im Bild
    overlayImage = uint8(originalImage); % Verwende das Originalbild als Basis
    overlayImage(:,:,1) = uint8(morphedImage* 255); % Rot für Erosion

    % Alpha-Blending mit dem Originalbild
    finalImage = uint8((double(originalImage) * 255 + double(overlayImage)) / 2); % Alpha-Blending

    % Ausgabe des Bildes
    imshow(finalImage);
    title("Erosion - Iteration " + num2str(iteration) + " mit Kernel-Größe " + num2str(kernelSize));

    % Iteration und Kernel-Größe anpassen
    iteration = iteration + 1;
    kernelSize = kernelSize + 2;
    pause(0.25);
end

% Zurücksetzen der Kernel-Größe für Dilatation
kernelSize = 3;
iteration = 1;

while kernelSize <= initialKernelSize
    % Morphologische Operationen: Dilatation
    filterKernel = strel(kernelShape, kernelSize);
    morphedImage = imopen(morphedImage, filterKernel);

    % Ergebnis als farbliche Hervorhebung im Bild
    overlayImage = uint8(originalImage); % Verwende das Originalbild als Basis
    overlayImage(:,:,2) = uint8(morphedImage* 255) ; % Grün für Dilatation

    % Alpha-Blending mit dem Originalbild
    finalImage = uint8((double(originalImage)* 255 + double(overlayImage)) / 2); % Alpha-Blending

    % Ausgabe des Bildes
    imshow(finalImage);
    title("Dilatation - Iteration " + num2str(iteration) + " mit Kernel-Größe " + num2str(kernelSize));

    % Iteration und Kernel-Größe anpassen
    iteration = iteration + 1;
    kernelSize = kernelSize + 2;
    pause(0.25);
end
end

function radius = fitCircleToBinaryImage(binaryImage)
    % Überprüfe ob das Eingabeformat binär ist
    if ~islogical(binaryImage)
        error('Das Eingabebild muss ein binäres (logisches) Bild sein.');
    end

    % Hough-Transformation durchführen, um Kreise zu erkennen
    [centers, radii] = imfindcircles(uint8(binaryImage*255), [10 100], 'Sensitivity', 0.9);

    % Überprüfen, ob Kreise erkannt wurden
    if isempty(centers)
        error('Keine Kreise im Bild erkannt.');
    end
    
    % Wähle den Kreis mit dem größten Radius
    [radius, idx] = max(radii);
    center = centers(idx, :);

    % Originalbild in RGB umwandeln zum Zeichnen
    rgbImage = cat(3, binaryImage, binaryImage, binaryImage);

    % In rot den erkannten Kreis zeichnen
    rgbImage = insertShape(rgbImage, 'circle', [center, radius], 'Color', 'red', 'LineWidth', 3);
    % In grün den Mittelpunkt markieren
    rgbImage = insertMarker(rgbImage, center, 'o', 'Color', 'green', 'Size', 10);

    % Ergebnis anzeigen
    figure;
    imshow(rgbImage);
    title(['Angepasster Kreis mit Radius: ', num2str(radius)]);
end

function drawMinBoundCircle(binaryImage)
    % Überprüfen, ob das Bild binär ist
    if ~islogical(binaryImage)
        error("Das Eingabebild muss ein binäres Bild (logical) sein.");
    end

    % Finden der Pixelkoordinaten der weißen Bereiche
    [rowCoords, colCoords] = find(binaryImage);

    % Überprüfen, ob weiße Pixel vorhanden sind
    if isempty(rowCoords)
        error("Das Bild enthält keine weißen Pixel.");
    end

    % Berechnung des minimalen Begrenzungskreises
    [centerX, centerY, radius] = minboundcircle(colCoords, rowCoords);

    % Erstelle ein Bild mit dem Kreis
    figure("Name", "MinBoundCircle");
    imshow(binaryImage);
    hold on;

    % Zeichne den Kreis
    theta = linspace(0, 2*pi, 100); % Kreis-Parameter
    xCircle = centerX + radius * cos(theta);
    yCircle = centerY + radius * sin(theta);
    plot(xCircle, yCircle, 'r', 'LineWidth', 2); % Kreis einzeichnen

    % Zeichne den Mittelpunkt
    plot(centerX, centerY, 'go', 'MarkerSize', 10, 'LineWidth', 2);

    % Beschriftung
    title("Minimaler Begrenzungskreis");
    legend("Begrenzungskreis", "Mittelpunkt");
    hold off;
end

function [xc, yc, r] = minboundcircle(x, y)
    % MINBOUNDCIRCLE - Berechnet den minimalen Begrenzungskreis für 2D-Punkte
    % 
    % [xc, yc, r] = minboundcircle(x, y) berechnet den Mittelpunkt (xc, yc) 
    % und den Radius r des minimalen Begrenzungskreises, der alle Punkte umfasst.
    %
    % Eingabe:
    % x, y - Arrays der x- und y-Koordinaten
    %
    % Ausgabe:
    % xc, yc - Mittelpunkt des Kreises
    % r - Radius des Kreises
    
    % Kombiniere Punkte
    points = [x(:), y(:)];
    k = convhull(points); % Konvexe Hülle
    hullPoints = points(k, :); % Punkte der Hülle

    % Berechnung des minimalen Kreises
    [xc, yc, r] = welzl(hullPoints);
end

function [xc, yc, r] = welzl(points)
    % WELZL - Implementierung des Welzl-Algorithmus
    if isempty(points)
        xc = 0;
        yc = 0;
        r = 0;
    elseif size(points, 1) == 1
        xc = points(1, 1);
        yc = points(1, 2);
        r = 0;
    elseif size(points, 1) == 2
        xc = mean(points(:, 1));
        yc = mean(points(:, 2));
        r = sqrt(sum((points(1, :) - points(2, :)).^2)) / 2;
    else
        % Rekursiver Algorithmus
        shuffleIdx = randperm(size(points, 1));
        for i = 1:numel(shuffleIdx)
            pt = points(shuffleIdx(i), :);
            [xc, yc, r] = welzl(points([1:i-1, i+1:end], :));
            if norm([xc, yc] - pt) > r
                [xc, yc, r] = minBoundCircleWithPoint(points(1:i-1, :), pt);
            end
        end
    end
end

function [xc, yc, r] = minBoundCircleWithPoint(points, p)
    % Unterstützung zur Rekonstruktion eines Kreises
    n = size(points, 1);
    if n == 0
        xc = p(1);
        yc = p(2);
        r = 0;
    elseif n == 1
        xc = (p(1) + points(1, 1)) / 2;
        yc = (p(2) + points(1, 2)) / 2;
        r = norm([xc, yc] - p);
    else
        % Verwende den Umkreis des Dreiecks
        x1 = points(1, 1); y1 = points(1, 2);
        x2 = points(2, 1); y2 = points(2, 2);
        x3 = p(1); y3 = p(2);
        A = [x1 - x2, y1 - y2; x1 - x3, y1 - y3];
        B = 0.5 * [x1^2 - x2^2 + y1^2 - y2^2; x1^2 - x3^2 + y1^2 - y3^2];
        center = A\B;
        xc = center(1);
        yc = center(2);
        r = norm([xc - x1, yc - y1]);
    end
end