clear all;
clc;

addpath('image_processing\');
addpath('visualization\');
addpath('containers\');
showVideo = true;

% video settings
videoFile = VideoFileV2("30_deg_view_B.avi", "Grayscale");
videoFile.setROI(200, "LR"); % 200
videoFile.setROI(100, "CT");
videoFile.setROI(0, "CB");
disp(videoFile);


% 'start' video to apply settings
start(videoFile);
disp(videoFile);

frameStack = ImageStack.fromVideo(videoFile, "Empty");
disp(frameStack);

videoWindow = figure;

pre = ImageProcessorV2();
disp(pre);

reconstructor = GeometryReconstructor(videoFile, 50, 62, {"coveredDistance", 320, "translationVelocity", 3.2});
[nPixels, error] = reconstructor.calculateStretchFactor(reconstructor.voxelDimensions);
% disp(reconstructor);


while true
    try
        frame = videoFile.getFrame();
    catch ME
        break;
    end
    disp(videoFile);

    frame = ImageData(frame);

    % gamma correction: brighten (g < 1), darken (g > 1)
    pre.setGamma(frame, 0.75);
    pre.medianFilter(frame, 15);
    
    % mean filtering
    % frameStruct = pre.meanFilter(frameStruct, 0, "<=");

    % stretch filtered values to range 0 to 255 again
    % frameStruct = pre.asGrayscale(frameStruct);

    % set zero values to nan
    % frameStruct = pre.threshold(frameStruct, 0, "==");

    frameStack.setData(frame, videoFile.nFrames - videoFile.frameIndex + 1);

    frame.show(videoWindow, "Frame " + num2str(videoFile.frameIndex) + "/" + num2str(videoFile.nFrames));
    pause(1 / videoFile.frameRate);
end

projectionImage = frameStack.project("Sum", "Height");
projectionImage = ImageData.asGrayscale(projectionImage.getData());
show(projectionImage)

return;

%% Projection

modeA = "sum";
modeB = "min";
axis = "height";
projectionA = pre.projectFrames(frameStack, modeA, axis);
projectionB = pre.projectFrames(frameStack, modeB, axis);

projectionA = pre.asGrayscale(projectionA);
projectionB = pre.asGrayscale(projectionB);

multiPlot(projectionA, projectionB);

stretchedProjection = pre.stretchImage(projectionA, "height", nPixels);

[roiImage, roiCoords] = pre.selectROI(stretchedProjection);
roiImage = pre.asGrayscale(roiImage);


%% Pointcloud

roiCoords(1,:) = floorDiv(roiCoords(1,:), nPixels);
pointsXYZA = reconstructor.createCoordGrid(frameStack);

pcl = PointCloudData(pointsXYZA, "Frames");
pcl.relabel("x", "Width");
pcl.relabel("y", "Height");
pcl.relabel("z", "Depth");
pcl.relabel("a", "Intensity");
pcl.setUnit("px");
pcl.setUnit("1", "Intensity");
pcl.getInfo();

% cropping
pcl.crop("Width", roiCoords(2,1), roiCoords(2,2));
pcl.crop("Depth", roiCoords(1,1), roiCoords(1,2));
pcl.crop("Intensity", 64, 124);
pcl.getInfo();

% scale point cloud
pcl.setData(pcl.getData("Width") * 2, "Width");
pcl.setData(pcl.getData("Height") * 2, "Height");
pcl.setData(pcl.getData("Depth") * 2, "Depth");
pcl.setUnit("mm");
pcl.setUnit("1", "Intensity");

pcl.show("Point Cloud", "Width", "Depth", "Height")

pcl.saveFigure("test")
pause;
close all;

function multiPlot(varargin)

% number of images
nImages = nargin;
nRows = floor(sqrt(nImages));
nColumns = ceil(nImages / nRows);

% create figure and display images
figure("Name", "Images", "NumberTitle", "off");

for i = 1:nImages
    subplot(nRows, nColumns, i);
    imshow(varargin{i}.image);
    title(varargin{i}.title);
    xlabel(varargin{i}.xLabel);
    ylabel(varargin{i}.yLabel);
end
end




function remainingPoints = removeRandomPoints(points, percentage)
    % Punkte zufällig entfernen
    % points: Ein Nxm-Matrix, wobei N die Anzahl der Punkte und m die Anzahl der Dimensionen pro Punkt ist
    % percentage: Der Prozentsatz der Punkte, die entfernt werden sollen (zwischen 0 und 100)
    
    % Gesamtzahl der Punkte
    numPoints = size(points, 1);
    
    % Anzahl der zu entfernenden Punkte berechnen
    numToRemove = round((percentage / 100) * numPoints);
    
    % Zufällige Permutation der Indizes der Punkte
    indices = randperm(numPoints);
    
    % Indizes der zu entfernenden Punkte
    removeIndices = indices(1:numToRemove);
    
    % Den Rest der Punkte behalten
    remainingPoints = points;
    remainingPoints(removeIndices, :) = [];
end