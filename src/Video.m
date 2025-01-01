classdef Video % speichert Properties, enthält keine Logik (Methoden)
    properties (GetAccess = public, SetAccess = private)
        frames % cell-array mit frame Objekten
        fileName
        resolutionX % [px]
        resolutionY % [px]
        nFrames % [1]
        frameStack % [H, W, N]
        frameRate % [fps]
        duration % [s]
        pixelFormat % [px]
    end

    methods
        function obj = Video(frames, fileName, resolutionX, resolutionY, nFrames, frameStack, frameRate, duration, pixelFormat)
            obj.frames = frames;
            obj.fileName = fileName;
            obj.resolutionX = resolutionX;
            obj.resolutionY = resolutionY;
            obj.nFrames = nFrames;
            obj.frameStack = frameStack;
            obj.frameRate = frameRate;
            obj.duration = duration;
            obj.pixelFormat = pixelFormat;
        end
    end
end
