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

reconstructor = GeometryReconstructor(videoObj, 50, 62, {"coveredDistance", 320, "translationVelocity", 3.2});
disp(reconstructor);

processor = ImageProcessor();
disp(processor);

frameStack = zeros(videoObj.Height, videoObj.Width, videoObj.NumFrames);

% Frames einzeln auslesen und anzeigen
frameCount = 0;
index = 0;

while hasFrame(videoObj)

    % Einzelnen Frame lesen
    frame = readFrame(videoObj);
    frame = rgb2gray(frame);

    % frame = imadjust(frame, [], [], 0.45);
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

[frameProjection, axis_labels] = processor.projectFrames(frameStack, "max", 2);
[projectionMin, ~] = processor.projectFrames(frameStack, "min", 2);
projectionMin =  ~imbinarize(projectionMin) %,'adaptive','ForegroundPolarity','dark','Sensitivity',0.4);
frameProjection = frameProjection .* projectionMin;

% while hasFrame(videoObj)
% 
%     % Einzelnen Frame lesen
%     frame = readFrame(videoObj);
%     frame = rgb2gray(frame);
% 
%     frame = frame - projectionMin;
% 
% 
%     % Frame anzeigen
%     imshow(frame);
%     title(['Frame ', num2str(frameCount)]);
%     pause(1 / videoObj.FrameRate); % Zeit für die Anzeige eines Frames (entspricht der Framerate des Videos)
% end


frameProjection = mat2gray(projectionMin);


figure;
imshow(frameProjection);
title('Frame Projection');
xlabel(axis_labels("x"));
ylabel(axis_labels("y"));

