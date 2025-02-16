classdef FrameSummation
    properties
        binarizedFrames % array with BinarizedFrame objects
    end

    methods
        % Constructor
        function obj = FrameSummation(binarizedFrames)
            fprintf('Initializing FrameSummation...\n');
            if isempty(binarizedFrames)
                error('Input frames cannot be empty.');
            end
            obj.binarizedFrames = binarizedFrames;
        end

        % Compute summed brightness matrix
        function summedMatrix = computeSum(obj)
            fprintf('Starting computation of summed brightness matrix...\n');
            numFrames = size(obj.binarizedFrames, 2);
            fprintf('Number of frames to process: %d\n', numFrames);
            binaryFrames = zeros(1200, 1920, numFrames);
            for index = 1:length(obj.binarizedFrames) - 1
                binarizedFrame = obj.binarizedFrames{index};
                frameIndex = getFrameIndex(binarizedFrame);
                binaryFrame = getBinaryFrame(binarizedFrame);
                binaryFrames(:, :, frameIndex) = binaryFrame;
            end

            % Summation process
            summedMatrix = sum(binaryFrames, 3);
        end
    end
end
