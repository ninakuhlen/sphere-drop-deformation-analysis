classdef GeometryReconstructor < handle
    properties (Access = private)
        units string = ["mm/px", "mm/px", "mm/f", "px/f", "mm/f", "mm"];
    end % private properties
    properties (GetAccess = public, SetAccess = private)
        voxelEdgeX
        voxelEdgeY
        voxelEdgeZ
        stretchFactor
        stretchError
        sphereRadius
    end % getable properties
    methods
        function obj = GeometryReconstructor(videoFile, sphereDiameter, objectWidth, velocityInfo)

            % parse keyword value pairs
            parser = inputParser;

            addParameter(parser, "translationVelocity", NaN);
            addParameter(parser, "coveredDistance", NaN);

            parse(parser, velocityInfo{:});

            translationVelocity = parser.Results.translationVelocity;
            coveredDistance = parser.Results.coveredDistance;

            if ~isnan(coveredDistance)
                translationVelocity = coveredDistance / videoFile.duration;
            end

            frameResolution = videoFile.get("originalResolution");
            frameWidth = frameResolution(2);

            voxelDimensions = GeometryReconstructor.calculateVoxelDimensions(...
                objectWidth, ...
                frameWidth, ...
                videoFile.frameRate, ...
                translationVelocity ...
                );

            obj.voxelEdgeY = voxelDimensions(1);
            obj.voxelEdgeX = voxelDimensions(2);
            obj.voxelEdgeZ = voxelDimensions(3);

            [obj.stretchFactor, obj.stretchError] = GeometryReconstructor.calculateStretchFactor(voxelDimensions);

            obj.sphereRadius = sphereDiameter / 2;
        end % GeometryReconstructor

        function domeHeight = calculateDomeHeight(obj, baseRadius)
            domeHeight = obj.sphereRadius - sqrt(obj.sphereRadius^2 - baseRadius^2);
        end % calculateDomeHeight

        function calculateDomeDimensions(obj, binaryImageData)
            edgeImage = edge(binaryImageData.getData(),"Canny");
            edgeImage = bwmorph(edgeImage, "branchpoints");

            [yCoords, xCoords] = find(edgeImage);
            yDim = max(yCoords) - min(yCoords);
            xDim = max(xCoords) - min(xCoords);
            
            yDimMM = yDim * obj.voxelEdgeY
            xDimMM = xDim * obj.voxelEdgeX

            depth = obj.calculateDomeHeight(xDimMM/2)


        end % calculateDomeDimensions

        function disp(obj)
            className = class(obj);
            fprintf("\n%s\n", className);

            % print all public properties
            fprintf("Properties:\n");
            objectProperties = properties(obj);
            for i = 1:length(objectProperties)
                fprintf("\t%s:\t%s %s\n", objectProperties{i}, mat2str(obj.(objectProperties{i})), obj.units(i));
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
    methods (Static, Access = private)

        function voxelDimensions = calculateVoxelDimensions(objectWidth, frameWidth, frameRate, translationVelocity)
            voxelXY = objectWidth / frameWidth;
            voxelZ = translationVelocity / frameRate;
            voxelDimensions = [voxelXY voxelXY voxelZ];
        end % calculateVoxelDimensions

        function [stretchFactor, stretchError] = calculateStretchFactor(voxelDimensions)
            stretchFactor = floorDiv(voxelDimensions(3), voxelDimensions(1));
            stretchError = rem(voxelDimensions(3), voxelDimensions(1)) * voxelDimensions(1);
        end % calculateStretchFactor

    end % static private methods
end % classdef
