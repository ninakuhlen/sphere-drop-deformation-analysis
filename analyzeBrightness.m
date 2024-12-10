function [averageBrightness, maximumBrightness, frameNumber, frameRate] = analyzeBrightness(videoObject, roi)
    % analyzeBrightness - Analyzes the brightness in the ROI of the video
    % Input:
    %   videoObject - VideoReader object
    %   roi - [x, y, width, height] array defining the ROI
    % Output:
    %   averageBrightness - Array of average brightness values for each frame
    %   maximumBrightness - Array of maximum brightness values for each frame
    %   frameNumber - Total number of frames analyzed
    %   frameRate - Frame rate of the video

    frameNumber = 0;
    averageBrightness = [];
    maximumBrightness = [];
    frameRate = videoObject.FrameRate;

    while hasFrame(videoObject)
        % Read the current frame
        frame = readFrame(videoObject);
        frameNumber = frameNumber + 1;

        % Convert to grayscale if necessary
        if size(frame, 3) == 3
            grayFrame = rgb2gray(frame);
        else
            grayFrame = frame;
        end

        % Extract the ROI
        roiFrame = extractROI(grayFrame, roi);

        % Calculate brightness metrics
        avgBrightness = mean(roiFrame(:)); % Average brightness
        maxBrightness = max(roiFrame(:)); % Maximum brightness

        % Store results
        averageBrightness = [averageBrightness; avgBrightness];
        maximumBrightness = [maximumBrightness; maxBrightness];
    end
end
