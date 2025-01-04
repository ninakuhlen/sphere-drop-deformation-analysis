classdef VideoLoader
    % liest das Video mit dem VideoReader aus und
    % erstellt eine Instanz von Video und gibt diese zurück
    properties(Access = 'private')
        path
        frameConverter
    end
    
    methods
        function obj = VideoLoader(path, frameConverter)
            obj.path = path;
            obj.frameConverter = frameConverter;
        end
        
        function video = load(obj, fileName)
            videoReader = VideoReader(obj.path + fileName);
            nFrames = videoReader.NumFrames;
            frames = {}; % wird befüllt s.u.
            resolutionX = videoReader.Width;
            resolutionY = videoReader.Height;
            frameStack = zeros(resolutionY, resolutionX, nFrames);
            fileName = videoReader.Name;
            frameRate = videoReader.FrameRate;
            duration = videoReader.Duration;
            pixelFormat = videoReader.BitsPerPixel;

            index = 1;
            while hasFrame(videoReader)
                frame = readFrame(videoReader);
                %imwrite(frame, obj.path + "\cache\" + fileName + "\\"  + index + ".png");
                frames{end+1} = frame;
                frameStack(:, :, index) = obj.frameConverter.convert(frame);
                index = index + 1;
            end

            video = Video(frames, fileName, resolutionX, resolutionY, nFrames, frameStack, frameRate, duration, pixelFormat);
            %obj.displayVideoInformation(video);
        end

        function displayVideoInformation(~, video)
            className = class(video);
            fprintf('\n%s\n', className);
            fprintf('Properties:\n');
            objectProperties = properties(video);
            for i = 2:length(objectProperties)
                fprintf("\t%s:\t%s\n", objectProperties{i}, mat2str(video.(objectProperties{i})));
            end
        end
    end
end
