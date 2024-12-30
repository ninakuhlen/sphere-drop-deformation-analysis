classdef ImageProcessor < handle
    properties (Access=private)
        logConversions logical = false;
        logFilters logical = false;
    end % private properties
    methods
        function obj = ImageProcessor()
        end % ImageProcessor

        function disp(obj)
            className = class(obj);
            fprintf('\n%s\n', className);

            % print all public properties
            fprintf('Properties:\n');
            objectProperties = properties(obj);
            for i = 1:length(objectProperties)
                fprintf("\t%s:\t%s\n", objectProperties{i}, mat2str(obj.(objectProperties{i})));
            end
            
            % get all methods
            allMethods = methods(obj);

            % get methods from superclass
            metaClass = meta.class.fromName(className);
            superClasses = metaClass.SuperclassList;
            inheritedMethods = {};
            for k = 1:length(superClasses)
                inheritedMethods = [inheritedMethods; methods(superClasses(k).Name)];
            end


            % print all public custom methods
            fprintf('Custom Methods:\n');
            customMethods = setdiff(allMethods, inheritedMethods);
            for i = 2:length(customMethods)
                fprintf('\t%s\n', customMethods{i});
            end

        end % disp

        %% Conversion Operations

        function imageStruct = asImageStruct(obj, image)
            imageStruct = struct("image", image, "title", "frame", "format", [], "xLabel", "image width", "yLabel", "image height");

            if ndims(image) == 3
                imageStruct.format = "multi channel";
            elseif ndims(image) == 2 && isinteger(image)
                imageStruct.format = "grayscale";
            elseif ndims(image) == 2 && isfloat(image)
                imageStruct.format = "normalized grayscale";
            end
        end % asImageStruct

        function grayscaleStruct = asGrayscale(obj, imageStruct)

            grayscaleStruct = imageStruct;
            image = grayscaleStruct.image;

            hasColor = false;
            if ndims(image) == 3
                image = rgb2gray(image);
                hasColor = true;
            end
            originalMin = double(min(image, [], "all"));
            originalMax = double(max(image, [], "all"));
            originalRange = [originalMin, originalMax];

            image(isnan(image)) = originalMin;

            grayscaleStruct.image = uint8(255 * mat2gray(image));

            grayscaleStruct.format = "grayscale";

            if obj.logConversions
                % display conversion information
                functionInfo = dbstack;
                fprintf('\n%s:\n', functionInfo(1).name);
                fprintf('\tInput Image:\t%s\n', inputname(2));
                fprintf('\tConversion from Color:\t%s\n', ImageProcessor.bool2str(hasColor));
                fprintf('\tOriginal Image Range:\t[%s]\n', num2str(originalRange));
                fprintf('\tGrayscale Image Range:\t[0 255]\n');
            end
        end % asGrayscale

        function colorStruct = asColor(obj, redStruct, greenStruct, blueStruct)

            colorStruct = redStruct;

            if nargin == 2
                colorStruct.image = cat(3, redStruct.image, redStruct.image, redStruct.image);
            elseif nargin == 3
                emptyChannel = zeros(size(redStruct.image));
                colorStruct.image = cat(3, redStruct.image, greenStruct.image, emptyChannel);
            elseif nargin == 4
                colorStruct.image = cat(3, redStruct.image, greenStruct.image, blueStruct.image);
            end

            colorStruct.image = uint8(colorStruct.image * 255);
            colorStruct.format = "rgb";

            if obj.logConversions
                % display conversion information
                functionInfo = dbstack;
                fprintf('\n%s:\n', functionInfo(1).name);
                for i = 2:nargin;
                    fprintf('\tInput Image Channel %s:\t%s\n', num2str(i-1), inputname(i));
                end
            end
        end % asColor

        %% Filter Operations

        function filteredStruct = threshold(obj, imageStruct, value, mode)
            filteredStruct = imageStruct;
            switch mode
                case "=="
                    filteredStruct.image(imageStruct.image == value) = NaN;
                case "<"
                    filteredStruct.image(imageStruct.image < value) = NaN;
                case "<="
                    filteredStruct.image(imageStruct.image <= value) = NaN;
                case ">"
                    filteredStruct.image(imageStruct.image > value) = NaN;
                case ">="
                    filteredStruct.image(imageStruct.image >= value) = NaN;
                otherwise
                    warning("Invalid mode selected!");
            end

            if obj.logFilters
                % display filter information
            end

        end % threshold

        function filteredStruct = meanFilter(obj, imageStruct, nSigma, mode)

            filteredStruct = imageStruct;
            filteredStruct.image = double(filteredStruct.image);

            meanValue = mean(filteredStruct.image, "all");
            stdValue = std(filteredStruct.image, 0, "all");

            threshold = meanValue + nSigma * stdValue;

            filteredStruct = obj.threshold(filteredStruct, threshold, mode);

            if obj.logFilters
                % diplay filter information
            end
        end % meanFilter


        function projection = projectFrames(obj, frameStack, mode, axis)
            axesMap = dictionary("height", 1, "width", 2, "depth", 3);

            oldSize = size(frameStack);

            switch mode
                case "sum"
                    image = sum(frameStack, axesMap(axis), "omitnan");
                case "max"
                    image = max(frameStack, [], axesMap(axis));
                case "min"
                    image = min(frameStack, [], axesMap(axis));
                case "mean"
                    image = mean(frameStack, axesMap(axis), "omitnan");
                case "mean dev"
                    image = std(frameStack, 0, axesMap(axis), "omitnan");
                case "median"
                    image = median(frameStack, axesMap(axis), "omitnan");
                case "median dev"
                    image = median(abs(frameStack - median(frameStack, axesMap(axis), "omitnan")), axesMap(axis), "omitnan");
                case "iqr"
                    image = iqr(frameStack, axesMap(axis));
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

            projection = obj.asImageStruct(image);
            projection.title = "projection (" + mode + " along " + axis + ")";
            projection.format = mode + " " + projection.format;
            projection.xLabel = xLabel;
            projection.yLabel = yLabel;

            newSize = size(projection.image);

            if obj.logConversions
                % display conversion information
                functionInfo = dbstack;
                fprintf('\n%s:\n', functionInfo(1).name);
                fprintf('\tInput Matrix:\t%s\n', inputname(2));
                fprintf('\tOperation Mode:\t%s\n', mode);
                fprintf('\tProjection along Axis:\t%s\n', axis);
                fprintf('\tInput Shape:\t[%s]\n', num2str(oldSize));
                fprintf('\tOutput Shape:\t[%s]\n', num2str(newSize));
            end

        end % projectFrames

    end % instance methods
    methods (Static)


        function stretchedImageStruct = stretchImage(imageStruct, axis, factor)

            axesMap = dictionary("height", 1, "width", 2);

            stretchedImageStruct = imageStruct;
            image = stretchedImageStruct.image;

            newShape = size(image);
            newShape(axesMap(axis)) = newShape(axesMap(axis)) * factor;
            stretchedImageStruct.image = imresize(image,newShape, "nearest"); %[newShape(1) newShape(2)]
            stretchedImageStruct.title = "Stretched " + stretchedImageStruct.title;

            % display function information
            functionInfo = dbstack;
            fprintf('\n%s:\n', functionInfo(1).name);
            fprintf('\tInput Image:\t%s\n', inputname(1));
            fprintf('\tOriginal Shape:\t%s\n', num2str(size(imageStruct.image)));
            fprintf('\tStretched Shape:\t[%s]\n', num2str(size(stretchedImageStruct.image)));
        end % stretchImage

        function [roiImageStruct, roi] = selectROI(imageStruct)
            figure("Name", "ROI Selection");
            imshow(imageStruct.image);
            title("Select ROI. Press Enter to confirm.");

            rectangle = drawrectangle('Label', 'ROI', 'Color', 'r');

            % print function instructions in command window
            functionInfo = dbstack;
            fprintf('\n%s:\n', functionInfo(1).name);
            fprintf("\t1) Drag a rectangle to select the region of interest.\n");
            fprintf("\t2) Press Enter to confirm.\n");

            pause;

            % get roi position
            rectanglePosition = round(rectangle.Position); % [x, y, width, height]
            roi = rectanglePosition;

            % create roi image struct and cut roi from input image
            roiImageStruct = imageStruct;
            xLimits = [roi(1), roi(1)+roi(3)];
            yLimits = [roi(2), roi(2)+roi(4)];
            roiImageStruct.image = imageStruct.image(yLimits(1):yLimits(2),xLimits(1):xLimits(2));

            roiImageStruct.title = "ROI of " + roiImageStruct.title;

            close;

            % print function results in command window
            fprintf("\n\tResults:\n");
            fprintf("\t\t ROI Position:\t%s\n", num2str(roi(1:2)));
            fprintf("\t\t ROI Shape:\t%s\n", num2str(roi(3:4)));

            % show roi image in new figure
            figure("Name", "ROI Display");
            title("Selected ROI. Press Enter to continue.");
            imshow(roiImageStruct.image);
            pause;
            close;

        end % selectROI

        function morphedImage = multiStepMorphing(binaryImage, kernelShape, kernelSize, mode, operation, figure, overlayImage)

            if nargin == 5 || nargin == 7

                morphedImage = binaryImage;

                switch mode
                    case "grow"
                        currentKernelSize = 3;
                        compare = @(x) x <= kernelSize;
                    case "shrink"
                        currentKernelSize = kernelSize;
                        compare = @(x) x >= 3;
                end

                iteration = 1;

                while compare(currentKernelSize)

                    % create kernel
                    filterKernel = strel(kernelShape, currentKernelSize);

                    switch operation
                        case "erode"
                            morphedImage = imerode(morphedImage, filterKernel);
                            channel = 1; % red for erosion
                        case "dilate"
                            morphedImage = imdilate(morphedImage, filterKernel);
                            channel = 2; % green for dilation
                        case "open" % erosion + dilation
                            morphedImage = imopen(morphedImage, filterKernel);
                            channel = 1; % red for opening
                        case "close" % dilation + erosion
                            morphedImage = imclose(morphedImage, filterKernel);
                            channel = 2; % green for closing
                    end

                    if nargin == 7

                        if ~isvalid(figure)
                            break;
                        end

                        % generate overlay image in red
                        originalOverlay = repmat(overlayImage, [1, 1, 3]);
                        overlay = uint8(originalOverlay);
                        overlay(:,:,channel) = uint8(morphedImage* 255);

                        % alpha blending with the original image
                        finalImage = uint8((double(originalOverlay) * 255 + double(overlay)) / 2);

                        % Ausgabe des Bildes
                        imshow(finalImage, 'Parent', axes('Parent', figure), "Border", "tight");
                        set(figure, "Name", "multiStepMorphing (" + operation + ") Iteration: " + num2str(iteration) + " (kernelSize " + num2str(currentKernelSize) + ")");
                    end

                    % change kernel size for next iteration
                    switch mode
                        case "grow"
                            currentKernelSize = currentKernelSize + 2;
                        case "shrink"
                            currentKernelSize = currentKernelSize - 2;
                    end

                    % increment the iteration counter
                    iteration = iteration + 1;

                    pause(0.25);
                end
            end
        end % multiStepMorphing

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