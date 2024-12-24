classdef VideoPlayerControls < FigureComponent    
    properties(Access=private)
        videoPlayerHandle
    end
    
    methods
        function obj = VideoPlayerControls(videoPlayerHandle, row, column, position)
            obj@FigureComponent(row, column, position); % parent call
            obj.videoPlayerHandle = videoPlayerHandle;
        end
        
        function show(obj, figureId)
            % Hier werden die Buttons erstellt. Jeder Button ruft eine Methode
            % im VideoPlayerHandle auf, um die gewünschte Aktion auszuführen.
            % Die UI ist nur ein Client der Logik, kennt aber deren Implementierung nicht.
            
            figureHandle = figure(figureId); % Aktives Figure wählen

            uicontrol('Parent', figureHandle, 'Style', 'pushbutton', 'String', 'Play',...
            'Units','normalized','Position',[0.1 0.05 0.1 0.05],...
            'Callback', @(~,~)obj.videoPlayerHandle.play());

            uicontrol('Parent', figureHandle, 'Style', 'pushbutton', 'String', 'Pause',...
            'Units','normalized','Position',[0.3 0.05 0.1 0.05],...
            'Callback', @(~,~)obj.videoPlayerHandle.pause());

            uicontrol('Parent', figureHandle, 'Style', 'pushbutton', 'String', 'Reset',...
            'Units','normalized','Position',[0.5 0.05 0.1 0.05],...
            'Callback', @(~,~)obj.videoPlayerHandle.reset());

            slider = uicontrol('Parent', figureHandle, 'Style', 'slider', 'Position', [0.1 0.05 500 20]);

            obj.videoPlayerHandle.registerHandler("VideoFrameUpdated", @(src,event) obj.onVideoFrameUpdate(src, event, slider));

            drawnow; % Aktualisiert die Darstellung der UI-Elemente
        end

        function onVideoFrameUpdate(~, ~, event, slider)
            frameAmount = getFrameAmount(event);
            frameIndex = getFrameIndex(event);
            progress = frameIndex / frameAmount;
            slider.Value = progress;
        end
    end
end

