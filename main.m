% Hauptskript

% Variablen
brightnessThreshold = 10;
videoPath = "../testVideo1.avi";
% Instanz von VideoReader stellen um aus Datei-Pfad Video laden zu können

videoReader = VideoReader(videoPath);
frameConverter = FrameConverter(brightnessThreshold);
% 1. Video laden und Frames extrahieren
videoFrameExtractor = VideoFrameExtractor(videoReader, frameConverter);
fprintf('Create VideoFrameExtractor object...\n');
% hier ist ein array aus BinarizedFrame Objekten
extractedBinarizedFrames = videoFrameExtractor.extractFrames();

extractedBinarizedFrame = extractedBinarizedFrames{100}; % das XY Frame auslesen
frameInspector = FrameInspector(extractedBinarizedFrame);
% Frames aus Video inspizieren
% FrameInspector.displayFrameResolution(extractedVideoFrames);
% frameInspector.displayFrame();
%frameInspector.displayPixelValues();
% FrameInspector.displayFrameRegion(extractedVideoFrames, 90, 300:1000, 350:1650);
frameSummation = FrameSummation(extractedBinarizedFrames);
summedMatrix = frameSummation.computeSum();

fprintf('Summed brightness matrix computation completed.\n');
fprintf('Resulting matrix size: %dx%d\n', size(summedMatrix, 1), size(summedMatrix, 2));
figure;
imshow(summedMatrix);
title('summed brightness Matrix');
