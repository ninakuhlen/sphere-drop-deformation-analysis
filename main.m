% Hauptskript

addpath('Presentation\')

% Variablen
brightnessThreshold = 10;
videoPath = "../testVideo1.avi";
figureId = 1;
% [file, location] = uigetfile('*.avi');
% if isequal(file, 0)
%     error('file not found');
% else
%     videoPath = fullfile(location, file);
% end
% Instanz von FrameConverter erstellen
frameConverter = FrameConverter(brightnessThreshold);

% Video Player erstellen
videoReader = VideoReader(videoPath);

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
