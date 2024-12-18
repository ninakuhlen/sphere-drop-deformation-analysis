classdef VideoPlayerHandle < handle % wird für events gebraucht
    events
        VideoStarted
        VideoFrameUpdated
        VideoStopped
    end

    properties(Access = 'private')
        videoReader
        listenerHandle
    end

    methods
        function obj = VideoPlayerHandle(videoReader)
            obj.videoReader = videoReader;
        end

        function registerHandler(obj, eventName, callback)
            obj.listenerHandle = addlistener(obj, eventName, @(src,evt)callback(src,evt));
        end

        function play(obj)
            notify(obj, "VideoStarted")

            frameIndex = 1;
            while (hasFrame(obj.videoReader))
                frame = readFrame(obj.videoReader);
                disp(frameIndex);
                % figure in eigene Klasse auslagern
                figure(1);
                % Erster Unterplot (1 Zeile, 2 Spalten, Position 1)
                subplot(2, 1, 1);
                image(frame);
                drawnow;
                pause(1/obj.videoReader.frameRate);
                notify(obj, "VideoFrameUpdated", VideoFrameUpdatedEvent(frameIndex, frame))
                frameIndex = frameIndex + 1;
            end

            obj.stop();
        end

        function stop(obj)
            notify(obj, "VideoStopped")
        end
    end
end
