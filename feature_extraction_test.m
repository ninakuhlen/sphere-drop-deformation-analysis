addpath('src\image_processing\')

% MATLAB Code zum Auslesen einer AVI-Video Datei

% Video Datei einlesen
parentDirectory = "C:\Users\Studium\Documents\GitHub\sphere-drop-deformation-analysis\data\recordings\testing\";
videoFile = "30_deg_view_B.avi";
video = VideoReader(parentDirectory+videoFile);

% Informationen über das Video anzeigen
disp('Video Informationen:');
disp(['Dateiname: ', video.Name]);
disp(['Auflösung: ', num2str(video.Width), ' x ', num2str(video.Height)]);
disp(['Anzahl Frames: ', num2str(video.NumFrames)]);
disp(['Framerate: ', num2str(video.FrameRate), ' fps']);
disp(['Pixel Format: ', num2str(video.BitsPerPixel), ' px']);

reconstructor = GeometryReconstructor(video, 50, 62, {"coveredDistance", 320, "translationVelocity", 3.2});

[nPixels, error] = reconstructor.calculateStretchFactor(reconstructor.voxelDimensions);
disp(reconstructor);

pre = ImageProcessor();
disp(pre);

figure;
% Frames einzeln auslesen und anzeigen
index = 0;

pixelDistanceX = 200;
pixelDistanceY = 100;

roiLimitsX = int32([pixelDistanceX+1, video.Width - pixelDistanceX]);
roiLimitsY = int32([video.Height/2-pixelDistanceY+1, video.Height/2]);


frameStack = zeros(roiLimitsY(2)-roiLimitsY(1)+1, roiLimitsX(2)-roiLimitsX(1)+1, video.NumFrames);


while hasFrame(video)

    % Einzelnen Frame lesen
    frame = readFrame(video);
    frame = frame(roiLimitsY(1):roiLimitsY(2),roiLimitsX(1):roiLimitsX(2),:);
    frame = rgb2gray(frame);

    frame = meanFilter(frame, 1);


    % mask = compareFrames(frame, previousFrame, 50);
    %
    % previousFrame = frame;

    % filteredFrame = double(frame) .* double(mask);

    % frame = imadjust(frame, [], [], 0.45);
    % frame = imadjust(frame, [], [], 2);

    % filteredFrame = mat2gray(filteredFrame);

    frameStack(:,:,end-index) = frame;
    index = index + 1;

    % Frame anzeigen
    frame = mat2gray(frame);
    imshow(frame);
    pause(1 / video.FrameRate); % Zeit für die Anzeige eines Frames (entspricht der Framerate des Videos)
end

modeA = "median";
modeB = "median ad";
axis = "depth";
projectionDepthA = pre.projectFrames(frameStack, modeA, axis);
projectionDepthB = pre.projectFrames(frameStack, modeB, axis);

projectionDepthA = pre.imageToGrayscale(projectionDepthA);
projectionDepthB = pre.imageToGrayscale(projectionDepthB);

axis = "height";
projectionHeightA = pre.projectFrames(frameStack, modeA, axis);
projectionHeightB = pre.projectFrames(frameStack, modeB, axis);

projectionHeightA = pre.imageToGrayscale(projectionHeightA);
projectionHeightB = pre.imageToGrayscale(projectionHeightB);

multiPlot(projectionDepthA, projectionDepthB, projectionHeightA, projectionHeightB);

shape = size(projectionHeightA.image);
shape(1) = shape(1) * nPixels;
stretchedProjection = imresize(projectionHeightA.image,[shape(1) shape(2)], "nearest");

%stretchedProjection = imresize(stretchedProjection, 0.5, "nearest");

figure("Name","Stretched Projection");
imshow(stretchedProjection)
% axis = "width";
% projectionMax = pre.projectFrames(frameStack, modeA, axis);
% projectionMin = pre.projectFrames(frameStack, modeB, axis);
%
% projectionMax = pre.imageToGrayscale(projectionMax);
% projectionMin = pre.imageToGrayscale(projectionMin);
%
% multiPlot(projectionMax, projectionMin);


% projectionMin =  ~imbinarize(projectionMin) %,'adaptive','ForegroundPolarity','dark','Sensitivity',0.4);
% frameProjection = frameProjection .* ~projectionMin;

% kernelSize = 3;
% iterations = 1;
%
% filterKernel = strel("square", kernelSize);
% filteredProjection = imopen(projectionDepthA, filterKernel);




function binaryMask = compareFrames(frame1, frame2, threshold)
% Vergleicht zwei Frames und erstellt eine binäre Maske basierend auf einem Schwellenwert.
%
% Eingabe:
%   frame1     - Der erste Frame (z. B. ein Graustufenbild)
%   frame2     - Der zweite Frame (z. B. ein Graustufenbild)
%   threshold  - Der Schwellenwert für die Abweichung (z. B. ein Wert zwischen 0 und 255)
%
% Ausgabe:
%   binaryMask - Eine binäre Maske, in der Pixel mit Abweichung > threshold mit 1 markiert sind.

% Überprüfen, ob die Frames die gleiche Größe haben
if ~isequal(size(frame1), size(frame2))
    error('Die beiden Frames müssen die gleiche Größe haben.');
end

% Berechne die absolute Differenz zwischen den beiden Frames
pixelDifference = abs(double(frame1) - double(frame2));

% Erstelle die binäre Maske basierend auf dem Schwellenwert
binaryMask = pixelDifference > threshold;
end



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



function outputImage = meanFilter(inputImage, n)

inputImage = double(inputImage);

meanValue = mean(inputImage, "all");
stdValue = std(inputImage, 0, "all");

threshold = meanValue - n * stdValue;

outputImage = inputImage;
outputImage(inputImage < threshold) = 0;
end