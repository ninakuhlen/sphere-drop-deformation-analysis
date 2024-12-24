classdef VideoFrameUpdatedEvent < event.EventData
    properties(Access='private')
        frameIndex
        frame
        frameAmount
    end
    
    methods
        function obj = VideoFrameUpdatedEvent(frameIndex, frame, frameAmount)
            obj.frameIndex = frameIndex;
            obj.frame = frame;
            obj.frameAmount = frameAmount;
        end

        function frameIndex = getFrameIndex(obj)
            frameIndex = obj.frameIndex;
        end

        function frame = getFrame(obj)
            frame = obj.frame;
        end

        function frameAmount = getFrameAmount(obj)
            frameAmount = obj.frameAmount;
        end
    end
end
