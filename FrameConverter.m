classdef FrameConverter
    properties
        brightnessThreshold
    end

    methods
        function obj = FrameConverter(brightnessThreshold)
            obj.brightnessThreshold = brightnessThreshold;
        end

        function binarizedFrame = convert(obj, frame)
            grayFrame = obj.convertToGrayFrame(frame);
            binarizedFrame = obj.convertToBinaryFrame(grayFrame);
        end

        function grayFrame = convertToGrayFrame(obj, rgbFrame)
            if size(rgbFrame, 3) == 3
                grayFrame = rgb2gray(rgbFrame);
                return;
            end

            % Alle anderen Kanäle ignorieren
            grayFrame = rgbFrame;
        end

        function binarizedFrame = convertToBinaryFrame(obj, grayFrame)
            pixelValueMatrix = imbinarize(grayFrame, obj.brightnessThreshold / 255);
            binarizedFrame = BinarizedFrame(grayFrame, pixelValueMatrix);
        end
    end
end
