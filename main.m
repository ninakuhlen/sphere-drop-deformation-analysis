% Hauptskript

% 1. Video laden und Frames extrahieren
videoProcessor = VideoProcessor('path_to_video.avi');
videoProcessor = videoProcessor.extractFrames();

% 2. Frames summieren
frameSummation = FrameSummation(videoProcessor.frames);
summedMatrix = frameSummation.computeSum();

% 3. Visualisierung
Visualization.displaySummedMatrix(summedMatrix); % Summierte Matrix anzeigen
Visualization.displayFrame(videoProcessor.frames(:, :, 1), 1); % Ersten Frame anzeigen
