classdef ImageStruct2GrayScaleStructConverter
    properties
        imageStruct
    end
    
    methods
        function obj = ImageStruct2GrayScaleStructConverter(imageStruct)
            obj.imageStruct = imageStruct;
        end
        
        function grayscaleStruct = execute(obj, imageStruct)
            grayscaleStruct = imageStruct;
            image = grayscaleStruct.image;

            hasColor = false;
            if ndims(image) == 3
                image = rgb2gray(image);
                hasColor = true;
            end
            originalMin = double(min(image(:)));
            originalMax = double(max(image(:)));
            originalRange = [originalMin, originalMax];

            image(isnan(image)) = originalMin;

            grayscaleStruct.image = uint8(255 * mat2gray(image));

            grayscaleStruct.format = "grayscale";

            if obj.logConversions
                % display conversion information
                functionInfo = dbstack;
                fprintf('\n%s:\n', functionInfo(1).name);
                fprintf('\tInput Image:\t%s\n', inputname(2));
                fprintf('\tConversion from Color:\t%s\n', ImageProcessor.bool2str(hasColor));
                fprintf('\tOriginal Image Range:\t[%s]\n', num2str(originalRange));
                fprintf('\tGrayscale Image Range:\t[0 255]\n');
            end
        end
    end
end

