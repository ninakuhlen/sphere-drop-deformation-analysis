clear all;
close all;
addpath('containers\')
maxNumCompThreads('automatic'); % use maximum available threads

% camera setup
camera = BaslerCamera("gentl", 30);

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