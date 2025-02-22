clear all;
close all;
clc;

addpath("image_processing\");
addpath("visualization\");
addpath("containers\");

showVideo = false;
enableHistogram = false;
record = true;
targetFrame = 0;
fileName = "30_deg_A";


%% PREPROCESSING

% input video settings
videoFile = VideoFileV2(fileName + ".avi", "Grayscale");
videoFile.setROI(200, "LR"); % 200
videoFile.setROI(100, "CT");
videoFile.setROI(0, "CB");
disp(videoFile);

pre = ImageProcessorV2();
disp(pre);

rec = GeometryReconstructor(videoFile, 50, 62, {"coveredDistance", 300, "translationVelocity", 3.2});
disp(rec);

if record
    % output video setup
    outputVideo = VideoWriter("..\res\videos\"+ fileName + "_processed.avi", "Uncompressed AVI");
    open(outputVideo);
end

%% VIDEO PROCESSING

if showVideo
    videoWindow = figure;
    if enableHistogram
        histogramWindow = figure;
    end
end

% create empty ImageStack from VideoFile
frameStack = ImageStack.fromVideo(videoFile);
disp(frameStack);

while true
    try
        frame = videoFile.getFrame();
    catch ME
        break;
    end

    frame = ImageData(frame);

    % gamma correction: brighten (g < 1), darken (g > 1)
    pre.setGamma(frame, 0.75);
    pre.medianFilter(frame, 15);
    pre.meanThreshold(frame, 0, "<=");

    frameStack.setData(frame, videoFile.nFrames - videoFile.frameIndex + 1);
    if showVideo
        frame.show(videoWindow, "Frame " + num2str(videoFile.frameIndex) + "/" + num2str(videoFile.nFrames));
        if enableHistogram
            frame.showHistogram(histogramWindow, "Frame " + num2str(videoFile.frameIndex) + "/" + num2str(videoFile.nFrames));
        end
        % disp(frame);
        % pause(1 / videoFile.frameRate);
    end

    if videoFile.frameIndex ~= 0 && videoFile.frameIndex == targetFrame
        break
    end

    if record
        image = uint8(frame.getData());
        writeVideo(outputVideo, image);
    end
end

if record
    close(outputVideo);
end

% return

%% PROJECTION

projectionImage = frameStack.project("Sum", "Depth");
pre.meanThreshold(projectionImage, 1, "<=");
pre.normalize(projectionImage, 8);
figure;
show(projectionImage);

projectionImage = frameStack.project("Sum", "Width");
pre.meanThreshold(projectionImage, 1, "<=");
pre.normalize(projectionImage, 8);
figure;
show(projectionImage);

projectionImage = frameStack.project("Sum", "Height");
pre.meanThreshold(projectionImage, 1, "<=");
pre.normalize(projectionImage, 8);
figure;
show(projectionImage);


%% ROI

stretchedProjection = pre.stretchImage(projectionImage, "height", rec.stretchFactor);
[roiImage, roi] = pre.selectROI(stretchedProjection);

pre.medianFilter(roiImage, 31, 5);
pre.gaussianFilter(roiImage, 2, 31, 5);

figure;
show(roiImage);

otsuThreshold = pre.binarize(roiImage);

figure;
morphedImage = pre.multiStepMorphing(roiImage, 15, "Disk", "Shrink", "Erode", roiImage);
morphedImage = pre.multiStepMorphing(morphedImage, 15, "Disk", "Grow", "Dilate", roiImage);

disp(morphedImage);
morphedImage.dispLog();

rec.calculateDomeDimensions(morphedImage);


%% POINTCLOUD

% unstretch roi height
roi(1,:) = floorDiv(roi(1,:), rec.stretchFactor);

pcl = PointCloudData.fromImageStack(frameStack, "Frames");
pcl.relabel("x", "Width");
pcl.relabel("y", "Height");
pcl.relabel("z", "Depth");
pcl.relabel("a", "Grayscale");
pcl.setUnit("px");
pcl.setUnit("1", "Grayscale");
pcl.getInfo();

% cropping
pcl.crop("Width", roi(2,1), roi(2,2));
pcl.crop("Depth", roi(1,1), roi(1,2));
pcl.crop("Grayscale", 50, otsuThreshold);
pcl.getInfo();

% translate point cloud along height
heightData = pcl.getData("Height");
maxHeight = max(heightData, [], "all");
heightData(:) = heightData(:) - maxHeight;
pcl.setData(heightData, "Height");

% scale point cloud
pcl.setData(pcl.getData("Width") * rec.voxelEdgeX, "Width");
pcl.setData(pcl.getData("Height") * rec.voxelEdgeY, "Height");
pcl.setData(pcl.getData("Depth") * rec.voxelEdgeZ, "Depth");
pcl.setUnit("mm");
pcl.setUnit("1", "Grayscale");
pcl.getInfo();

figure;
pcl.show("Point Cloud", "Width", "Depth", "Height")