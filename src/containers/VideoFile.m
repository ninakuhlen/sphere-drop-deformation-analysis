classdef VideoFile < handle
    properties (Access = private)
        video
        originalResolution
        units = ["", "s", "", "px [H W]", "", "fps", "px [T B;L R]", "", ""]
    end % private properties
    properties (GetAccess = public, SetAccess = private)
        fileName
        duration
        pixelFormat string = "RGB";
        resolution
        nFrames
        frameRate
        roi
    end % getable private properties
    properties (Access = public)
        parentPath = "..\data\";
        frameIndex = 0;
    end % public properties
    methods

        function obj = VideoFile(fileName, format)

            obj.video = VideoReader(obj.parentPath+fileName);
            obj.fileName = obj.video.Name;
            obj.duration = obj.video.Duration;
            obj.originalResolution = [obj.video.Height, obj.video.Width];
            obj.resolution = [obj.video.Height, obj.video.Width];
            obj.nFrames = obj.video.NumFrames;
            obj.frameRate = obj.video.FrameRate;
            obj.roi = [1, obj.video.Height;
                1, obj.video.Width];

            if nargin == 2
                format = string(format);
                validFormats = ["RGB", "Grayscale"];
                assert(ismember(format, validFormats)), "Invalid format selected!";
                obj.pixelFormat = format;
            end

            % create cleanup tasks
            % cleanup = onCleanup(@() VideoFile.videoCleanup(obj.video));
        end % VideoFile

        function value = get(obj, propertyName)
            switch nargin
                case 1
                    objectProperties = properties(obj);
                    value = struct();
                    for i = 1:length(objectProperties)
                        value.(objectProperties{i}) = obj.(objectProperties{i});
                    end
                case 2
                    if isprop(obj, propertyName)
                        value = obj.(propertyName);
                    else
                        errorMessage = string(sprintf("Property '#s' does not exist in class '%s'.", propertyName, class(obj)));
                        error(errorMessage);
                    end
            end
        end % get

        function disp(obj)
            className = class(obj);
            fprintf("\n%s\n", className);
            objectProperties = properties(obj);
            for i = 1:length(objectProperties)
                fprintf("\t%s:\t%s %s\n", objectProperties{i}, mat2str(obj.(objectProperties{i})), obj.units(i));
            end
        end % disp

        function setROI(obj, nPixels, mode)

            switch mode
                case "T"
                    obj.roi(1, 1) = 1 + nPixels;
                case "B"
                    obj.roi(1, 2) = obj.originalResolution(1) - nPixels;
                case "TB"
                    obj.roi(1, 1) = 1 + nPixels;
                    obj.roi(1, 2) = obj.originalResolution(1) - nPixels;
                case "L"
                    obj.roi(2, 1) = 1 + nPixels;
                case "R"
                    obj.roi(2, 2) = obj.originalResolution(2) - nPixels;
                case "LR"
                    obj.roi(2, 1) = 1 + nPixels;
                    obj.roi(2, 2) = obj.originalResolution(2) - nPixels;
                case "CT"
                    center = floor(obj.originalResolution(1) / 2);
                    obj.roi(1, 1) = center - nPixels + 1;
                case "CB"
                    center = floor(obj.originalResolution(1) / 2);
                    obj.roi(1, 2) = center + nPixels;
                case "CTB"
                    center = floor(obj.originalResolution(1) / 2);
                    obj.roi(1, 1) = center - nPixels + 1;
                    obj.roi(1, 2) = center + nPixels;
                case "CL"
                    center = floor(obj.originalResolution(2) / 2);
                    obj.roi(2, 1) = center - nPixels + 1;
                case "CR"
                    center = floor(obj.originalResolution(2) / 2);
                    obj.roi(2, 2) = center + nPixels;
                case "CLR"
                    center = floor(obj.originalResolution(2) / 2);
                    obj.roi(2, 1) = center - nPixels + 1;
                    obj.roi(2, 2) = center + nPixels;

                otherwise
                    error("Invalid mode. Use 'T', 'B', 'TB', 'L', 'R' or 'LR'. To measure from the image center, add a leading 'C'.");
            end

            obj.resolution(1) = obj.roi(1, 2) - obj.roi(1, 1) + 1;
            obj.resolution(2) = obj.roi(2, 2) - obj.roi(2, 1) + 1;
            
        end % setROI

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
                error("No more frames available in the video.");
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