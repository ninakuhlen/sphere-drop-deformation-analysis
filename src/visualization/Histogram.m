classdef Histogram < FigureComponent
    properties(Access=private)
        image % ersetzen mit FrameDto
        %videoPlayerHandle
    end

    methods
        function obj = Histogram(image, row, column, position)
            obj@FigureComponent(row, column, position); % parent call
            obj.image = image;
            %obj.videoPlayerHandle = videoPlayerHandle; % weiter refactorn
        end
        
        function show(obj, ~)
            imhist(obj.image);
            axis tight;
            ylim([0 1200]); % Zeigt nur bis Höhe 200 an, um Details besser zu erkennen
            drawnow;
        end
    end
end
