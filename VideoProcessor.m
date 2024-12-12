classdef VideoProcessor
    properties
        video % Videodatei
        extractedFrames % 3D-Matrix mit extrahierten Frames
    end

    methods
        % Konstruktor zum Laden des Videos
        function obj = VideoProcessor(videoPath)
            fprintf('Loading video out of path: %s\n', videoPath);
            if ~isfile(videoPath)
                error('File does not exist: %s', videoPath);
            end
            obj.video = VideoReader(videoPath);
            fprintf('Video loading successful: %s\n', videoPath);
        end

        % Frames extrahieren
        function obj = extractFrames(obj)
            fprintf('Start extracting frames...\n');
            frames = []; % 3D-Matrix: Höhe, Breite, FrameIndex (Zeitachse)
            frameIndex = 1;

            while hasFrame(obj.video)
                %fprintf('read frame %d...\n', frameIndex);
                frame = readFrame(obj.video);
                fprintf('data type of frame before transformation:\n');
                disp(class(frame)); % Gibt den Datentyp des Frames aus
                if size(frame, 3) == 3
                    %fprintf('Convert Frame %d to greyscale...\n', frameIndex);
                    frame = rgb2gray(frame); % In Graustufen umwandeln
                end
                frames(:, :, frameIndex) = frame; % Das aktuelle Frame wird als 2D-Matrix in der temporären 3D-Matrix frames gespeichert
                frameIndex = frameIndex + 1; % Die dritte Dimension (frameIndex) gibt an, welches Frame gespeichert wird.
                fprintf('data type of frame after transformation:\n');
                disp(class(frame)); % Gibt den Datentyp nach Graustufen-Konvertierung aus
            end

            % Speichert die extrahierten Frames in der Eigenschaft "extractedFrames"
            obj.extractedFrames = frames;
            fprintf('Frame-Extraction completed. Amount of frames: %d\n', frameIndex - 1);
        end

        function obj = showFrame(frame)
            imshow(obj.extractedFrames(:,:,frame));
        end
    end
end
