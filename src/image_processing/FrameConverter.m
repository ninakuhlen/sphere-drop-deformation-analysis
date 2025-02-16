classdef FrameConverter
    properties
        brightnessThreshold
    end

    methods
        % Constructor
        function obj = FrameConverter(brightnessThreshold)
            obj.brightnessThreshold = brightnessThreshold;
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
    end
end
