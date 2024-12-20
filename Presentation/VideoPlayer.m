classdef VideoPlayer < FigureComponent
    properties
        videoPlayerHandle % object
    end
    
    methods
        function obj = VideoPlayer(videoPlayerHandle, row, column, position)
            obj@FigureComponent(row, column, position); % parent call
            obj.videoPlayerHandle = videoPlayerHandle;
        end

        function show(obj, ~)
            obj.videoPlayerHandle.preview();
        end
    end
end
