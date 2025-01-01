% Variablen
videoPath = "..\data\recordings\";
brightnessThreshold = 50;
traversedCameraDistance = 300; % [mm]

fieldOfViewWidth = 62; % [mm]

% Definiere den ROI (mittlerer Bereich)
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

videoLoader = VideoLoader(videoPath, frameConverter);
video = videoLoader.load("30_deg_view_A.avi");

roi = ROI(rowStart, rowEnd, colStart, colEnd);
reducedFrameStack = apply(roi, video.frameStack);

% videoPlayerHandle = VideoPlayerHandle(figureId, video);
% videoPlayer = VideoPlayer(videoPlayerHandle, 1, 2, 2);
% 
% videoPlayerControls = VideoPlayerControls(videoPlayerHandle, 3, 1, 1); % z. B. im gleichen Grid wie VideoPlayer & Histogram
% 
% figureObj = Figure(figureId, {videoPlayerControls, videoPlayer}); % cell array erstellen (kann unterschiedliche objekt types beinhalten (Historgram oder VideoPlayer))
% show(figureObj);

[frameSum1, ~, ~]= frameSummation.computeSum(reducedFrameStack);

figure(1); title("Nicht gestretchte Video Summe");
imshow(frameSum1);

figure(3); title("gestretchte Video Summe");

stretchedFrameStack = stretchAndProject(frameStretcher, video, roi);
% Debug: Überprüfe den Inhalt
% disp(size(stretchedFrameStack));
% imshow(min(stretchedFrameStack(:)));
% imshow(max(stretchedFrameStack(:)));
imshow(stretchedFrameStack);
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
