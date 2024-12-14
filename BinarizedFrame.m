classdef BinarizedFrame
    properties(Access='private')
        originalFrame
        pixelValueMatrix
    end
    
    methods
        function obj = BinarizedFrame(originalFrame, pixelValueMatrix)
            obj.originalFrame = originalFrame;
            obj.pixelValueMatrix = pixelValueMatrix;
        end

        function val = getOriginalFrame(obj)
            val = obj.originalFrame;
        end

        function val = getPixelValueMatrix(obj)
            val = obj.pixelValueMatrix;
        end
    end
end
