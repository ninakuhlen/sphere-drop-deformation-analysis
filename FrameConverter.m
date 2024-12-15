classdef FrameConverter
    properties
        brightnessThreshold
    end

    methods
        % Constructor
        function obj = FrameConverter(brightnessThreshold)
            obj.brightnessThreshold = brightnessThreshold;
        end

        % Kapselung der Konvertierungsmethoden
        function binarizedFrame = convert(obj, frameIndex, frame)
            grayFrame = obj.convertToGrayFrame(frame);
            binarizedFrame = obj.convertToBinaryFrame(frameIndex, grayFrame);
        end

        % Konvertierungs-Methoden
        function grayFrame = convertToGrayFrame(~, frame)
            if size(frame, 3) == 1
                grayFrame = frame;
                return;
            end
            if size(frame, 3) == 3
                grayFrame = rgb2gray(frame);
                return;
            end

            error('invalid amount of bands');
        end

        function binarizedFrameDto = convertToBinaryFrame(obj, frameIndex, grayFrame)
            binaryFrame = imbinarize(grayFrame, obj.brightnessThreshold / 255); % normalisierter Threshold
            binarizedFrameDto = BinarizedFrameDto(frameIndex, grayFrame, binaryFrame);
        end
    end
end
