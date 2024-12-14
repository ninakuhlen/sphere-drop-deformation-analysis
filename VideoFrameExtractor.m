classdef VideoFrameExtractor
    properties(Access='private')
        % Abhängigkeiten dieser Klasse
        videoReader,
        frameConverter
    end

    methods
        % Konstruktor setzt Abhängigkeiten als properties
        function obj = VideoFrameExtractor(videoReader, frameConverter)
            obj.videoReader = videoReader; % Speichere videoReader als property
            obj.frameConverter = frameConverter;
        end

        % Frames extrahieren
        function frames = extractFrames(obj)
            fprintf('Start extracting frames...\n');
            frameAmount = floor(obj.videoReader.Duration * obj.videoReader.FrameRate);
            frames = cell(1, frameAmount);
            frameIndex = 1;

            while (hasFrame(obj.videoReader))
                frame = readFrame(obj.videoReader);
                frames{frameIndex} = obj.frameConverter.convert(frame); % Das aktuelle Frame wird in frames gespeichert
                frameIndex = frameIndex + 1; % Die dritte Dimension (frameIndex) gibt an, welches Frame gespeichert wird.
            end
            fprintf('Frame-Extraction completed. Amount of frames: %d\n', frameAmount);
        end
    end
end
