function videoObject = loadVideo(videoFile)
    % loadVideo - Loads the video from the given file
    % Input:
    %   videoFile - Path to the video file
    % Output:
    %   videoObject - VideoReader object

    videoObject = VideoReader(videoFile);
    disp(['Video loaded: ', videoFile]);
end
