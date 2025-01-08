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

% mask = uint8(imbinarize(stretchedProjection.image, 182/255) * 255);
mask = uint8(imbinarize(stretchedProjection.image) * 255);

imshow(mask);

pause;

% stretchedProjection.image = stretchedProjection.image .* mask;
findLargestHistogramSlopeWithEnvelope(stretchedProjection.image, 256);

% stretchedProjection.image = medfilt2(stretchedProjection.image, [45, 25], "symmetric");
[roiImage, roiCoords] = pre.selectROI(stretchedProjection);
roiImage = pre.asGrayscale(roiImage);


%% Pointcloud

roiCoords(1,:) = floorDiv(roiCoords(1,:), nPixels);
pointsXYZA = reconstructor.createCoordGrid(frameStack);
disp("")
fprintf("Width Min Max:\t%s\n", num2str([min(pointsXYZA(:,1), [], "all") max(pointsXYZA(:,1), [], "all")]));
fprintf("Height Min Max:\t%s\n", num2str([min(pointsXYZA(:,2), [], "all") max(pointsXYZA(:,2), [], "all")]));
fprintf("Depth Min Max:\t%s\n", num2str([min(pointsXYZA(:,3), [], "all") max(pointsXYZA(:,3), [], "all")]));
fprintf("Uncropped Size:\t%s\n", num2str(size(pointsXYZA)));
% width cropping
roiPointsXYZA = pointsXYZA(pointsXYZA(:,1) >= roiCoords(2,1), :);
roiPointsXYZA = roiPointsXYZA(roiPointsXYZA(:,1) <= roiCoords(2,2), :);
disp("")
fprintf("Width Min Max:\t%s\n", num2str([min(roiPointsXYZA(:,1), [], "all") max(roiPointsXYZA(:,1), [], "all")]));
fprintf("Height Min Max:\t%s\n", num2str([min(roiPointsXYZA(:,2), [], "all") max(roiPointsXYZA(:,2), [], "all")]));
fprintf("Depth Min Max:\t%s\n", num2str([min(roiPointsXYZA(:,3), [], "all") max(roiPointsXYZA(:,3), [], "all")]));
fprintf("Width Cropped Size:\t%s\n", num2str(size(roiPointsXYZA)));


% depth cropping
roiPointsXYZA = roiPointsXYZA(roiPointsXYZA(:,3) >= roiCoords(1,1), :);
roiPointsXYZA = roiPointsXYZA(roiPointsXYZA(:,3) <= roiCoords(1,2), :);
disp("")
fprintf("Width Min Max:\t%s\n", num2str([min(roiPointsXYZA(:,1), [], "all") max(roiPointsXYZA(:,1), [], "all")]));
fprintf("Height Min Max:\t%s\n", num2str([min(roiPointsXYZA(:,2), [], "all") max(roiPointsXYZA(:,2), [], "all")]));
fprintf("Depth Min Max:\t%s\n", num2str([min(roiPointsXYZA(:,3), [], "all") max(roiPointsXYZA(:,3), [], "all")]));
fprintf("Depth Cropped Size:\t%s\n", num2str(size(roiPointsXYZA)));
% grayscale thresholding
threshold = 0;
filteredPointsXYZA = roiPointsXYZA(roiPointsXYZA(:,4) > threshold, :);
fprintf("GS Thresholded Size:\t%s", num2str(size(filteredPointsXYZA)));
% filteredPoints = removeRandomPoints(filteredPoints, 99);
% size(filteredPoints)

sclaedPointsXYZA = reconstructor.scaleCoordGrid(filteredPointsXYZA);
stepSize = 1;
plotData(...
    sclaedPointsXYZA(1:stepSize:end,1), ... % X = width
    sclaedPointsXYZA(1:stepSize:end,3), ... % Y = depth
    sclaedPointsXYZA(1:stepSize:end,2) ... % Z = height (2), grayscale (4)
    );

pause;

clear cleanupObj;
return


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
filterKernel = strel(kernelShape, kernelSize);
morphedImage = imclose(binarizedImage, filterKernel);
morphedImage = pre.multiStepMorphing(morphedImage, kernelShape, kernelSize, "shrink", "erode", morphFigure, binarizedImage);
morphedImage = pre.multiStepMorphing(morphedImage, kernelShape, kernelSize, "grow", "dilate", morphFigure, binarizedImage);
pause;

imshow(morphedImage);


edgeImage = edge(morphedImage,"Canny");

edgeImage = bwmorph(edgeImage, "branchpoints");
pause;

imshow(edgeImage);

pause;

% initial dilation
% filterKernel = strel(kernelShape, kernelSize);
% morphedImage = imdilate(binarizedImage, filterKernel);

resizedBinaryImage = imresize(morphedImage, 0.5, "nearest");

[yCoords, xCoords] = find(edgeImage);
yDim = max(yCoords) - min(yCoords)
xDim = max(xCoords) - min(xCoords)

yDimMM = yDim * reconstructor.voxelDimensions(2)
xDimMM = xDim * reconstructor.voxelDimensions(1)
% drawMinBoundCircle(edgeImage);
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



function plotData(x, y, z)
    % Funktion zur Visualisierung von Daten aus bis zu drei Vektoren.
    % - Wenn z weggelassen wird, wird ein 2D-Plot erstellt.
    % - Wenn z angegeben wird, wird ein 3D-Plot erstellt.
    
    f = figure; % Neues Fenster für den Plot

    c = z;

    if nargin == 2
        % 2D Daten
        p = scatter(x, y, 'o-'); % Zeichnet einen 2D-Plot mit Linien und Punkten
        xlabel('X');
        ylabel('Y');
        title('2D Datenvisualisierung');
        grid on;
    elseif nargin == 3
        % 3D Daten
        p = scatter3(x, y, z, 8, z,"filled","o"); % Zeichnet einen 3D-Plot mit Linien und Punkten
        % p.Color = "blue";
        % p.Marker = ".";
        xlabel('X');
        ylabel('Y');
        zlabel('Z');
        title('3D Datenvisualisierung');
        colorbar;
        axis equal;
        grid on;
        rotate3d on; % Aktiviert die 3D-Rotation mit der Maus
    else
        error('Bitte entweder zwei oder drei Vektoren als Argumente übergeben.');
    end
end

function remainingPoints = removeRandomPoints(points, percentage)
    % Punkte zufällig entfernen
    % points: Ein Nxm-Matrix, wobei N die Anzahl der Punkte und m die Anzahl der Dimensionen pro Punkt ist
    % percentage: Der Prozentsatz der Punkte, die entfernt werden sollen (zwischen 0 und 100)
    
    % Gesamtzahl der Punkte
    numPoints = size(points, 1);
    
    % Anzahl der zu entfernenden Punkte berechnen
    numToRemove = round((percentage / 100) * numPoints);
    
    % Zufällige Permutation der Indizes der Punkte
    indices = randperm(numPoints);
    
    % Indizes der zu entfernenden Punkte
    removeIndices = indices(1:numToRemove);
    
    % Den Rest der Punkte behalten
    remainingPoints = points;
    remainingPoints(removeIndices, :) = [];
end


function cleanupFunction()
    clear all;
    close all;
    clc;
end