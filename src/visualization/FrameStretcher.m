classdef FrameStretcher
    properties
        traversedCameraDistance % Physikalische Distanz, die die Kamera zurücklegt (in mm)
        fieldOfViewWidth        % Sichtfeldbreite der Kamera (in mm)
    end

    methods
        function obj = FrameStretcher(traversedCameraDistance, fieldOfViewWidth)
            % Konstruktor: Initialisiert die Eigenschaften
            obj.traversedCameraDistance = traversedCameraDistance;
            obj.fieldOfViewWidth = fieldOfViewWidth;
        end

        function sideProjection = stretchAndProject(obj, video, roi)
            % Extrahiere wichtige Videoeigenschaften
            frameHeight = video.resolutionY; % Höhe des Videos (Pixel)
            frameWidth = video.resolutionX;  % Breite des Videos (Pixel)
            nFrames = video.nFrames;         % Anzahl der Frames
            
            % Zielanzahl der interpolierten Frames (gestreckte Tiefe)
            pixelsPerMM = frameWidth / obj.fieldOfViewWidth;
            desiredDepth = round(obj.traversedCameraDistance * pixelsPerMM);
            
            % Frame-Stapel mit Frames von 340 bis 550
            startFrame = 340;
            endFrame = 550;
            frameStack = video.frameStack(:, :, startFrame:endFrame);
        
            % ROI anwenden
            frameStackROI = roi.apply(frameStack);

            % Debug: Originalgröße des ROI
            disp('Original ROI Größe:');
            disp(size(frameStackROI));
        
            % Streckung des reduzierten Frame-Stapels mit imresize3
            [roiHeight, roiWidth, ~] = size(frameStackROI);
            stretchedFrameStack = imresize3(frameStackROI, [roiHeight, roiWidth, desiredDepth]);
        
            % Berechne die seitliche Projektion durch Summieren der Höhe
            sideProjection = squeeze(sum(stretchedFrameStack, 1)); % Dimension: (roiWidth x desiredDepth)
        end
    end
end
