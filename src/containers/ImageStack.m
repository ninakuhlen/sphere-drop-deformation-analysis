classdef ImageStack < handle
    properties (Access = private)
        data
    end % private properties

    properties
        size
        title string = "Image";
        format string;
        xLabel string = "Width";
        yLabel string = "Height";
    end % public properties

    methods
        function obj = ImageStack(stackData)
            obj.data = stackData;

            obj.size = size(stackData);

            switch ndims(stackData)
                case 3
                    if isinteger(stackData)
                        obj.format = "Grayscale";
                    elseif isfloat(stackData)
                        obj.format = "Normalized Grayscale";
                    end
                case 4
                    switch size(stackData, 3)
                        case 2
                            obj.format = "dual channel";
                        case 3
                            obj.format = "RGB";
                        otherwise
                            obj.format = "Multispectral";
                    end
            end
        end % ImageStack

        function data = getData(obj)
            data = obj.data;
        end % getData

        function setData(obj, newImageData, index)
            switch nargin
                case 2
                    obj.data = newImageData.getData();
                case 3
                    dims = ndims(obj.data);
                    indices = repmat({':'}, 1, dims);
                    indices{end} = index;
                    obj.data(indices{:}) = newImageData.getData();
            end
        end % setData

        function projectionImageData = project(obj, mode, axis)
            axesMap = dictionary("Height", 1, "Width", 2, "Depth", 3);

            switch mode
                case "Sum"
                    image = sum(obj.data, axesMap(axis), "omitnan");
                case "Max"
                    image = max(obj.data, [], axesMap(axis), "omitnan");
                case "Min"
                    image = min(obj.data, [], axesMap(axis), "omitnan");
                case "Mean"
                    image = mean(obj.data, axesMap(axis), "omitnan");
                case "Mean Dev"
                    image = std(obj.data, 0, axesMap(axis), "omitnan");
                case "Median"
                    image = median(obj.data, axesMap(axis), "omitnan");
                case "Median Dev"
                    image = median(abs(obj.data - median(obj.data, axesMap(axis), "omitnan")), axesMap(axis), "omitnan");
                case "IQR"
                    image = iqr(frameStack, axesMap(axis));
            end

            switch axis
                case "Height"
                    projectionImageData = ImageData(permute(image, [3 2 1]));
                    projectionImageData.xLabel = "Width";
                    projectionImageData.yLabel = "Frame";
                case "Width"
                    projectionImageData = ImageData(permute(image, [3 1 2]));
                    projectionImageData.xLabel = "Height";
                    projectionImageData.yLabel = "Frame";
                case "Depth"
                    projectionImageData = ImageData(image);
                    projectionImageData.xLabel = "Width";
                    projectionImageData.yLabel = "Height";
            end

            projectionImageData.title = "projection (" + mode + " along " + axis + ")";
        end % projectFrames

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

    end % public methods

    methods (Static)
        function imageStack = fromVideo(videoFile, mode)

            switch nargin
                case 1
                    mode = "Filled";
            end

            stackDims = videoFile.resolution;
            stackDims(end + 1) = videoFile.nFrames;

            switch mode
                case "Empty"
                    imageStack = ImageStack(zeros(stackDims));
                case "Filled"
                    imageStack = ImageStack(zeros(stackDims));
                    index = 0;
                    while true
                        try
                            frame = videoFile.getFrame();
                            frame = ImageData(frame);
                            index = index + 1;
                        catch ME
                            break;
                        end
                        imageStack.setData(frame, index);
                    end
            end

        end % fromVideo
    end % static methods

end % classdef