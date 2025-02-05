classdef ImageData < handle
    properties (Access=private)
        data
    end % private properties
    properties
        title string = "Image";
        format string;
        xLabel string = "Width";
        yLabel string = "Height";
    end % public properties

    methods
        function obj = ImageData(imageArray)
            
            obj.data = imageArray;

            switch size(imageArray, 3)
                case 1
                    if isinteger(imageArray)
                        obj.format = "Grayscale";
                    elseif isfloat(imageArray)
                        obj.format = "Normalized Grayscale";
                    end
                case 2
                    obj.format = "dual channel";
                case 3
                    obj.format = "RGB";
                otherwise
                    obj.format = "Multispectral";
            end
        end % ImageData

        function data = getData(obj)
                    data = obj.data;
        end % getData

        function setData(obj, newData)
            obj.data = newData;
        end % setData     

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

        function show(obj, imageFigure, windowTitle)

            switch nargin
                case 1
                    imageFigure = gcf;
                    set(imageFigure, "Name", class(obj));
                case 2
                    set(imageFigure, "Name", class(obj));
                case 3
                    set(imageFigure, "Name", windowTitle);
            end

            % show filtered frame
            imshow(obj.data);
                
            % get current key and pause on 'q'
            key = get(imageFigure, "CurrentCharacter");
            if key == "q" || key == "Q"
                fprintf("Char '%s' pressed. Pausing video. Press any key to continue\n", key);
                pause;
            end

        end % show

    end % public methods
    methods (Static)
        function grayscaleData = asGrayscale(imageArray)

            switch size(imageArray, 3)
                case 1
                    imageArray = uint8(255 * mat2gray(imageArray));
                case 3
                    imageArray = uint8(255 * mat2gray(rgb2gray(imageArray)));
                otherwise
                    imageArray = uint8(255 * mat2gray(mean(imageArray, 3)));
            end
            
            grayscaleData = ImageData(imageArray);
        end % asGrayscale

        function colorData = asColor(redImageArray, greenImageArray, blueImageArray)

            switch nargin
                case 1
                    assert(size(redImageArray, 3) == 1);
                    colorArray = cat(3, redImageArray, redImageArray, redImageArray);
                case 2
                    assert((size(redImageArray, 3) == 1) && (size(greenImageArray, 3) == 1));
                    emptyChannel = zeros(size(redStruct.image));
                    colorArray = cat(3, redImageArray, greenImageArray, emptyChannel);
                case 3
                    assert((size(redImageArray, 3) == 1) && (size(greenImageArray, 3) == 1) && (size(blueImageArray, 3) == 1));
                    colorArray = cat(3, redImageArray, greenImageArray, blueImageArray);
            end

            colorData = ImageData(colorArray);            
        end % asColor

    end % static methods

end % classdef