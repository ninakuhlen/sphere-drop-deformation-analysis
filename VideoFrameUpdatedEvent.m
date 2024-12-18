classdef VideoFrameUpdatedEvent < event.EventData
    properties(Access='private')
        frameIndex
        frame
    end
    
    methods
        function obj = VideoFrameUpdatedEvent(frameIndex, frame)
            obj.frameIndex = frameIndex;
            obj.frame = frame;
        end

        function frameIndex = getFrameIndex(obj)
            frameIndex = obj.frameIndex;
        end

        function frame = getFrame(obj)
            frame = obj.frame;
        end
    end
end
