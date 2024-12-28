classdef VideoFile
    properties (GetAccess = public, SetAccess = private)
        video
        fileName
        resolution % [px]
        nFrames % [1]
        frameRate % [fps]
        pixelFormat % [px]
    end % private properties
    properties (Access = public)
        parentPath = "C:\Users\Studium\Documents\GitHub\sphere-drop-deformation-analysis\data\recordings\testing\";
    end % public properties
    methods

        function obj = VideoFile(fileName)
            disp(obj.parentPath+fileName)
            obj.video = VideoReader(obj.parentPath+fileName);
            obj.fileName = obj.video.Name;
            obj. resolution = [obj.video.Width, obj.video.Height];
            obj.nFrames = obj.video.NumFrames;
            obj.pixelFormat = obj.video.BitsPerPixel;
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
            fprintf('Properties:\n');
            objectProperties = properties(obj);
            for i = 1:length(objectProperties)
                fprintf("\t%s:\t%s\n", objectProperties{i}, mat2str(obj.(objectProperties{i})));
            end
        end % disp 

        function frame = getFrame(obj)

            if ~isrunning(obj.deviceConnection)
                start(obj.deviceConnection)
            end

            frame = getsnapshot(obj.deviceConnection);

            flushdata(video,"all");
        end % getFrame
    end % methods
end % classdef