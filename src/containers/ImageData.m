classdef ImageData < handle & matlab.mixin.Copyable
    properties (Access=private)
        data
        processingLog string = strings(0);
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
                    if islogical(imageArray)
                        obj.format = "Binary";
                    elseif isinteger(imageArray)
                        obj.format = "Grayscale";
                    elseif isfloat(imageArray)
                        obj.format = "Normalized Grayscale";
                    end
                case 2
                    obj.format = "Dual Channel";
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
            switch size(newData, 3)
                case 1
                    if islogical(newData)
                        obj.format = "Binary";
                    elseif isinteger(newData)
                        obj.format = "Grayscale";
                    elseif isfloat(newData)
                        obj.format = "Normalized Grayscale";
                    end
                case 2
                    obj.format = "Dual Channel";
                case 3
                    obj.format = "RGB";
                otherwise
                    obj.format = "Multispectral";
            end
        end % setData

        function logEntry = getLog(obj, index)
            switch nargin
                case 1
                    logEntry = obj.processingLog;
                case 2
                    logEntry = obj.processingLog(index);
            end
        end % getLog

        function appendLog(obj, logEntry)
            obj.processingLog(end + 1) = string(logEntry);
        end % appendLog

        function dispLog(obj)
            className = class(obj);
            fprintf("\n%s Processing Log\n", className);

            if isempty(obj.processingLog)
                disp("No image processing was performed.");
                return;
            end
            
            % select first string and counter
            currentString = obj.processingLog{1};
            count = 1;

            for i = 2:length(obj.processingLog)
                if strcmp(obj.processingLog{i}, currentString)
                    count = count + 1;
                    continue;
                end

                if count > 1
                    fprintf("\t%d %s\n", count, currentString);
                else
                    fprintf("\t%s\n", currentString);
                end
                
                % select next string and reset counter
                currentString = obj.processingLog{i};
                count = 1;
            end

            % display the only or final string in the list
            if count > 1
                fprintf("\t%d %s\n", count, currentString);
            else
                fprintf("\t%s\n", currentString);
            end

        end % dispLog

        function disp(obj)
            className = class(obj);
            fprintf("\n%s\n", className);

            % print all public properties
            fprintf("Properties:\n");
            objectProperties = properties(obj);
            for i = 1:length(objectProperties)
                fprintf("\t%s:\t%s\n", objectProperties{i}, mat2str(obj.(objectProperties{i})));
            end

            minValue = min(obj.data, [], "all", "omitnan");
            maxValue = max(obj.data, [], "all", "omitnan");

            fprintf("\tglobalMin:\t%s\n", mat2str(minValue));
            fprintf("\tglobalMax:\t%s\n", mat2str(maxValue));

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
                    figure(imageFigure);
                    set(imageFigure, "Name", class(obj));
                case 3
                    figure(imageFigure);
                    windowTitle = string(windowTitle);
                    set(imageFigure, "Name", windowTitle);
            end

            image = uint8(obj.data);

            % show filtered frame
            imshow(image);

            % get current key and pause on 'q'
            key = get(imageFigure, "CurrentCharacter");
            if key == "q" || key == "Q"
                fprintf("Char '%s' pressed. Pausing video. Press any key to continue\n", key);
                pause;
            end

        end % show

        function showHistogram(obj, imageFigure, windowTitle)

            switch nargin
                case 1
                    imageFigure = gcf;
                    set(imageFigure, "Name", class(obj) + " Histogram");
                case 2
                    figure(imageFigure);
                    set(imageFigure, "Name", class(obj) + " Histogram");
                case 3
                    figure(imageFigure);
                    windowTitle = string(windowTitle);
                    set(imageFigure, "Name", windowTitle);
            end

            image = uint8(imgaussfilt(obj.data));

            minValue = min(image(~isnan(image)), [], "all");
            maxValue = max(image(~isnan(image)), [], "all");


            [counts, binCenters] = imhist(image(image ~=0), 256);

            % logarithmic scaling: +1 to avoid log(0)
            logCounts = log10(counts + 1);

            if length(binCenters) ~= length(logCounts)
                error("Mismatching numbers of 'binCenters' and 'logCounts'!");
            end

            % get envelope by using a Savitzky-Golay filter
            smoothedCounts = sgolayfilt(logCounts, 2, 11); % Grad 3, windowSize 11
          
            % plot histogram
            bar(binCenters, logCounts, "FaceColor", [0.5, 0.5, 0.8]);
            hold on;

            % plot envelope
            plot(binCenters, smoothedCounts, "r", "LineWidth", 2);

            xlabel("Grayscale");
            ylabel("Logarithmic Frequency");
            legend("Histogram", "Envelope");
            hold off;

            % get current key and pause on 'q'
            key = get(imageFigure, "CurrentCharacter");
            if key == "q" || key == "Q"
                fprintf("Char '%s' pressed. Pausing video. Press any key to continue\n", key);
                pause;
            end

        end % showHistogram

    end % public methods
    methods (Access=private)
        function estimateImageFormat(obj)
        end % estimateImageType

        function applyImageFormat(obj)
        end % applyImageFormat
    end % 
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

        function showPair(imageDataA, imageDataB, imageFigure, windowTitle)
        end % showPair

    end % static methods

end % classdef