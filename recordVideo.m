% MATLAB Script to Record a Video for 20 Seconds and Save Each Recording with a Unique Filename

% Step 1: Configure the video input object
% Replace 'gentl' and the device ID with your camera's configuration
camera = videoinput('gentl', 1); % Example for a GenICam-compatible camera

% Set video recording parameters
camera.FramesPerTrigger = Inf; % Continuously capture frames
camera.TriggerRepeat = 0; % No repeating triggers
camera.LoggingMode = 'disk'; % Save video directly to disk

% Step 2: Generate a unique filename for the video
timestamp = datestr(now, 'yyyymmdd_HHMMSS'); % Current date and time
videoFileName = sprintf('recorded_video_%s.avi', timestamp); % Unique filename
diskLogger = VideoWriter(videoFileName, 'Uncompressed AVI');
camera.DiskLogger = diskLogger;

% Step 3: Start the video recording
disp(['Recording video: ', videoFileName]);
start(camera);

% Record for 20 seconds
pause(20);

% Step 4: Stop the video recording
stop(camera);
disp(['Recording complete. Video saved as ', videoFileName]);

% Step 5: Clean up
delete(camera); % Delete the video object
clear camera;

% Step 6: Play back the video (optional)
disp('Playing back the recorded video...');
implay(videoFileName);