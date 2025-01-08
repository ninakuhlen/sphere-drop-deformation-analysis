classdef ImageData
    properties
        data
        title str = "frame";
        format str = "";
        xLabel str = "image width";
        yLabel str = "image height";
    end % properties

    methods
        function obj = ImageData(imageArray, title, format, xLabel, yLabel)
            
            obj.data = imageArray;

            switch ndims(imageArray)
                case 2
                    if isinteger(imageArray)
                        obj.format = "grayscale";
                    elseif isfloat(imageArray)
                        obj.format = "normalized grayscale";
                    end
                case 3
                    obj.format = "multi channel";
            end

            switch nargin
                case 1
                    return
                case 2
                    obj.title = title;
                case 3
                    obj.title = title;
                    obj.format = format;
                case 5
                    obj.title = title;
                    obj.format = format;
                    obj.xLabel = xLabel;
                    obj.yLabel = yLabel;
            end

            
        end % ImageData

    end % public methods

end % classdef