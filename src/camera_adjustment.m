clear all;
addpath('visualization\')
maxNumCompThreads('automatic'); % use maximum available threads

% camera setting are derived from Image Acquisition Explorer:
% - AdaptorName: EXPLORER/Device List/a2A1920-160umBAS (40332755)/Adaptor
% - DeviceID: EXPLORER/Device List/a2A1920-160umBAS (40332755)/DeviceID
% - Format: EXPLORER/CONFIGURE FORMAT/Video Format
camera = BaslerCamera("adaptorName", "gentl", ...
    "deviceID", 1, ...
    "pixelFormat", "Mono8", ...
    "frameRate", 30)

fig = figure('Name', 'Live-Bild von der Kamera', 'NumberTitle', 'off');


try
    while isvalid(fig)
        frame = camera.getFrame();
        frame = drawCrossHair(frame);

        imshow(frame);
    end
catch ME
    disp("An Error occured during recording:");
    disp(ME.message);
end



function image = drawCrossHair(image)
[pixels_x, pixels_y] = size(frame);
x = floorDiv(pixels_x, 2);
y = floorDiv(pixels_y, 2);

image(x, :) = 255;
image(:,y) = 255;
end