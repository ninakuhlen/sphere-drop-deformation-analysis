classdef Figure
    properties(Access=private)
        id
        components % array aus FigureComponent(s)
    end
    
    methods
        function obj = Figure(id, components)
            obj.id = id;
            obj.components = components;
        end

        function obj = addComponent(obj, component)
            obj.components{end+1} = component; % Elemenet im cell array hinzufügen
            obj.showComponent(component);
        end

        function show(obj)
            figure(obj.id);
            for i = 1:length(obj.components)
                component = obj.components{i};
                obj.showComponent(component);
            end
        end

        function showComponent(~, component)
            row = getRow(component);
            column = getColumn(component);
            position = getPosition(component);
            subplot(row, column, position);
            show(component);
        end
    end
end
