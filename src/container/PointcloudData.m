classdef PointcloudData
    properties
        data
        title str = "frame";
        labels list = ["x", "y", "z"];
    end % properties

    methods
        function obj = PointcloudData(pointList, title, labels)
            
            obj.data = pointList;

            switch nargin
                case 1
                    return
                case 2
                    obj.title = title;
                case 3
                    obj.title = title;
                    obj.labels = labels;
            end
            
        end % PointcloudData

    end % public methods

end % classdef