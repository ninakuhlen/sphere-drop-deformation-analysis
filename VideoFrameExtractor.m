classdef VideoFrameExtractor
    properties(Access='private')
        % Abhängigkeiten dieser Klasse
        videoReader,
        frameConverter
    end

    methods
        % Konstruktor setzt Abhängigkeiten als properties, hier werden alle
        % Klassen eingefügt, die von dieser Klasse verwendet werden
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
                binarizedFrameDto = obj.frameConverter.convert(frameIndex, frame);
                frames{frameIndex} = binarizedFrameDto;  % Das aktuelle Frame wird konvertiert und in frames[] an der Position frameIndex gespeichert
                frameIndex = frameIndex + 1;
            end
            fprintf('Frame-Extraction completed. Amount of frames: %d\n', frameAmount);
        end
    end
end
