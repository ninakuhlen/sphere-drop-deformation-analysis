% MATLAB Code zum Auslesen einer AVI-Video Datei

% Video Datei einlesen
parentDirectory = "C:\Users\Studium\Documents\GitHub\sphere-drop-deformation-analysis\data\recordings\testing\";
videoFile = "30_deg_view_B.avi";
videoObj = VideoReader(parentDirectory+videoFile);

% Informationen über das Video anzeigen
disp('Video Informationen:');
disp(['Dateiname: ', videoObj.Name]);
disp(['Auflösung: ', num2str(videoObj.Width), ' x ', num2str(videoObj.Height)]);
disp(['Anzahl Frames: ', num2str(videoObj.NumFrames)]);
disp(['Framerate: ', num2str(videoObj.FrameRate), ' fps']);
disp(['Pixel Format: ', num2str(videoObj.BitsPerPixel), ' px']);

reconstructor = GeometryReconstructor(videoObj, 5.0, 5.0, 62.0);

numberOfFrames = int32(videoObj.Duration * videoObj.FrameRate);

frameStack = zeros(1200, 1920, numberOfFrames);

% Frames einzeln auslesen und anzeigen
frameCount = 0;
index = 1;

while hasFrame(videoObj)

    % Einzelnen Frame lesen
    frame = readFrame(videoObj);
    frame = rgb2gray(frame);

    frame = imadjust(frame, [], [], 0.45);
    % frame = imadjust(frame, [], [], 2);



    frameStack(:,:,end-index) = frame;
    frameCount = frameCount + 1;
    index = index + 1;

    % Frame anzeigen
    % imshow(frame);
    % title(['Frame ', num2str(frameCount)]);
    % pause(1 / videoObj.FrameRate); % Zeit für die Anzeige eines Frames (entspricht der Framerate des Videos)
end

disp(['Frame Stack Size: ', num2str(size(frameStack))]);

[frameProjection, axis_labels] = projectFrames(frameStack, "max", 1);
frameProjection = mat2gray(frameProjection);

figure;
imshow(frameProjection);
title('Frame Projection');
xlabel(axis_labels("x"));
ylabel(axis_labels("y"));

function [projection, labelling] = projectFrames(frameStack, mode, axis)

oldSize = size(frameStack);

switch mode
    case "sum"
        projection = sum(frameStack, axis);
    case "max"
        projection = max(frameStack, [], axis);
    case "min"
        projection = min(frameStack, [], axis);
    case "mean"
        projection = mean(frameStack, axis);
    case "median"
        projection = median(frameStack, axis);
end


switch axis
    case 1
        projection = permute(projection, [3 2 1]);
        x_label = "Frame Width";
        y_label = "Time [past -> present]";
    case 2
        projection = permute(projection, [3 1 2]);
        x_label = "Frame Height";
        y_label = "Time [past -> present]";
    case 3
        % no dimension swap necessary
        x_label = "Frame Width";
        y_label = "Frame Height";
end

labelling = dictionary(["x" "y"], [x_label y_label]);

newSize = size(projection);

displayMessage = "Projected from shape: " ...
    + num2str(oldSize) ...
    + " to " ...
    + num2str(newSize);
disp(displayMessage)
end % projectFrames