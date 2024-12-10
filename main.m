% main.m
% Entry point for brightness analysis

% Load the video
videoFile = 'testVideo1.avi';
videoObject = loadVideo(videoFile);

% % Define Region of Interest (ROI)
% roi = [500, 300, 200, 100]; % [x, y, width, height]
% 
% % Analyze brightness in the video
% [averageBrightness, maximumBrightness, frameNumber, frameRate] = analyzeBrightness(videoObject, roi);
% 
% % Plot the results
% plotBrightness(frameNumber, frameRate, averageBrightness, maximumBrightness);
% 
% % Save the results to a CSV file
% saveResults(frameNumber, frameRate, averageBrightness, maximumBrightness, 'brightness_analysis.csv');
