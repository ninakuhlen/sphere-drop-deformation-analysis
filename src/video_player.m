% Variablen
videoPath = "..\data\recordings\";
videoFileName = "30_deg_view_A.avi";

videoLoader = VideoLoader(videoPath, frameConverter);
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

function videoFrameUpdatedCallback(~, event, figure, frameConverter)
    grayFrame = frameConverter.convertToGrayFrame(getFrame(event));
    histogram = Histogram(grayFrame, 2, 1, 2);
    figure.addComponent(histogram);
end
