classdef FrameConverter
    properties
        brightnessThreshold
    end

    methods
        % Constructor
        function obj = FrameConverter(brightnessThreshold)
            obj.brightnessThreshold = brightnessThreshold;
        end

        function frame = convert(obj, frame)
            newFrame = obj.convertToGrayFrame(frame);
            newFrame = obj.convertToBinaryFrame(newFrame);

            frame = newFrame;
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

        function binaryFrame = convertToBinaryFrame(~, frame)
            binaryFrame = imbinarize(frame, "global");
        end

        function frame = gausFilter(~, frame)
            %thresholdValue = 200;
            %binaryMask = frame > thresholdValue;
            
            % Evtl. kleine Morphologische Operationen, um Lücken zu schließen
            binaryMask = imclose(frame, strel('line', 3, 0));
            frame = imfill(binaryMask, 'holes');
        end
    end
end
