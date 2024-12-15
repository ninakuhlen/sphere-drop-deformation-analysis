% Data Transfer Object DTO
% Objekt ist für den Transport von Daten zuständig. (Falls neue dazu kommen, muss nicht überall der code entsprechend angepasst werden)
classdef BinarizedFrameDto
    properties(Access='private')
        frameIndex
        originalFrame
        binaryFrame
    end
    
    methods
        function obj = BinarizedFrameDto(frameIndex, originalFrame, binaryFrame)
            obj.frameIndex = frameIndex;
            obj.originalFrame = originalFrame;
            obj.binaryFrame = binaryFrame;
        end

        function frameIndex = getFrameIndex(obj)
            frameIndex = obj.frameIndex;
        end

        function originalFrame = getOriginalFrame(obj)
            originalFrame = obj.originalFrame;
        end

        function binaryFrame = getBinaryFrame(obj)
            binaryFrame = obj.binaryFrame;
        end
    end
end
