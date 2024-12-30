classdef IntensityThresholdMasker
    methods
        function filteredStruct = execute(~, imageStruct, value, mode)
            filteredStruct = imageStruct;
            switch mode
                case "=="
                    filteredStruct.image(imageStruct.image == value) = NaN;
                case "<"
                    filteredStruct.image(imageStruct.image < value) = NaN;
                case "<="
                    filteredStruct.image(imageStruct.image <= value) = NaN;
                case ">"
                    filteredStruct.image(imageStruct.image > value) = NaN;
                case ">="
                    filteredStruct.image(imageStruct.image >= value) = NaN;
                otherwise
                    warning("Invalid mode selected!");
            end
        end
    end
end
