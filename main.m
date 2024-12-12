% Hauptskript

% Konfiguration importieren
load('configs/configs.mat'); % Lädt die Variablen aus der configs.mat-Datei

% 1. Video laden und Frames extrahieren
videoProcessor = VideoProcessor(videoPath);
fprintf('Create VideoProcessor object...\n');
videoProcessor = videoProcessor.extractFrames();

% Frames aus Video inspizieren
% FrameInspector.displayFrameResolution(videoProcessor.extractedFrames);
% FrameInspector.displayFrame(videoProcessor.extractedFrames, 90);
% FrameInspector.displayPixelValues(videoProcessor.extractedFrames, 100);
%FrameInspector.displayFrameRegion(videoProcessor.extractedFrames, 90, 300:1000, 350:1650);


% % 2. Frames summieren
% frameSummation = FrameSummation(videoProcessor.extractedFrames);
% summedMatrix = frameSummation.computeSum();
% 
% % 3. Visualisierung
% Visualization.displaySummedMatrix(summedMatrix); % Summierte Matrix anzeigen
% Visualization.displayFrame(videoProcessor.extractedFrames(:, :, 30), 30); % 30. Frame anzeigen
