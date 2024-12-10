% Load the video
videoFile = 'testVideo1.avi';
videoObject = VideoReader(videoFile);

% Calculate the middle frame
totalFrames = round(videoObject.FrameRate * videoObject.Duration) % Total number of frames
middleFrameNumber = round(totalFrames / 2); % Frame in the middle
testFrameNumber = 30;

% Read the middle frame
currentFrameNumber = 0;
while hasFrame(videoObject)
    currentFrameNumber = currentFrameNumber + 1;
    frame = readFrame(videoObject);
    
    if currentFrameNumber == testFrameNumber %middleFrameNumber
        break; % Stop once the selected frame is reached
    end
end

% Display the selected frame
figure;
imshow(frame);
title('Middle Frame of the Video');

% Interactively select the ROI
roi = drawrectangle('Label', 'ROI'); % Interactive ROI selection
pause; % Wait for user adjustment

% Get the ROI position
roiPosition = round(roi.Position); % [x, y, width, height]
disp(['Selected ROI: [x, y, width, height] = [', num2str(roiPosition), ']']);

% Todo this is not working
