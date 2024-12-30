% Hauptskript

addpath("src\")
addpath("src\image_processing\conversion_operation\")
addpath("src\image_processing\filter_operation\")
%addpath('src\visualization\')

% Variablen
brightnessThreshold = 10;
videoPath = "data\recordings\testing\";
videoFileName = "30_deg_view_A.avi";
figureId = 1;
% [file, location] = uigetfile('*.avi');
% if isequal(file, 0)
%     error('file not found');
% else
%     videoPath = fullfile(location, file);
% end

% Instanz von FrameConverter erstellen
image2StructConverter = Image2StructConverter();
imageStruct2GrayScaleConverter = ImageStruct2GrayScaleConverter();
intensityThresholdMasker = IntensityThresholdMasker();
frameConverter = FrameConverter(brightnessThreshold, {image2StructConverter, imageStruct2GrayScaleConverter}, {intensityThresholdMasker});
convert(frameConverter);
filter(frameConverter, );

% Video Player erstellen
videoLoader = VideoLoader(videoPath);
video = videoLoader.load(videoFileName);
videoPlayerHandle = VideoPlayerHandle(figureId, video);
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

function videoFrameUpdatedCallback(~, event, figure, frameConverter) % Todo: refactor in Histogram verschieben
    grayFrame = frameConverter.convertToGrayFrame(getFrame(event));
    histogram = Histogram(grayFrame, 2, 1, 2);
    figure.addComponent(histogram);
end
