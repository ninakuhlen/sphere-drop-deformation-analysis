classdef ImageProcessorV2 < handle
    properties (Access=private)
        logConversions logical = false;
        logFilters logical = false;
    end % private properties
    methods
        function obj = ImageProcessorV2()
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




    end % instance methods
    methods (Static)

        function setGamma(imageData, gamma)
            imageData.setData(imadjust(imageData.getData(), [], [], gamma));
        end % setGamma

        function medianFilter(imageData, kernelSize)
            imageData.setData(medfilt2(imageData.getData(), [kernelSize kernelSize], "symmetric"));
        end % medianFilter


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

            [imageHeight, imageWidth] = size(imageStruct.image);

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
            roiImageStruct = imageStruct;
            roiImageStruct.image = imageStruct.image(roiMinY:roiMaxY,roiMinX:roiMaxX);
            roiImageStruct.title = "ROI of " + roiImageStruct.title;

            close;

            % print function results in command window
            fprintf("\n\tResults:\n");
            fprintf("\t\t ROI Position:\t%s\n", num2str(rectanglePosition(1:2)));
            fprintf("\t\t ROI Shape:\t%s\n", num2str(rectanglePosition(3:4)));

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