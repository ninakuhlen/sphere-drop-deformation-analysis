% Variablen
videoPath = "..\data\recordings\";
brightnessThreshold = 50;
traversedCameraDistance = 300; % [mm]
videoFileName = "30_deg_view_A.avi";
stretchedCachePath = videoPath+"cache/"+videoFileName+"\";
stretchedCacheImageFileName = "stretched-framestack.png";
useCache = false;

fieldOfViewWidth = 62; % [mm]

% ROI von Seiten Ansicht % Todo prüfen
rowStart = 500; % Startzeile
rowEnd = 600;   % Endzeile
colStart = 480; % Startspalte
colEnd = 1240;  % Endspalte

figureId = 1;
% [file, location] = uigetfile('*.avi');
% if isequal(file, 0)
%     error('file not found');
% else
%     videoPath = fullfile(location, file);
% end

% Instanz von FrameConverter erstellen
close all;

frameConverter = FrameConverter(brightnessThreshold);
frameStretcher = FrameStretcher(traversedCameraDistance, fieldOfViewWidth);
frameSummation = FrameSummation();

if ~isfile(stretchedCachePath+stretchedCacheImageFileName) || ~useCache
    if ~isfolder(stretchedCachePath)
        mkdir(stretchedCachePath);
    end
    videoLoader = VideoLoader(videoPath, frameConverter);
    video = videoLoader.load(videoFileName);
    
    roi = ROI(rowStart, rowEnd, colStart, colEnd);
    
    [frameSum1, ~, ~]= frameSummation.computeSum(video.frameStack);

    figure(1);
    imshow(frameSum1);
    title("Nicht gestretchte Video Summe");
    
    stretchedFrameStack = stretchAndProject(frameStretcher, video, roi); % Todo: für bessere Performance erst roi dann stretch
    imwrite(stretchedFrameStack, stretchedCachePath+stretchedCacheImageFileName);
else
    stretchedFrameStack = imread(stretchedCachePath+stretchedCacheImageFileName);
end

stretchedRoi = ROI(1, 761, 1, 7290);
stretchedFrameStack = apply(stretchedRoi, stretchedFrameStack);

figure();
imshow(stretchedFrameStack);
title("gestretchte Video Summe");

%% Bildverarbeitung

% nur größere zusammenhängende Bereiche behalten
minObjectSize = 60000; % Passe die Mindestgröße an
filteredImage = bwareaopen(stretchedFrameStack, minObjectSize);
filteredImage = double(filteredImage);
figure();
imshow(filteredImage);
title('Nur große zusammenhängende Objekte');

% % Morphologische Schließung (Closing)
se = strel('disk', 15); % Strukturelement: Radius = 3 Pixel (anpassen bei Bedarf)
iterativeClosing = filteredImage;
for i = 1:3 % Anzahl der Iterationen anpassen
    iterativeClosing = imclose(iterativeClosing, se);
end
figure();
imshow(iterativeClosing);
title('Nach iterativem Closing');

%% Durchmesser berechnen
% in Logical umwandeln
binaryImage = logical(filteredImage);  % Typkonvertierung sicherstellen

% Finde die vertikalen Begrenzungen
[rows, cols] = find(binaryImage); % Koordinaten der weißen Pixel

% Höchster und niedrigster Punkt
topPixel = min(rows); % Höchster Pixel (vertikal)
bottomPixel = max(rows); % Tiefster Pixel (vertikal)

% Vertikaler Durchmesser
verticalDiameterInPixels = bottomPixel - topPixel;
fprintf('Vertikaler Durchmesser Pixel: %.2f Pixel\n', verticalDiameterInPixels);

% Visualisierung Durchmesser
% Bild anzeigen
figure();
imshow(binaryImage);
hold on;

% Vertikale Linie vom höchsten zum tiefsten Punkt zeichnen
xCenter = mean(cols); % Mittlere Spalte für die Linie
plot([xCenter, xCenter], [topPixel, bottomPixel], 'r-', 'LineWidth', 2);

% Punkte markieren
plot(xCenter, topPixel, 'go', 'MarkerSize', 10, 'MarkerFaceColor', 'g'); % Höchster Punkt
plot(xCenter, bottomPixel, 'bo', 'MarkerSize', 10, 'MarkerFaceColor', 'b'); % Tiefster Punkt

title(sprintf('Vertikaler Durchmesser: %.2f Pixel', verticalDiameterInPixels));
hold off;

pixelPerMM = calculatePixelsPerMM(frameStretcher, video.resolutionX);

diameterMM = verticalDiameterInPixels / pixelPerMM;
fprintf('Durchmesser: %.2f mm\n', diameterMM);

% % Kreis rekonstrieren
% Regionseigenschaften berechnen
% stats = regionprops(iterativeClosing, 'Centroid', 'MajorAxisLength', 'MinorAxisLength')

% 
% 
% % Größtes zusammenhängendes Objekt analysieren (falls mehrere Objekte vorhanden sind)
% [~, largestIdx] = max([stats.Area]);
% center = stats(largestIdx).Centroid; % Mittelpunkt [x, y]
% majorAxis = stats(largestIdx).MajorAxisLength / 2; % Halbe Hauptachse
% 
% % Kreisradius festlegen (größte Achse als Grundlage)
% radius = majorAxis;
% 
% % Erstelle eine leere Maske
% [rows, cols] = size(iterativeClosing);
% [X, Y] = meshgrid(1:cols, 1:rows); % Pixelkoordinaten
% 
% % Kreisgleichung anwenden
% circleMask = ((X - center(1)).^2 + (Y - center(2)).^2) <= radius^2;
% 
% % Kreis auf das Bild anwenden
% circleImage = false(rows, cols);
% circleImage(circleMask) = 1;
% 
% figure();
% imshow(circleImage);
% title('Perfekte Kreis-Maske');
% 
% return;
