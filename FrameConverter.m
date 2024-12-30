classdef FrameConverter % Strategy Pattern
    properties
        brightnessThreshold
        conversionOperations = {}
        filterOperations = {}
    end

    methods
        % Constructor
        function obj = FrameConverter(brightnessThreshold, conversionOperations, filterOperations)
            obj.brightnessThreshold = brightnessThreshold;
            obj.conversionOperations = conversionOperations;
            obj.filterOperations = filterOperations;
        end

        % Konvertierungs-Methoden
        function frame = convertFrame(obj, frame)
            for i = 1:length(obj.conversionOperations)
                conversionOperation = obj.conversionOperations{i};
                frame = execute(conversionOperation, frame);
            end
        end

        function frame = filterFrame(obj, frame)
            for i = 1:length(obj.filterOperations)
                filterOperation = obj.filterOperations{i};
                frame = execute(filterOperation, frame);
            end
        end
    end
end
