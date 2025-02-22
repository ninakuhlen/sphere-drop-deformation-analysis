classdef BaslerCamera
    properties (Access = private)
        adaptorName string = "gentl";
        deviceID;
        pixelFormat;
    end % private properties
    properties (Access = public)
        deviceConnection
        deviceProperties
    end % public properties

    methods
        function obj = BaslerCamera(adaptorName, frameRate)

            connectionInfo = imaqhwinfo(obj.adaptorName);

            deviceInfo = connectionInfo.DeviceInfo

            obj.pixelFormat = deviceInfo.DefaultFormat;
            obj.deviceID = deviceInfo.DeviceID;

            % setup device connection
            obj.deviceConnection = videoinput(obj.adaptorName, obj.deviceID, obj.pixelFormat);

            if isvalid(obj.deviceConnection)
                obj.deviceConnection.FramesPerTrigger = 1;
                obj.deviceConnection.TriggerRepeat = Inf;
            end

            % setup device
            obj.deviceProperties = getselectedsource(obj.deviceConnection);
            if isvalid(obj.deviceProperties)
                obj.deviceProperties.ExposureTime = int32(10^6 / frameRate);
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