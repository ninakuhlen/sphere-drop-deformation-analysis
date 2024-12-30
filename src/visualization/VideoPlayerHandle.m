classdef VideoPlayerHandle < handle % wird für events gebraucht
    events
        VideoStarted
        VideoFrameUpdated
        VideoStopped
    end

    properties(Access = 'private')
        figureId
        video
        frameIndex = 1
        listenerHandle
        isPlaying logical = false
    end

    methods
        function obj = VideoPlayerHandle(figureId, video)
            obj.figureId = figureId;
            obj.video = video;
        end

        function registerHandler(obj, eventName, callback) % Wrapper-Methode
            obj.listenerHandle = addlistener(obj, eventName, @(src,evt)callback(src,evt));
        end

        function preview(obj)
            obj.renderFrame(obj.video.frames{obj.frameIndex});
        end

        function play(obj)
            obj.isPlaying = true;
            % publish event:
            notify(obj, "VideoStarted")

            for i = 1:length(obj.video.frames)
                if (~obj.isPlaying)
                    return;
                end
                if (isequal(obj.frameIndex, obj.video.nFrames))
                    obj.reset();
                    return;
                end
                frame = obj.video.frames{obj.frameIndex};
                obj.renderFrame(frame);
            end

            obj.stop();
        end

        function renderFrame(obj, frame)
            % disp(obj.frameIndex);
            figure(obj.figureId);
            % Erster Unterplot (1 Zeile, 2 Spalten, Position 1)
            subplot(2, 1, 1);
            image(frame);
            drawnow;
            pause(1/obj.video.frameRate);
            % publish event:
            notify(obj, "VideoFrameUpdated", VideoFrameUpdatedEvent(obj.frameIndex, frame, obj.video.nFrames))
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
