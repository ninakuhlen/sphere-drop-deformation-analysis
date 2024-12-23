classdef GeometryReconstructor
    properties (Access = private)
        gridDimensions
        voxelDimensions
        sphereRadius
    end % private properties
    properties (Access = public)
    end % public properties
    methods
        function obj = GeometryReconstructor(video, translationVelocity, sphereRadius, objectWidth)
            % parse keyword value pairs
            % parser = inputParser;
            % 
            % addRequired(parser, "video", @isvalid);
            % addRequired(parser, "translationVelocity", @isfloat);
            % addRequired(parser, "sphereRadius", @isfloat);
            % addRequired(parser, "objectWidth", @isfloat);
            % 
            % parse(parser, varargin{:});

            obj.voxelDimensions = GeometryReconstructor.calculateVoxelDimensions(...
                objectWidth, ...
                video.Width, ...
                video.FrameRate, ...
                translationVelocity ...
                );

            obj.gridDimensions = [video.Height video.Width video.NumFrames]
            obj.sphereRadius = sphereRadius;
        end % GeometryReconstructor

        function points = createVoxelGrid(obj)
            [height, width, depth] = obj.voxelDimensions;
            [x, y, z] = meshgrid(width, height, depth);
            x = x * obj.voxelDimensions(1);
            y = y * obj.voxelDimensions(2);
            z = z * obj.voxelDimensions(3);

            points = [x(:) y(:) z(:)];

            disp(size(points))

        end % scaleFrame


    end % methods
    methods (Static)

        function voxelDimensions = calculateVoxelDimensions(objectWidth, frameWidth, frameRate, translationVelocity)
            voxelXY = objectWidth / frameWidth;
            voxelZ = translationVelocity / frameRate;
            voxelDimensions = [voxelXY voxelXY voxelZ];
        end % calculateVoxelDimensions
        

        function domeHeight = calculateDomeHeight(sphereRadius, baseRadius)
            domeHeight = sphereRadius - sqrt(sphereRadius^2 - baseRadius^2);
        end % calculateDomeHeight

    end % static methods
end % classdef