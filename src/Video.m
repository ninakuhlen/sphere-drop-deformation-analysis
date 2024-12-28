classdef Video % speichert Properties, enthält keine Logik (Methoden)
    properties (GetAccess = public, SetAccess = private)
        frames % cell-array mit frame Objekten
        fileName
        resolution % [px]
        nFrames % [1]
        frameRate % [fps]
        pixelFormat % [px]
    end

    methods
        function obj = Video(frames, fileName, resolution, nFrames, frameRate, pixelFormat)
            obj.frames = frames;
            obj.fileName = fileName;
            obj.resolution = resolution;
            obj.nFrames = nFrames;
            obj.frameRate = frameRate;
            obj.pixelFormat = pixelFormat;
        end
    end
end
