classdef VideoFrameExtractor
    properties(Access='private')
        % Abhängigkeiten dieser Klasse
        videoReader (1,1) VideoReader
    end

    methods
        % Konstruktor setzt Abhängigkeiten als properties
        function obj = VideoFrameExtractor(videoReader)
            obj.videoReader = videoReader; % Speichere videoReader als property
        end

        % Frames extrahieren
        function [obj, frames] = extractFrames(obj)
            video = obj.videoReader.read();
            fprintf('Start extracting frames...\n');
            frames = zeros(video.Height, video.Width, video.Duration * video.FrameRate); % 3D-Matrix: Höhe, Breite, Frame Anzahl
            frameIndex = 1;

            while (video.hasFrame())
                frame = video.readFrame();
                frames(:, :, frameIndex) = frame; % Das aktuelle Frame wird als 2D-Matrix in der temporären 3D-Matrix frames gespeichert
                frameIndex = frameIndex + 1; % Die dritte Dimension (frameIndex) gibt an, welches Frame gespeichert wird.
            end
            fprintf('Frame-Extraction completed. Amount of frames: %d\n', frameIndex - 1);
        end
    end
end
