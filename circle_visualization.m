clear all;
clc;

addpath('src\image_processing\');
addpath('src\visualization\');

showVideo = false;

videoFile = VideoFile("30_deg_view_B.avi");
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

% stretchedProjection.image = medfilt2(stretchedProjection.image, [45, 25], "symmetric");
[roiImage, roiCoords] = pre.selectROI(stretchedProjection);
roiImage = pre.asGrayscale(roiImage);

roiImage.image = medfilt2(roiImage.image, [3, 3], "symmetric")
binarizedImage = imbinarize(roiImage.image);

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

drawMinBoundCircle(edgeImage);

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