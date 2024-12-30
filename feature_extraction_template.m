addpath('src\image_processing\');
addpath('src\visualization\');

% boolean zur Video-Anzeige
showVideo = false;

videoFile = VideoFile("30_deg_view_A.avi");
videoFile.setROI(200, "width", "symmetrical"); % 200
videoFile.setROI(-100, "height", "from center");
disp(videoFile);

reconstructor = GeometryReconstructor(videoFile, 50, 62, {"coveredDistance", 300, "translationVelocity", 3.2});
[nPixels, error] = reconstructor.calculateStretchFactor(reconstructor.voxelDimensions);
disp(reconstructor);

pre = ImageProcessor();
disp(pre);

%% Initialisierung von deinen Klassen


%% Video-Anzeige
if showVideo
    videoWindow = figure("Name", "Video");
end

%% Erstellung eines Frame Stacks
frameStack = videoFile.createFrameContainer(1);


while true
    %% Ziehe Bild aus Video
    try
        frame = videoFile.getFrame();
    catch ME
        break;
    end

    frameStruct = pre.asImageStruct(frame);
    frameStruct = pre.asGrayscale(frameStruct);
    % unter frameStruct.image findest du das konvertierte Frame
    % frame = rgb2gray(frame);

    %% Ab hier kannst du jeden einzelnen frame bearbeiten
    
    % Gamma-Korrektur: imadjust(frameStruct.image, [], [], gamma);
    % Median-Filter: medfilt2(frameStruct.image, ...);
    % thresholding: filteredStruct.image(imageStruct.image == value) = NaN;
    % Binarisierung: imbinarize(frameStruct.image, ...);
    % Grayscale Erodion, Dilation, Opening und Closing
 
    
    %% Erstellung eines Frame Stacks
    frameStack(:,:,end - videoFile.frameIndex + 1) = frameStruct.image;
    %% Video-Anzeige
    if showVideo
        % show filtered frame
        imshow(frameStruct.image);
        set(videoWindow, "Name", "Frame " + num2str(videoFile.frameIndex) + "/" + num2str(videoFile.nFrames));
        pause(1 / videoFile.frameRate);
    end
end

%% Erstellung der Projektionen

mode = "max";
axis = "depth";
projectionHeight = pre.projectFrames(frameStack, mode, axis);
projectionHeight = pre.asGrayscale(projectionHeight);

%% Hier Operationen

stretchedProjection = pre.stretchImage(projectionHeight, "height", nPixels);

[roiImage, ~] = pre.selectROI(stretchedProjection);
roiImage = pre.asGrayscale(roiImage);

% roiImage.image gibt die region of interest als Matrix aus

pause;

close all;
clear all;
clc;