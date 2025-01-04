classdef VideoPlayerHandle < handle % wird für events gebraucht
    events
        VideoStarted
        VideoFrameUpdated
        VideoStopped
    end

    properties(Access = 'private')
        figureId
        frames = {}
        frameAmount = 0
        frameRate
        frameIndex = 1
        listenerHandle
        isPlaying logical = false
    end

    methods
        function obj = VideoPlayerHandle(figureId, video)
            obj.figureId = figureId;
            obj.frameRate = video.frameRate;
            obj.frames = video.frames;
            obj.frameAmount = video.nFrames;
        end

        function registerHandler(obj, eventName, callback)
            obj.listenerHandle = addlistener(obj, eventName, @(src,evt)callback(src,evt));
        end

        function preview(obj)
            obj.renderFrame(obj.frames{obj.frameIndex});
        end

        function play(obj)
            obj.isPlaying = true;
            notify(obj, "VideoStarted")

            for i = 1:length(obj.frames)
                if (~obj.isPlaying)
                    return;
                end
                if (isequal(obj.frameIndex, obj.frameAmount))
                    obj.reset();
                    return;
                end
                frame = obj.frames{obj.frameIndex};
                obj.renderFrame(frame);
            end

            obj.stop();
        end

        function renderFrame(obj, frame)
            % disp(obj.frameIndex);
            % figure in eigene Klasse auslagern
            figure(obj.figureId);
            % Erster Unterplot (1 Zeile, 2 Spalten, Position 1)
            subplot(2, 1, 1);
            image(frame);
            drawnow;
            pause(1/obj.frameRate);
            notify(obj, "VideoFrameUpdated", VideoFrameUpdatedEvent(obj.frameIndex, frame, obj.frameAmount))
            obj.frameIndex = obj.frameIndex + 1;
        end

        function pause(obj)
            obj.isPlaying = false;
        end

        function reset(obj)
            obj.pause();
            obj.frameIndex = 1;
            obj.preview();
        end

        function stop(obj)
            obj.isPlaying = false;
            notify(obj, "VideoStopped")
        end
    end
end
