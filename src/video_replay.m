clear all;
clc;

addpath('image_processing\');
addpath('visualization\');
addpath('containers\');
showVideo = true;

% video settings
videoFile = VideoFileV2("30_deg_view_B.avi", "Grayscale");
videoFile.setROI(200, "LR"); % 200
videoFile.setROI(100, "CT");
videoFile.setROI(0, "CB");
disp(videoFile);


% 'start' video to apply settings
start(videoFile);
disp(videoFile);

frameStack = ImageStack.fromVideo(videoFile, "Empty");
disp(frameStack);

videoWindow = figure;


while true
    try
        frame = videoFile.getFrame();
    catch ME
        break;
    end
    disp(videoFile);

    frame = ImageData(frame);

    frameStack.setData(frame, videoFile.nFrames - videoFile.frameIndex + 1);

    frame.show(videoWindow, "Frame " + num2str(videoFile.frameIndex) + "/" + num2str(videoFile.nFrames));
    pause(1 / videoFile.frameRate);
end

projectionImage = frameStack.project("Sum", "Height");
projectionImage = ImageData.asGrayscale(projectionImage.getData());
show(projectionImage)