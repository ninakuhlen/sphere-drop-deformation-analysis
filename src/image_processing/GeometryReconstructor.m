classdef GeometryReconstructor < handle
    properties (GetAccess = public, SetAccess = private)
        gridDimensions
        voxelDimensions
        stretch
        sphereRadius
    end % private properties
    properties (Access = public)
    end % public properties
    methods
        function obj = GeometryReconstructor(video, sphereDiameter, objectWidth, velocityInfo)

            % parse keyword value pairs
            parser = inputParser;

            addParameter(parser, "translationVelocity", NaN);
            addParameter(parser, "coveredDistance", NaN);

            parse(parser, velocityInfo{:});

            translationVelocity = parser.Results.translationVelocity;
            coveredDistance = parser.Results.coveredDistance;

            if ~isnan(coveredDistance)
                translationVelocity = coveredDistance / video.duration;
            end

            obj.voxelDimensions = GeometryReconstructor.calculateVoxelDimensions(...
                objectWidth, ...
                video.resolution(2), ...
                video.frameRate, ...
                translationVelocity ...
                );

            obj.gridDimensions = [video.resolution(1) video.resolution(2) video.nFrames];
            obj.sphereRadius = sphereDiameter / 2;
        end % GeometryReconstructor

        function value = get(obj, propertyName)
            if nargin == 1
                objectProperties = properties(obj);
                value = struct();
                for i = 1:length(objectProperties)
                    value.(objectProperties{i}) = obj.(objectProperties{i});
                end
            else
                if isprop(obj, propertyName)
                    value = obj.(propertyName);
                else
                    error(['Property "', propertyName, '" does not exist in the class ', class(obj),'.']);
                end
            end
        end % get

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

        function points = createVoxelGrid(obj)
            [height, width, depth] = obj.voxelDimensions;
            [x, y, z] = meshgrid(width, height, depth);
            x = x * obj.voxelDimensions(1);
            y = y * obj.voxelDimensions(2);
            z = z * obj.voxelDimensions(3);

            points = [x(:) y(:) z(:)];

            disp(size(points))

        end % createVoxelGrid

    end % methods
    methods (Static)

        function voxelDimensions = calculateVoxelDimensions(objectWidth, frameWidth, frameRate, translationVelocity)
            voxelXY = objectWidth / frameWidth;
            voxelZ = translationVelocity / frameRate;
            voxelDimensions = [voxelXY voxelXY voxelZ];
        end % calculateVoxelDimensions

        function [nPixels, error] = calculateStretchFactor(voxelDimensions)
            nPixels = floorDiv(voxelDimensions(3), voxelDimensions(1));
            error = rem(voxelDimensions(3), voxelDimensions(1));
        end %


        function domeHeight = calculateDomeHeight(sphereRadius, baseRadius)
            domeHeight = sphereRadius - sqrt(sphereRadius^2 - baseRadius^2);
        end % calculateDomeHeight

    end % static methods
end % classdef
