function plotBrightness(frameNumber, frameRate, averageBrightness, maximumBrightness)
    % plotBrightness - Plots the average and maximum brightness over time
    % Input:
    %   frameNumber - Total number of frames
    %   frameRate - Frame rate of the video
    %   averageBrightness - Array of average brightness values
    %   maximumBrightness - Array of maximum brightness values

    time = (1:frameNumber) / frameRate; % Time vector

    % Plot average brightness
    figure;
    plot(time, averageBrightness, '-b', 'LineWidth', 1.5);
    xlabel('Time (s)');
    ylabel('Average Brightness');
    title('Average Brightness in ROI Over Time');
    grid on;

    % Plot maximum brightness
    figure;
    plot(time, maximumBrightness, '-r', 'LineWidth', 1.5);
    xlabel('Time (s)');
    ylabel('Maximum Brightness');
    title('Maximum Brightness in ROI Over Time');
    grid on;
end
