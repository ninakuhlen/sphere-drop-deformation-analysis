classdef FrameInspector
    properties
        binarizedFrame
    end

    methods
        function obj = FrameInspector(binarizedFrame)
            obj.binarizedFrame = binarizedFrame;
        end

        % Zeigt die Dimensionen der 3D-Matrix an. Höhe und Breite sind
        % Anzahl der Pixel
        function displayFrameResolution(obj)
            originalFrame = getOriginalFrame(obj.binarizedFrame);
            matrixSize = size(originalFrame);
            disp('Matrix dimensions:');
            disp(['Height (rows): ', num2str(matrixSize(1))]);
            disp(['Width (columns): ', num2str(matrixSize(2))]);
            disp(['Number of bands: ', num2str(matrixSize(3))]);
            disp(['Number of Frames: ', num2str(matrixSize(4))]);
        end

        % Zeigt ein bestimmtes Frame aus der 3D-Matrix als Bild an
        function displayFrame(obj)
            originalFrame = getOriginalFrame(obj.binarizedFrame);
            binaryFrame = getBinaryFrame(obj.binarizedFrame);
            frameIndex = getFrameIndex(obj.binarizedFrame);
            % frameMatrix: 3D-Matrix mit Frames
            % frameIndex: Index des Frames, das angezeigt werden soll
            figure;
            imshow(originalFrame);
            title(['Frame ', num2str(frameIndex)]);

            figure;
            imshow(binaryFrame);
            title(['Frame ', num2str(frameIndex)]);
        end

        % Gibt die Pixelwerte (Helligkeit) eines bestimmten Frames aus
        % 0 = schwarz, 255 = weiß
        function displayBinaryFrame(obj)
            % frameMatrix: 3D-Matrix mit Frames
            % frameIndex: Index des Frames, dessen Werte angezeigt werden sollen
            binaryFrame = getBinaryFrame(obj.binarizedFrame);
            frameIndex = getFrameIndex(obj.binarizedFrame);
            disp(['Pixel values for frame ', num2str(frameIndex), ':']);
            disp(frameMatrix); % Zeigt die Pixelwerte
        end

        % Zeigt einen bestimmten Ausschnitt eines Frames an
        function displayFrameRegion(rowRange, colRange)
            % frameMatrix: 3D-Matrix mit Frames
            % frameIndex: Index des Frames
            % rowRange: Bereich der Zeilen (z.B., 1:100)
            % colRange: Bereich der Spalten (z.B., 1:100)
            if frameIndex > size(frameMatrix, 4)
                error('Frame index exceeds the total number of frames.');
            end
            if max(rowRange) > size(frameMatrix, 1) || max(colRange) > size(frameMatrix, 2)
                error('Row or column range exceeds frame dimensions.');
            end
            figure;
            imshow(frameMatrix(rowRange, colRange, frameIndex)); % Zeigt den Ausschnitt
            title(['Frame ', num2str(frameIndex), ' Region']); % Titel mit Frame-Nummer
        end
    end
end
