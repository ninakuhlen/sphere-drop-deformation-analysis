% Hauptskript

addpath('Presentation\')

% Variablen
brightnessThreshold = 10;
videoPath = "../testVideo1.avi";

% Instanz von FrameConverter erstellen
frameConverter = FrameConverter(brightnessThreshold);

% Video Player erstellen
videoReader = VideoReader(videoPath);

videoPlayerHandle = VideoPlayerHandle(videoReader);
videoPlayer = VideoPlayer(videoPlayerHandle, 1, 2, 2);

figure = Figure(1, {videoPlayer}); % cell array erstellen (kann unterschiedliche objekt types beinhalten (Historgram oder VideoPlayer))

% event listener registrieren um callback function für jedes frame update
% aufzurufen
videoPlayerHandle.registerHandler( ...
    "VideoFrameUpdated", ...
    @(src,event) videoFrameUpdatedCallback(src, event, figure, frameConverter) ...
);

show(figure);

% Instanz von VideoReader stellen um aus Datei-Pfad Video laden zu können

% Video laden und Frames extrahieren
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
