% MATLAB Script for Detecting Dimples on a Surface
% Based on the Reflection of a Line Light Source in the Dimples


% % Capture a snapshot using the camera
% % This assumes the camera is properly configured and connected
% camera = videoinput('gentl', 1); % Replace 'gentl' and ID if different
% snapshot = getsnapshot(camera);
% imwrite(snapshot, 'captured_image.jpg'); % Save snapshot for reference
% testImage = snapshot;

% % Load the test image
testImage = imread('Snapshots_Video/hell.png');

% Convert to grayscale if it's an RGB image
if size(testImage, 3) == 3
    testImage = rgb2gray(testImage);
end
% show testImage
figure;
imshow(testImage);
title('Original Test Image');
disp(size(testImage)); % Gibt die Dimensionen des Bildes aus
disp(class(testImage)); % Gibt den Datentyp des Bildes aus


% Apply brightness threshold 1
% Highlights bright reflections of the line light
brightnessThreshold1 = 200; % Threshold value (0 to 255)
binaryReflectionImage1 = testImage > brightnessThreshold1;
figure;
imshow(binaryReflectionImage1);
title('1: Binary Image (Bright Reflections)');

% Apply brightness threshold 2
% Highlights bright reflections of the line light
brightnessThreshold2 = 100; % Threshold value (0 to 255)
binaryReflectionImage2 = testImage > brightnessThreshold2;
figure;
imshow(binaryReflectionImage2);
title('2: Binary Image (Bright Reflections)');

% Apply brightness threshold 3
% Highlights bright reflections of the line light
brightnessThreshold3 = 50; % Threshold value (0 to 255)
binaryReflectionImage3 = testImage > brightnessThreshold3;
figure;
imshow(binaryReflectionImage3);
title('3: Binary Image (Bright Reflections)');

% % Perform morphological operations
% % Clean up small artifacts and refine the reflection region
% binaryReflectionImage = bwareaopen(binaryReflectionImage, 50); % Remove small noise
% structuringElement = strel('rectangle', [5, 20]); % Define shape for cleaning
% binaryReflectionImage = imdilate(binaryReflectionImage, structuringElement); % Enhance reflection area
% figure;
% imshow(binaryReflectionImage);
% title('Processed Binary Image (Reflection Region)');
% 
% % Measure the reflection region
% % Analyze the properties of the bright reflection area
% reflectionStats = regionprops(binaryReflectionImage, 'BoundingBox', 'Area', 'MajorAxisLength', 'MinorAxisLength');
% 
% % Visualize detected dimple centroids
% figure;
% imshow(testImage);
% hold on;
% title('Measured Reflection Region');
% if ~isempty(reflectionStats)
%     boundingBox = reflectionStats(1).BoundingBox; % Get the bounding box of the reflection
%     rectangle('Position', boundingBox, 'EdgeColor', 'r', 'LineWidth', 2); % Draw the bounding box
%     text(boundingBox(1), boundingBox(2) - 10, sprintf('Area: %.2f', reflectionStats(1).Area), ...
%          'Color', 'yellow', 'FontSize', 12, 'FontWeight', 'bold');
%     text(boundingBox(1), boundingBox(2) + 10, sprintf('Major Axis: %.2f', reflectionStats(1).MajorAxisLength), ...
%          'Color', 'yellow', 'FontSize', 12, 'FontWeight', 'bold');
%     text(boundingBox(1), boundingBox(2) + 30, sprintf('Minor Axis: %.2f', reflectionStats(1).MinorAxisLength), ...
%          'Color', 'yellow', 'FontSize', 12, 'FontWeight', 'bold');
% else
%     disp('No reflection region detected.');
% end
% hold off;
% 
% % Output measurements
% if ~isempty(reflectionStats)
%     fprintf('Reflection Area: %.2f pixels\n', reflectionStats(1).Area);
%     fprintf('Major Axis Length: %.2f pixels\n', reflectionStats(1).MajorAxisLength);
%     fprintf('Minor Axis Length: %.2f pixels\n', reflectionStats(1).MinorAxisLength);
% else
%     disp('No reflection region detected in the image.');
% end