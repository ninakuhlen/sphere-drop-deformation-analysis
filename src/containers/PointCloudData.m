classdef PointCloudData < handle & matlab.mixin.Copyable
    properties (Access = private)
        data
        labels string;
        units string;
    end % private properties
    properties
        name string = "Point Cloud";
    end % properties

    methods
        function obj = PointCloudData(pointList, name)

            obj.data = obj.createDictionary(pointList);
            obj.labels = obj.data.keys';

            for i = 1:length(obj.labels)
                obj.units(i) = "[1]";
            end

            switch nargin
                case 1
                    return;
                case 2
                    obj.name = string(name);
            end

        end % PointCloudData

        function data = getData(obj, label)
            switch nargin
                case 1
                    data = cell2mat(obj.data.values');
                case 2
                    data = cell2mat(obj.data(label))';
            end
        end % getData

        function setData(obj, newData, label)
            switch nargin
                case 2
                    if size(newData, 2) ~= length(obj.labels)
                        error("Please match point dimensions or create new PointCloudData object!")
                    end
                    obj.data = obj.createDictionary(newData, obj.labels);
                case 3
                    oldData = obj.getData();

                    keys = obj.data.keys;
                    i = find(keys == label);

                    if size(oldData(:,i)') ~= size(newData)
                        error("Dimensions of old and new data not identical!")
                    end
                    
                    oldData(:,i) = newData';

                    obj.setData(oldData);
            end
        end % setData

        function unit = getUnit(obj, label)
            switch nargin
                case 1
                    unit = obj.units;
                case 2
                    keys = obj.data.keys;
                    i = find(keys==label);
                    unit = obj.units(i);
            end
        end % getUnit

        function setUnit(obj, newUnit, label)
            switch nargin
                case 2
                    obj.units(:) = sprintf("[%s]", newUnit);
                case 3
                    keys = obj.data.keys;
                    i = find(keys==label);
                    obj.units(i) = sprintf("[%s]", newUnit);
            end
        end % setUnit

        function relabel(obj, oldKey, newKey)
            oldKey = string(oldKey);
            newKey = string(newKey);

            if isKey(obj.data, oldKey)
                keys = obj.data.keys;
                values = obj.data.values;

                keys(keys == oldKey) = newKey;

                obj.data = dictionary(keys, values);
                obj.labels = keys';
            else
                error("Old key not in data!");

            end
        end % relabel

        function crop(obj, label, lowerLimit, upperLimit)
            if isnan(lowerLimit)
                lowerLimit = min(cell2mat(obj.data(label)), [], "all");
            end

            if isnan(upperLimit)
                upperLimit = max(cell2mat(obj.data(label)), [], "all");
            end
            keys = obj.data.keys;
            i = find(keys==label);

            croppedData = obj.getData();
            croppedData = croppedData(croppedData(:,i) >= lowerLimit, :);
            croppedData = croppedData(croppedData(:,i) <= upperLimit, :);

            obj.setData(croppedData);

        end %crop

        function getInfo(obj)
            fprintf("\nPoint cloud '%s':\n", obj.name)

            nPoints = size(obj.getData(), 1);
            fprintf("\tNumber of Points:\t%s\n", num2str(nPoints));

            keys = obj.data.keys;
            for i = 1:length(keys)
                values = cell2mat(obj.data(keys(i))');
                minValue = min(values, [], "all");
                maxValue = max(values, [], "all");
                fprintf("\t'%s' Min/Max:\t%s  /  %s    %s\n", keys(i), num2str(minValue), num2str(maxValue), obj.units(i));
            end

        end % getInfo

        function saveFigure(obj, fileName)
            fileName = string(fileName);
            parentPath = "\results\point_clouds\";
            mkdir(parentPath);
            filePath = parentPath + fileName + ".fig";
            saveas(obj.pointCloudFigure, filePath);
        end % saveFigure

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

        function show(obj, windowTitle, x, y, z)

            windowTitle = string(windowTitle);
            set(gcf, "Name", windowTitle);

            labelWithUnit = @(x) (x) + " " + obj.units(find(obj.data.keys == (x)));

            if nargin == 4
                % plot 2 data coordinates

                xData = cell2mat(obj.data(x));
                yData = cell2mat(obj.data(y));

                scatter(xData, yData, 8, "blue", "filled", "o");

                xlabel(labelWithUnit(x));
                ylabel(labelWithUnit(y));
                title(windowTitle);
                grid on;

            elseif nargin == 5
                % plot 3 data coordinates

                xData = cell2mat(obj.data(x));
                yData = cell2mat(obj.data(y));
                zData = cell2mat(obj.data(z));

                scatter3(xData, yData, zData, 8, zData,"filled","o");

                xlabel(labelWithUnit(x));
                ylabel(labelWithUnit(y));
                zlabel(labelWithUnit(z));
                title(windowTitle);
                colorBar = colorbar;
                axis equal;
                grid on;
                rotate3d on;

                title(colorBar, labelWithUnit(z))

            else
                error("Invalid number of arguments! Please select either X and Y axes or X, Y and Z axes.");
            end

        end % show

    end % public methods
    
    methods (Static)
        function obj = fromImageStack(imageStack, name, scalingFactor)

            switch nargin
                case {1, 2}
                    scalingFactor = 1;
                case 3
                    assert(size(scalingFactor, 2) == 1 || size(scalingFactor, 2) == 3, "Invalid number of scaling factors! Either insert a single scalar or a list of three scalars.");
            end

            [height, width, depth] = size(imageStack.getData());
            [x, y, z] = meshgrid(1:width, 1:height, 1:depth);

            switch size(scalingFactor, 2)
                case 1
                    x = x * scalingFactor;
                    y = y * scalingFactor;
                    z = z * scalingFactor;
                case 3
                    x = x * scalingFactor(1);
                    y = y * scalingFactor(2);
                    z = z * scalingFactor(3);

            end

            a = imageStack.getData();

            points = [x(:) y(:) z(:) a(:)];

            disp(size(points))

            obj = PointCloudData(points, name);
        end % fromImageStack
    
    end % static methods
    methods (Static, Access=private)
        function d = createDictionary(pointList, keys)
            n = size(pointList, 2);
            values = cell(1, n);
            
            for i = 1:n
                values{i} = pointList(:, i);
            end

            if nargin == 1
                % initial keys are alphabetical starting at x
                keys = strings(1, n);
                for i = 1:n
                    keys(i) = char(mod(i + 22, 26) + 'a'); % 'a' = 96
                end
            end

            d = dictionary(keys, values);
        end % createDictionary
    end % static private methods

end % classdef