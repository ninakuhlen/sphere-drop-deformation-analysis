classdef ImageProcessor < handle
    properties
    end % public properties
    methods
        function obj = ImageProcessor()
        end % ImageProcessor
    end % methods
    methods (Static)

        function imageStruct = asImageStruct(image)
            if ismatrix(image)
                imageStruct = struct("image", image, "title", "frame", "format", [], "xLabel", "image width", "yLabel", "image height");

                if ndims(image) == 3
                    imageStruct.format = "multi channel";
                elseif ndims(image) == 2 && isinteger(image)
                    imageStruct.format = "grayscale";
                elseif ndims(image) == 2 && isfloat(image)
                    imageStruct.format = "normalized grayscale";
                end
            end
        end % asImageStruct

        function projection = projectFrames(frameStack, mode, axis)
            axesMap = dictionary("height", 1, "width", 2, "depth", 3);

            oldSize = size(frameStack);

            switch mode
                case "sum"
                    image = sum(frameStack, axesMap(axis));
                case "max"
                    image = max(frameStack, [], axesMap(axis));
                case "min"
                    image = min(frameStack, [], axesMap(axis));
                case "mean"
                    image = mean(frameStack, axesMap(axis));
                case "std"
                    image = std(frameStack, 0, axesMap(axis));
                case "median"
                    image = median(frameStack, axesMap(axis));
                case "iqr"
                    image = iqr(frameStack, axesMap(axis));
                case "mean ad"
                    image = mad(frameStack, 0, axesMap(axis));
                case "median ad"
                    image = mad(frameStack, 1, axesMap(axis));
            end

            switch axis
                case "height"
                    image = permute(image, [3 2 1]);
                    xLabel = "width";
                    yLabel = "frame";
                case "width"
                    image = permute(image, [3 1 2]);
                    xLabel = "height";
                    yLabel = "frame";
                case "depth"
                    % no dimension swap necessary
                    xLabel = "width";
                    yLabel = "height";
            end

            projection = ImageProcessor.asImageStruct(image);
            projection.title = "projection: " + mode + " along " + axis;
            projection.xLabel = xLabel;
            projection.yLabel = yLabel;

            newSize = size(projection.image);

            % display conversion information
            functionInfo = dbstack;
            fprintf('\n%s:\n', functionInfo(1).name);
            fprintf('\tInput Matrix:\t%s\n', inputname(1));
            fprintf('\tOperation Mode:\t%s\n', mode);
            fprintf('\tProjection along Axis:\t%s\n', axis);
            fprintf('\tInput Shape:\t[%s]\n', num2str(oldSize));
            fprintf('\tOutput Shape:\t[%s]\n', num2str(newSize));

        end % projectFrames

        function imageStruct = imageToGrayscale(imageStruct)

            image = imageStruct.image;

            hasColor = false;
            if ndims(image) == 3
                image = rgb2gray(image);
                hasColor = true;
            end
            originalMin = double(min(image(:)));
            originalMax = double(max(image(:)));
            originalRange = [originalMin, originalMax];

            if originalMin < 0 || originalMax > 1
                imageStruct.image = mat2gray(image);
            end

            imageStruct.format = "normalized grayscale";

            % display conversion information
            functionInfo = dbstack;
            fprintf('\n%s:\n', functionInfo(1).name);
            fprintf('\tInput Image:\t%s\n', inputname(1));
            fprintf('\tConversion from Color:\t%s\n', ImageProcessor.bool2str(hasColor));
            fprintf('\tOriginal Image Range:\t[%s]\n', num2str(originalRange));
            fprintf('\tGrayscale Image Range:\t[0 1]\n');
        end % imageToGrayscale

        function scaledImage = scaleImage(image, axis, varargin)

            parser = inputParser;
            axesMap = dictionary("height", 1, "width", 2, "all", 3);
        end

    end % static methods

    methods (Static, Access = private)

        function str = bool2str(x)
            if x
                str='true';
            else
                str='false';
            end
        end % bool2str
    end % private static methods
end % classdef