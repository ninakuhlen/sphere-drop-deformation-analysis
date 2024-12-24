classdef BaslerCamera
    properties (Access = private)
        adaptorName = 'gentl';
        deviceID = 1;
        pixelFormat = 'Mono8';
    end % private properties
    properties (Access = public)
        deviceConnection
        deviceProperties
    end % public properties

    methods
        function obj = BaslerCamera(varargin)

            % parse keyword value pairs
            parser = inputParser;

            addParameter(parser, "adaptorName", 'gentl', @BaslerCamera.validateAdaptor);
            addParameter(parser, "deviceID", 1);
            addParameter(parser, "pixelFormat", 'Mono8');
            addParameter(parser, "frameRate", 30);

            parse(parser, varargin{:});
            obj.adaptorName = parser.Results.adaptorName;
            obj.deviceID = parser.Results.deviceID;
            obj.pixelFormat = parser.Results.pixelFormat;

            % setup device connection
            obj.deviceConnection = videoinput(obj.adaptorName, obj.deviceID, obj.pixelFormat);

            if isvalid(obj.deviceConnection)
                obj.deviceConnection.FramesPerTrigger = 1;
                obj.deviceConnection.TriggerRepeat = Inf;
            end

            % setup device
            obj.deviceProperties = getselectedsource(obj.deviceConnection);
            if isvalid(obj.deviceProperties)
                obj.deviceProperties.ExposureTime = int32(10^6 / parser.Results.frameRate)
            end

            % create cleanup tasks
            cleanup = onCleanup(@() BaslerCamera.videoCleanup(obj.deviceConnection));
        end % BaslerCamera

        function showConnectionInfo(obj)
            get(obj.deviceConnection)
        end % showConnectionInfo

        function showDeviceSettings(obj)
            get(obj.deviceProperties)
        end % showDeviceSettings
      
        function frame = getFrame(obj)

            if ~isrunning(obj.deviceConnection)
                start(obj.deviceConnection)
            end

            frame = getsnapshot(obj.deviceConnection);

            flushdata(video,"all");
        end % getFrame

    end % methods
    methods (Static)

        function validateAdaptor(adaptorName)
            availableHardware = imaqhwinfo;
            installedAdaptors = availableHardware.InstalledAdaptors;
            adaptorAvailable = any(strcmpi(adaptorName, installedAdaptors));

            if ~adaptorAvailable
                error("The Adaptor '%s' is not installed.", adaptorName);
            end
        end % checkAdaptor

        function videoCleanup(device)
            % close all figures
            close all;

            % stop video, if the video object exists and is running
            if isvalid(device)
                if isrunning(device)
                    stop(device);
                end

                % empty buffer and delete video object
                flushdata(device, 'all');
                delete(device);
            end
        end % videoCleanup
    end % static methods

end % classdef