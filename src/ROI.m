classdef ROI
    properties
        rowStart % Startzeile des ROI
        rowEnd   % Endzeile des ROI
        colStart % Startspalte des ROI
        colEnd   % Endspalte des ROI
    end

    methods
        function obj = ROI(rowStart, rowEnd, colStart, colEnd)
            % Konstruktor: Setzt die ROI-Grenzen
            obj.rowStart = rowStart;
            obj.rowEnd = rowEnd;
            obj.colStart = colStart;
            obj.colEnd = colEnd;
        end

        function reducedFrameStack = apply(obj, frameStack)
            % Überprüfen, ob der ROI innerhalb der Grenzen des Arrays liegt
            [H, W, ~] = size(frameStack)
            if obj.rowStart < 1 || obj.rowEnd > H || obj.colStart < 1 || obj.colEnd > W
                error('ROI ist außerhalb der Grenzen des Arrays.');
            end

            % ROI auf das Frame-Stack anwenden
            reducedFrameStack = frameStack(obj.rowStart:obj.rowEnd, obj.colStart:obj.colEnd, :);
        end
    end
end
