classdef VideoLoader
    % liest das Video mit dem VideoReader aus und
    % erstellt eine Instanz von Video und gibt diese zurück
    properties(Access = 'private')
        path
    end
    
    methods
        function obj = VideoLoader(path)
            obj.path = path;
        end
        
        function video = load(obj, fileName)
            videoReader = VideoReader(obj.path + fileName);
            nFrames = videoReader.NumFrames;
            frames = {}; % wird befüllt s.u.
            fileName = videoReader.Name;
            resolution = [videoReader.Width, videoReader.Height];
            frameRate = videoReader.FrameRate;
            pixelFormat = videoReader.BitsPerPixel;

            while hasFrame(videoReader)
                frame = readFrame(videoReader);
                frames{end+1} = frame;
            end

            video = Video(frames, fileName, resolution, nFrames, frameRate, pixelFormat);
            obj.displayVideoInformation(video);
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
