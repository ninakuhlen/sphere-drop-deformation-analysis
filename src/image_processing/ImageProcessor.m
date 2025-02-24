classdef ImageProcessor < handle
    properties (Access=private)
        oldImage
        newImage
    end % private properties
    methods
        function obj = ImageProcessor()
            
        end % ImageProcessor

        function show(obj, mode)
            switch nargin
                case 1
                    mode = "diff";
                case 2
                    mode = lower(mode);
            end

            switch mode
                case "falsecolor"
                    imshowpair(obj.oldImage, obj.newImage, "falsecolor", "ColorChannels", "green-magenta");
                otherwise
                    imshowpair(obj.oldImage, obj.newImage, mode)
            end
        end % show

        function disp(obj)
            className = class(obj);
            fprintf("\n%s\n", className);

            % print all public properties
            fprintf("Properties:\n");
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
            fprintf("Custom Methods:\n");
            customMethods = setdiff(allMethods, inheritedMethods);
            for i = 2:length(customMethods)
                fprintf("\t%s\n", customMethods{i});
            end

        end % disp

    end % methods

    methods (Static)

        function setGamma(imageData, gamma)
            oldImage = imageData.getData();
            newImage = imadjust(oldImage, [], [], gamma);

            
            imageData.setData(imadjust(imageData.getData(), [], [], gamma));
            imageData.appendLog(string(sprintf("Gamma correction with gamma = %0.2f", gamma)));
        end % setGamma

        function medianFilter(imageData, kernelSize, nIterations)
            assert((mod(kernelSize,2)~=0), "Expected odd kernel size!");

            switch nargin
                case 2
                    nIterations = 1;
                case 3
                    % use number of iterations given
            end

            for i = 1:nIterations
                imageData.setData(medfilt2(imageData.getData(), [kernelSize kernelSize], "symmetric"));
                imageData.appendLog(string(sprintf("Median blurred with kernel size %d x %d pixels.", kernelSize, kernelSize)));
            end
        end % medianFilter

        function gaussianFilter(imageData, sigma, kernelSize, nIterations)
            assert((mod(kernelSize,2)~=0), "Expected odd kernel size!");

            switch nargin
                case 3
                    nIterations = 1;
                case 4
                    % use number of iterations given
            end
            
            for i = 1:nIterations
                imageData.setData(imgaussfilt(imageData.getData(), sigma, "FilterSize", kernelSize, "Padding", "symmetric"));
                imageData.appendLog(string(sprintf("Gaussian blurred with sigma %0.2f and kernel size %d x %d pixels.", sigma, kernelSize, kernelSize)));
            end
        end % gaussianFilter

        function threshold(imageData, value, mode)
            mode = string(mode);
            image = double(imageData.getData());
            switch mode
                case "=="
                    image(image == value) = NaN;
                case "<"
                    image(image < value) = NaN;
                case "<="
                    image(image <= value) = NaN;
                case ">"
                    image(image > value) = NaN;
                case ">="
                    image(image >= value) = NaN;
                otherwise
                    warning("Invalid mode selected!");
            end

            imageData.setData(image);
            imageData.appendLog(string(sprintf("Discard values %s %0.2f.", mode, value)));

        end % threshold

        function meanThreshold(imageData, nSigma, mode)
            image = double(imageData.getData());
            image(image == 0) = NaN;

            meanValue = mean(double(image), "all", "omitnan");
            stdValue = std(double(image), 0, "all", "omitnan");

            threshold = meanValue + nSigma * stdValue;

            ImageProcessor.threshold(imageData, threshold, mode);

        end % meanFilter

        function threshold = binarize(imageData, threshold)
            image = double(imageData.getData());
            switch nargin
                case 1
                    threshold = graythresh(image);
                case 2
                    if isinteger(threshold)
                        threshold = threshold / 255;
                    else
                        % use given threshold
                    end
            end
            binaryImage = imbinarize(image, threshold);
            imageData.setData(binaryImage);

            threshold = uint8(threshold * 255);
        end % binarize

        function normalize(imageData, nBits)
            image = double(imageData.getData());
            image(image == 0) = NaN;
            normalizedImage = zeros(size(image), "like", image);

            for c = 1:size(normalizedImage, 3)
                minValue = min(image, [], "all", "omitnan");
                maxValue = max(image, [], "all", "omitnan");

                if minValue == maxValue
                    normalizedImage(:, :, c) = zeros(size(image, 1), size(image, 2), "like", image);
                else
                    normalizedImage(:, :, c) = 2^nBits * (image(:, :, c) - minValue) / (maxValue - minValue);
                end
            end

            if nBits <= 8
                normalizedImage = uint8(normalizedImage);
            elseif nBits <= 16
                normalizedImage = uint16(normalizedImage);
            elseif nBits <= 32
                normalizedImage = uint32(normalizedImage);
            elseif nBits <= 64
                normalizedImage = uint64(normalizedImage);
            end

            imageData.setData(normalizedImage);
            imageData.appendLog(string(sprintf("Normalized image to %d bits.", nBits)));
        end % normalize


        function stretchedImageData = stretchImage(imageData, axis, factor)

            axesMap = dictionary("height", 1, "width", 2);

            stretchedImageData = copy(imageData);
            image = stretchedImageData.getData;

            newShape = size(image);
            newShape(axesMap(axis)) = newShape(axesMap(axis)) * factor;
            stretchedImageData.setData(imresize(image, newShape, "nearest"));
            stretchedImageData.title = "Stretched " + stretchedImageData.title;

            % display function information
            functionInfo = dbstack;
            fprintf('\n%s:\n', functionInfo(1).name);
            fprintf('\tInput Image:\t%s\n', inputname(1));
            fprintf('\tOriginal Shape:\t[%s]\n', num2str(size(imageData.getData())));
            fprintf('\tStretched Shape:\t[%s]\n', num2str(size(stretchedImageData.getData())));
        end % stretchImage

        function [roiImageData, roi] = selectROI(imageData)

            image = imageData.getData();
            figure("Name", "ROI Selection");
            imshow(image);
            title("Select ROI. Press Enter to confirm.");

            rectangle = drawrectangle('Label', 'ROI', 'Color', 'r');

            % print function instructions in command window
            functionInfo = dbstack;
            fprintf('\n%s:\n', functionInfo(1).name);
            fprintf("\t1) Drag a rectangle to select the region of interest.\n");
            fprintf("\t2) Press Enter to confirm.\n");

            pause;

            [imageHeight, imageWidth] = size(image);

            % get roi position
            rectanglePosition = round(rectangle.Position); % [x, y, width, height]

            % solveses a rare 'index out of bounds' error
            roiMinX = max([rectanglePosition(1), 1]);
            roiMinY = max([rectanglePosition(2), 1]);
            roiMaxX = min([imageWidth, rectanglePosition(1)+rectanglePosition(3)]);
            roiMaxY = min([imageHeight, rectanglePosition(2)+rectanglePosition(4)]);

            % pack results for output
            roi = [roiMinY, roiMaxY; roiMinX, roiMaxX];

            % create new imageStruct to return resulting roi image
            roiImageData = imageData;
            roiImageData.setData(image(roiMinY:roiMaxY,roiMinX:roiMaxX));
            roiImageData.title = "ROI of " + imageData.title;

            close;

            % print function results in command window
            fprintf("\n\tResults:\n");
            fprintf("\t\t ROI Position:\t%s\n", num2str(rectanglePosition(1:2)));
            fprintf("\t\t ROI Shape:\t%s\n", num2str(rectanglePosition(3:4)));

            % show roi image in new figure
            figure("Name", "ROI Display");
            title("Selected ROI. Press Enter to continue.");
            imshow(roiImageData.getData());
            pause;
            close;

        end % selectROI

        function morphedImageData = multiStepMorphing(binaryImageData, kernelSize, kernelShape, mode, operation, overlayImageData)

            assert(islogical(binaryImageData.getData()), "Image given is not binary!");
            assert((mod(kernelSize,2)~=0), "Expected odd kernel size!");

            mode = string(mode);
            operation = string(operation);

            morphedImageData = copy(binaryImageData);

            image = morphedImageData.getData();
            overlayImage = overlayImageData.getData();

            switch mode
                case "Grow"
                    currentKernelSize = 3;
                    compare = @(x) x <= kernelSize;
                    resizeKernel = @(x) x + 2;
                case "Shrink"
                    currentKernelSize = kernelSize;
                    compare = @(x) x >= 3;
                    resizeKernel = @(x) x - 2;
            end

            iteration = 1;

            while compare(currentKernelSize)

                % create kernel
                filterKernel = strel(lower(kernelShape), currentKernelSize);

                switch operation
                    case "Erode"
                        image = imerode(image, filterKernel);
                    case "Dilate"
                        image = imdilate(image, filterKernel);
                    case "Open" % erosion + dilation
                        image = imopen(image, filterKernel);
                    case "Close" % dilation + erosion
                        image = imclose(image, filterKernel);
                end

                imshowpair(image, overlayImage, "falsecolor", "ColorChannels", "green-magenta") %[1 2 1]);

                % change kernel size for next iteration
                currentKernelSize = resizeKernel(currentKernelSize);

                % increment the iteration counter
                iteration = iteration + 1;

                % short pause for better visualization
                pause(0.25);
            end
            
            % return morphed image
            morphedImageData.setData(image);
            morphedImageData.appendLog("Mophed image " + lower(mode) + "ing a " ...
                + lower(kernelShape) + " kernel of size " + kernelSize + " " ...
                + iteration + " times with operation '" + operation + "'.");
        end % multiStepMorphing

    end % static methods

    methods (Static, Access = private)

        function str = bool2str(x)
            if x
                str = "true";
            else
                str = "false";
            end
        end % bool2str

    end % private static methods
end % classdef