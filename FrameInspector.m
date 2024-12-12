classdef FrameInspector
    methods (Static)
        % Zeigt die Dimensionen der 3D-Matrix an. Höhe und Breite sind
        % Anzahl der Pixel
        function displayFrameResolution(frameMatrix)
            matrixSize = size(frameMatrix);
            disp('Matrix dimensions:');
            disp(['Height (rows): ', num2str(matrixSize(1))]);
            disp(['Width (columns): ', num2str(matrixSize(2))]);
            disp(['Number of frames: ', num2str(matrixSize(3))]);
        end

        % Zeigt ein bestimmtes Frame aus der 3D-Matrix als Bild an
        function displayFrame(frameMatrix, frameIndex)
            % frameMatrix: 3D-Matrix mit Frames
            % frameIndex: Index des Frames, das angezeigt werden soll
            if frameIndex > size(frameMatrix, 3)
                error('Frame index exceeds the total number of frames.');
            end
            figure;
            imshow(frameMatrix(:, :, frameIndex)); % Zeigt das Frame
            title(['Frame ', num2str(frameIndex)]); % Zeigt die Frame-Nummer
        end

        % Gibt die Pixelwerte (Helligkeit) eines bestimmten Frames aus
        % 0 = schwarz, 255 = weiß
        function displayPixelValues(frameMatrix, frameIndex)
            % frameMatrix: 3D-Matrix mit Frames
            % frameIndex: Index des Frames, dessen Werte angezeigt werden sollen
            if frameIndex > size(frameMatrix, 3)
                error('Frame index exceeds the total number of frames.');
            end
            disp(['Pixel values for frame ', num2str(frameIndex), ':']);
            disp(frameMatrix(:, :, frameIndex)); % Zeigt die Pixelwerte
        end

        % Zeigt einen bestimmten Ausschnitt eines Frames an
        function displayFrameRegion(frameMatrix, frameIndex, rowRange, colRange)
            % frameMatrix: 3D-Matrix mit Frames
            % frameIndex: Index des Frames
            % rowRange: Bereich der Zeilen (z.B., 1:100)
            % colRange: Bereich der Spalten (z.B., 1:100)
            if frameIndex > size(frameMatrix, 3)
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
