classdef VideoFile < handle
    properties (Access = private)
        video
    end % private properties
    properties (GetAccess = public, SetAccess = private)
        fileName
        duration
        resolution % [px]
        nFrames % [1]
        frameRate % [fps]
        pixelFormat % [px]

        roi
    end % getable private properties
    properties (Access = public)
        parentPath = ".\data\recordings\testing\";
    end % public properties
    methods

        function obj = VideoFile(fileName)
            obj.video = VideoReader(obj.parentPath+fileName);
            obj.fileName = obj.video.Name;
            obj.duration = obj.video.Duration;
            obj. resolution = [obj.video.Height, obj.video.Width];
            obj.nFrames = obj.video.NumFrames;
            obj.frameRate = obj.video.FrameRate;
            obj.pixelFormat = obj.video.BitsPerPixel;
            obj.roi = [1, obj.video.Height;
                1, obj.video.Width];
        end % VideoFile

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
            objectProperties = properties(obj);
            for i = 1:length(objectProperties)
                fprintf("\t%s:\t%s\n", objectProperties{i}, mat2str(obj.(objectProperties{i})));
            end
        end % disp

        function setROI(obj, nPixels, target, mode)
            targetMap = dictionary("height", 1, "width", 2);
            dim = targetMap(target);

            switch mode
                case "symmetrical"
                    obj.roi(dim, 1) = 1 + nPixels;
                    obj.roi(dim, 2) = obj.resolution(dim) - nPixels;
                case "from center"
                    center = floor(obj.resolution(dim) / 2);
                    obj.roi(dim, 1) = center + nPixels + 1;
                    obj.roi(dim, 2) = center;
                otherwise
                    error('Invalid mode. Use "symmetrical" or "from center".');
            end

            obj.resolution(dim) = obj.roi(dim, 2) - obj.roi(dim, 1) + 1;
        end % setROI

        function frame = getFrame(obj)
            if hasFrame(obj.video)
                frame = readFrame(obj.video);
                frame = frame(obj.roi(1, 1):obj.roi(1, 2), obj.roi(2, 1):obj.roi(2, 2), :);
            else
                error('No more frames available in the video.');
            end
        end % getFrame
    end % methods
end % classdef