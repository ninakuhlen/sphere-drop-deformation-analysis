classdef ImageProcessor < handle
    properties
    end % public properties
    methods
        function obj = ImageProcessor()
        end % ImageProcessor
    end % methods
    methods (Static)
        function [projection, labelling] = projectFrames(frameStack, mode, axis)

            oldSize = size(frameStack);

            switch mode
                case "sum"
                    projection = sum(frameStack, axis);
                case "max"
                    projection = max(frameStack, [], axis);
                case "min"
                    projection = min(frameStack, [], axis);
                case "mean"
                    projection = mean(frameStack, axis);
                case "median"
                    projection = median(frameStack, axis);
            end

            switch axis
                case 1
                    projection = permute(projection, [3 2 1]);
                    x_label = "Frame Width";
                    y_label = "Time [past -> present]";
                case 2
                    projection = permute(projection, [3 1 2]);
                    x_label = "Frame Height";
                    y_label = "Time [past -> present]";
                case 3
                    % no dimension swap necessary
                    x_label = "Frame Width";
                    y_label = "Frame Height";
            end

            labelling = dictionary(["x" "y"], [x_label y_label]);

            newSize = size(projection);

            displayMessage = "Projected from shape: " ...
                + num2str(oldSize) ...
                + " to " ...
                + num2str(newSize);
            disp(displayMessage)
        end % projectFrames
    end % static methods
end % classdef