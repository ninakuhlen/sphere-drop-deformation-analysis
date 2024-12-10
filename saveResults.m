function saveResults(frameNumber, frameRate, averageBrightness, maximumBrightness, outputFile)
    % saveResults - Saves the brightness analysis results to a CSV file
    % Input:
    %   frameNumber - Total number of frames
    %   frameRate - Frame rate of the video
    %   averageBrightness - Array of average brightness values
    %   maximumBrightness - Array of maximum brightness values
    %   outputFile - Path to the CSV file to save results

    time = (1:frameNumber)' / frameRate; % Time vector
    resultsTable = table((1:frameNumber)', time, averageBrightness, maximumBrightness, ...
        'VariableNames', {'FrameNumber', 'Time', 'AverageBrightness', 'MaximumBrightness'});

    writetable(resultsTable, outputFile);
    disp(['Results saved to: ', outputFile]);
end
