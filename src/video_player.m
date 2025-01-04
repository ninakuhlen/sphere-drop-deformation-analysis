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
    % reducedFrameStack = apply(roi, video.frameStack);
    
    % videoPlayerHandle = VideoPlayerHandle(figureId, video);
    % videoPlayer = VideoPlayer(videoPlayerHandle, 1, 2, 2);
    % 
    % videoPlayerControls = VideoPlayerControls(videoPlayerHandle, 3, 1, 1); % z. B. im gleichen Grid wie VideoPlayer & Histogram
    % 
    % figureObj = Figure(figureId, {videoPlayerControls, videoPlayer}); % cell array erstellen (kann unterschiedliche objekt types beinhalten (Historgram oder VideoPlayer))
    % show(figureObj);
    
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

% Debug: Überprüfe den Inhalt
% disp(size(stretchedFrameStack));
% imshow(min(stretchedFrameStack(:)));
% imshow(max(stretchedFrameStack(:)));
figure();
imshow(stretchedFrameStack);
title("gestretchte Video Summe");


%% Bildverarbeitung

% % Medianfilter
% smoothedMedianImage = medfilt2(stretchedFrameStack, [3, 3]); % 3x3 Medianfilter
% figure(4);
% imshow(smoothedMedianImage, []);
% title('Nach Medianfilterung');

% % Histogram-Ausgleich
% figure();
% contrastImage = histeq(smoothedGaussImage);
% imshow(contrastImage, []);
% title('Nach Histogrammausgleich');

% % Lokale Standardabweichung zur Kreis-Extrahierung
% localStd = stdfilt(stretchedFrameStack, true(5)); % 5x5 Nachbarschaft
% figure();
% imshow(localStd, []);
% title('Lokale Standardabweichung');

% % Bilateralfilter bewahrt Kanten und Glättet gleichzeitig
% smoothedImage = imbilatfilt(stretchedFrameStack);
% figure;
% imshow(smoothedImage, []);
% title('Nach Bilateral-Filterung');

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

return;

% % Kreis rekonstrieren
% Regionseigenschaften berechnen
stats = regionprops(iterativeClosing, 'Centroid', 'MajorAxisLength', 'MinorAxisLength')

% Größtes zusammenhängendes Objekt analysieren (falls mehrere Objekte vorhanden sind)
[~, largestIdx] = max([stats.Area]);
center = stats(largestIdx).Centroid; % Mittelpunkt [x, y]
majorAxis = stats(largestIdx).MajorAxisLength / 2; % Halbe Hauptachse

% Kreisradius festlegen (größte Achse als Grundlage)
radius = majorAxis;

% Erstelle eine leere Maske
[rows, cols] = size(iterativeClosing);
[X, Y] = meshgrid(1:cols, 1:rows); % Pixelkoordinaten

% Kreisgleichung anwenden
circleMask = ((X - center(1)).^2 + (Y - center(2)).^2) <= radius^2;

% Kreis auf das Bild anwenden
circleImage = false(rows, cols);
circleImage(circleMask) = 1;

figure();
imshow(circleImage);
title('Perfekte Kreis-Maske');


% % Gauß-Filter
% smoothedGaussImage = imgaussfilt(filteredImage, 2); % Sigma = 2
% smoothedGaussImage = double(smoothedGaussImage);
% figure();
% imshow(smoothedGaussImage, []);
% title('Nach Gauß-Filterung');

% Glätten der Kanten
% se = strel('disk', 15); % Kleineres Strukturelement zum Glätten
% erodedImage = imerode(filteredImage, se); % Kanten leicht zurücknehmen
% smoothedImage = imdilate(erodedImage, se); % Kreis wiederherstellen
% smoothedImage = double(smoothedImage);
% figure();
% imshow(smoothedImage);
% title('Geglättete Kanten');



% % Morphologische Dilatation, um den Kreis zu schließen
% se = strel('disk', 10); % Struktur mit Radius 5 Pixel (anpassen je nach Lücken)
% dilatedImage = imdilate(filteredImage, se);
% figure();
% imshow(dilatedImage);
% title("dilated Image");

% erneut nur größere zusammenhängende Bereiche behalten
% minObjectSize = 40000; % Passe die Mindestgröße an
% filteredImage = bwareaopen(iterativeClosing, minObjectSize);
% figure();
% imshow(filteredImage);
% title('Erneut Nur große zusammenhängende Objekte');


% % Lücken füllen
% filledImage = imfill(iterativeClosing, 'holes');
% figure();
% imshow(filledImage);
% title('Gefüllter Kreis');

% Kreis-Kanten verbessern
% edges = edge(smoothedImage, 'canny', [0.1, 0.3]);%, 1.5);
% figure();
% imshow(edges);
% title('Nach Canny Kanten Verbesserung');

% % Kreiserkennung nach Hough
% radiusRange = [200, 5000]; % Beispiel: Kreise mit Radien zwischen 20 und 100 Pixeln
% % Kreise erkennen
% [centers, radii] = imfindcircles(iterativeClosing, radiusRange, 'Sensitivity', 0.9, 'EdgeThreshold', 0.1);
% figure();
% imshow(iterativeClosing); % Zeige das Bild an
% hold on;
% viscircles(centers, radii, 'EdgeColor', 'r'); % Kreise zeichnen
% title('Gefundene Kreise');
% hold off;



return;

figure(2); title("gestretchte Video Frames");
imshow(frameSummation.computeSum(stretchedFrameStack));

return;


return;

videoPlayerHandle = VideoPlayerHandle(figureId, videoReader);
videoPlayer = VideoPlayer(videoPlayerHandle, 1, 2, 2);
videoPlayerControls = VideoPlayerControls(videoPlayerHandle, 3, 1, 1); % z. B. im gleichen Grid wie VideoPlayer & Histogram

figureObj = Figure(figureId, {videoPlayerControls, videoPlayer}); % cell array erstellen (kann unterschiedliche objekt types beinhalten (Historgram oder VideoPlayer))

% event listener registrieren um callback function für jedes frame update
% aufzurufen
videoPlayerHandle.registerHandler( ...
    "VideoFrameUpdated", ...
    @(src,event) videoFrameUpdatedCallback(src, event, figureObj, frameConverter) ...
);

show(figureObj);

% Instanz von VideoReader stellen um aus Datei-Pfad Video laden zu können

% Frames aus Video inspizieren
% FrameInspector.displayFrameResolution(extractedVideoFrames);
% frameInspector.displayFrame();
%frameInspector.displayPixelValues();
% FrameInspector.displayFrameRegion(extractedVideoFrames, 90, 300:1000, 350:1650);

% summed Matrix anzeigen:
% frameSummation = FrameSummation(extractedBinarizedFrames);
% summedMatrix = frameSummation.computeSum();
% 
% fprintf('Summed brightness matrix computation completed.\n');
% fprintf('Resulting matrix size: %dx%d\n', size(summedMatrix, 1), size(summedMatrix, 2));
% figure;
% imshow(summedMatrix);
% title('summed brightness Matrix');

function videoFrameUpdatedCallback(~, event, figure, frameConverter)
    grayFrame = frameConverter.convertToGrayFrame(getFrame(event));
    histogram = Histogram(grayFrame, 2, 1, 2);
    figure.addComponent(histogram);
end
