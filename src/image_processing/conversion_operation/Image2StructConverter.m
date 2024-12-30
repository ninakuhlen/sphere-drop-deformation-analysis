classdef Image2StructConverter

    methods
        function imageStruct = execute(~, image)
            imageStruct = struct("image", image, "title", "frame", "format", [], "xLabel", "image width", "yLabel", "image height");

            if ndims(image) == 3
                imageStruct.format = "multi channel";
            elseif ismatrix(image) && isinteger(image)
                imageStruct.format = "grayscale";
            elseif ismatrix(image) && isfloat(image)
                imageStruct.format = "normalized grayscale";
            end
        end
    end
end

