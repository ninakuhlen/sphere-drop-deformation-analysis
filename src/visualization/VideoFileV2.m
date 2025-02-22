classdef VideoFileV2 < handle
    properties (Access = private)
        video
    end % private properties
    properties (GetAccess = public, SetAccess = private)
        fileName
        duration
        pixelFormat string = "RGB";
        resolution % [px]
        nFrames % [1]
        frameRate % [fps]
        roi % [px]
    end % getable private properties
    properties (Access = public)
        parentPath = "..\data\recordings\";
        frameIndex = 0;
    end % public properties
    methods

        function obj = VideoFileV2(fileName, format)
            obj.video = VideoReader(obj.parentPath+fileName);
            obj.fileName = obj.video.Name;
            obj.duration = obj.video.Duration;
            obj. resolution = [obj.video.Height, obj.video.Width];
            obj.nFrames = obj.video.NumFrames;
            obj.frameRate = obj.video.FrameRate;
            obj.roi = [1, obj.video.Height;
                1, obj.video.Width];

            if nargin == 2
                validFormats = ["RGB", "Grayscale"];
                assert(ismember(format, validFormats)), "Invalid format selected!";
                obj.pixelFormat = format;
            end

            % create cleanup tasks
            % cleanup = onCleanup(@() VideoFile.videoCleanup(obj.video));
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

        function setROI(obj, nPixels, mode)

            switch mode
                case "T"
                    obj.roi(1, 1) = 1 + nPixels;
                case "B"
                    obj.roi(1, 2) = obj.resolution(1) - nPixels;
                case "TB"
                    obj.roi(1, 1) = 1 + nPixels;
                    obj.roi(1, 2) = obj.resolution(1) - nPixels;
                case "L"
                    obj.roi(2, 1) = 1 + nPixels;
                case "R"
                    obj.roi(2, 2) = obj.resolution(2) - nPixels;
                case "LR"
                    obj.roi(2, 1) = 1 + nPixels;
                    obj.roi(2, 2) = obj.resolution(2) - nPixels;
                case "CT"
                    center = floor(obj.resolution(1) / 2);
                    obj.roi(1, 1) = center - nPixels + 1;
                case "CB"
                    center = floor(obj.resolution(1) / 2);
                    obj.roi(1, 2) = center + nPixels;
                case "CTB"
                    center = floor(obj.resolution(1) / 2);
                    obj.roi(1, 1) = center - nPixels + 1;
                    obj.roi(1, 2) = center + nPixels;
                case "CL"
                    center = floor(obj.resolution(2) / 2);
                    obj.roi(2, 1) = center - nPixels + 1;
                case "CR"
                    center = floor(obj.resolution(2) / 2);
                    obj.roi(2, 2) = center + nPixels;
                case "CLR"
                    center = floor(obj.resolution(2) / 2);
                    obj.roi(2, 1) = center - nPixels + 1;
                    obj.roi(2, 2) = center + nPixels;

                otherwise
                    error("Invalid mode. Use 'T', 'B', 'TB', 'L', 'R' or 'LR'. To measure from the image center, add a leading 'C'.");
            end
            
        end % setROI

        function start(obj)
            obj.resolution(1) = obj.roi(1, 2) - obj.roi(1, 1) + 1;
            obj.resolution(2) = obj.roi(2, 2) - obj.roi(2, 1) + 1;

        end % start

        function frame = getFrame(obj)
            if hasFrame(obj.video)
                obj.frameIndex = obj.frameIndex + 1;
                frame = readFrame(obj.video);
                frame = frame(obj.roi(1, 1):obj.roi(1, 2), obj.roi(2, 1):obj.roi(2, 2), :);
                if obj.pixelFormat == "Grayscale"
                    frame = im2gray(frame);
                end
            else
                obj.frameIndex = 0;
                error('No more frames available in the video.');
            end
        end % getFrame

    end % methods

    methods (Static, Access=private)
        function videoCleanup()
            % close all figures
            close all;

            % clear workspace
            clear all;

            % clear command window
            clc;
        end % videoCleanup
    end % private methods
end % classdef