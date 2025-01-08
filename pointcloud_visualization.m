addpath('src\image_processing\');
addpath('src\visualization\');

showVideo = false;


videoFile = VideoFile("30_deg_view_A.avi");
videoFile.setROI(200, "width", "symmetrical"); % 200
videoFile.setROI(-100, "height", "from center");
% disp(videoFile);

pre = ImageProcessor();
% disp(pre);

reconstructor = GeometryReconstructor(videoFile, 50, 62, {"coveredDistance", 320, "translationVelocity", 3.2});
[nPixels, error] = reconstructor.calculateStretchFactor(reconstructor.voxelDimensions);
disp(reconstructor);

if showVideo
    videoWindow = figure("Name", "Video");
end

frameStack = videoFile.createFrameContainer(1);

%% Recording

while true
    try
        frame = videoFile.getFrame();
    catch ME
        break;
    end

    frameStruct = pre.asImageStruct(frame);
    frameStruct = pre.asGrayscale(frameStruct);

    % gamma correction: brighten (g < 1), darken (g > 1)
    % frameStruct.image = imadjust(frameStruct.image, [], [], 0.75);
    frameStruct.image = medfilt2(frameStruct.image, [15 15], "symmetric");
    
    % mean filtering
    frameStruct = pre.meanFilter(frameStruct, 0, "<=");

    % stretch filtered values to range 0 to 255 again
    frameStruct = pre.asGrayscale(frameStruct);

    % set zero values to nan
    frameStruct = pre.threshold(frameStruct, 0, "==");

    frameStack(:,:,end - videoFile.frameIndex + 1) = frameStruct.image;
    
    if showVideo
        % show filtered frame
        imshow(frameStruct.image);
        set(videoWindow, "Name", "Frame " + num2str(videoFile.frameIndex) + "/" + num2str(videoFile.nFrames));
        pause(1 / videoFile.frameRate);
    end
end

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
disp("")
fprintf("Width Min Max:\t%s\n", num2str([min(pointsXYZA(:,1), [], "all") max(pointsXYZA(:,1), [], "all")]));
fprintf("Height Min Max:\t%s\n", num2str([min(pointsXYZA(:,2), [], "all") max(pointsXYZA(:,2), [], "all")]));
fprintf("Depth Min Max:\t%s\n", num2str([min(pointsXYZA(:,3), [], "all") max(pointsXYZA(:,3), [], "all")]));
fprintf("Uncropped Size:\t%s\n", num2str(size(pointsXYZA)));
% width cropping
roiPointsXYZA = pointsXYZA(pointsXYZA(:,1) >= roiCoords(2,1), :);
roiPointsXYZA = roiPointsXYZA(roiPointsXYZA(:,1) <= roiCoords(2,2), :);
disp("")
fprintf("Width Min Max:\t%s\n", num2str([min(roiPointsXYZA(:,1), [], "all") max(roiPointsXYZA(:,1), [], "all")]));
fprintf("Height Min Max:\t%s\n", num2str([min(roiPointsXYZA(:,2), [], "all") max(roiPointsXYZA(:,2), [], "all")]));
fprintf("Depth Min Max:\t%s\n", num2str([min(roiPointsXYZA(:,3), [], "all") max(roiPointsXYZA(:,3), [], "all")]));
fprintf("Width Cropped Size:\t%s\n", num2str(size(roiPointsXYZA)));


% depth cropping
roiPointsXYZA = roiPointsXYZA(roiPointsXYZA(:,3) >= roiCoords(1,1), :);
roiPointsXYZA = roiPointsXYZA(roiPointsXYZA(:,3) <= roiCoords(1,2), :);
disp("")
fprintf("Width Min Max:\t%s\n", num2str([min(roiPointsXYZA(:,1), [], "all") max(roiPointsXYZA(:,1), [], "all")]));
fprintf("Height Min Max:\t%s\n", num2str([min(roiPointsXYZA(:,2), [], "all") max(roiPointsXYZA(:,2), [], "all")]));
fprintf("Depth Min Max:\t%s\n", num2str([min(roiPointsXYZA(:,3), [], "all") max(roiPointsXYZA(:,3), [], "all")]));
fprintf("Depth Cropped Size:\t%s\n", num2str(size(roiPointsXYZA)));
% grayscale thresholding
threshold = 0;
filteredPointsXYZA = roiPointsXYZA(roiPointsXYZA(:,4) > threshold, :);
fprintf("GS Thresholded Size:\t%s", num2str(size(filteredPointsXYZA)));
% filteredPoints = removeRandomPoints(filteredPoints, 99);
% size(filteredPoints)

sclaedPointsXYZA = reconstructor.scaleCoordGrid(filteredPointsXYZA);
stepSize = 1;
plotData(...
    sclaedPointsXYZA(1:stepSize:end,1), ... % X = width
    sclaedPointsXYZA(1:stepSize:end,3), ... % Y = depth
    sclaedPointsXYZA(1:stepSize:end,2) ... % Z = height (2), grayscale (4)
    );

pause;


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



function plotData(x, y, z)
    % Funktion zur Visualisierung von Daten aus bis zu drei Vektoren.
    % - Wenn z weggelassen wird, wird ein 2D-Plot erstellt.
    % - Wenn z angegeben wird, wird ein 3D-Plot erstellt.
    
    f = figure; % Neues Fenster für den Plot

    c = z;

    if nargin == 2
        % 2D Daten
        p = scatter(x, y, 'o-'); % Zeichnet einen 2D-Plot mit Linien und Punkten
        xlabel('X');
        ylabel('Y');
        title('2D Datenvisualisierung');
        grid on;
    elseif nargin == 3
        % 3D Daten
        p = scatter3(x, y, z, 8, z,"filled","o"); % Zeichnet einen 3D-Plot mit Linien und Punkten
        % p.Color = "blue";
        % p.Marker = ".";
        xlabel('X');
        ylabel('Y');
        zlabel('Z');
        title('3D Datenvisualisierung');
        colorbar;
        axis equal;
        grid on;
        rotate3d on; % Aktiviert die 3D-Rotation mit der Maus
    else
        error('Bitte entweder zwei oder drei Vektoren als Argumente übergeben.');
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