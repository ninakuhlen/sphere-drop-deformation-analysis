classdef (Abstract) FigureComponent % es kann keine Instanz von FigureComponent erstellt werden, FigureComponent kann nur vererben
    properties(Access=private)
        row
        column
        position
    end

    methods(Abstract)
        show(~) % muss bei Vererbung implementiert werden
    end

    methods
        function obj = FigureComponent(row, column, position)
            obj.row = row;
            obj.column = column;
            obj.position = position;
        end

        function row = getRow(obj)
            row = obj.row;
        end

        function column = getColumn(obj)
            column = obj.column;
        end

        function position = getPosition(obj)
            position = obj.position;
        end
    end
end
