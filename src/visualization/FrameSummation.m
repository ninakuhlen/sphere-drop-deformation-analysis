classdef FrameSummation

    methods
        % Compute summed brightness matrix
        function [summedMatrix1, summedMatrix2, summedMatrix3] = computeSum(~, frameStack)
            fprintf('Starting computation of summed brightness matrix...\n');
            %fprintf('Number of frames to process: %d\n', video.nFrames);

            % Summation process
            summedMatrix3 = sum(frameStack, 3); % Summe entlang der Frame-Anzahl (N)
            summedMatrix2 = squeeze(sum(frameStack, 2)); % Summe entlang der Höhe (H)
            summedMatrix1 = squeeze(sum(frameStack, 1)); % Summe entlang der Breite (W)
        end
    end
end
