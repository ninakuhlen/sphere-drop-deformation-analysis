% Hauptskript

% Konfiguration importieren
load('configs/configs.mat'); % Lädt die Variablen aus der configs.mat-Datei

% Instanz von VideoReader stellen um aus Datei-Pfad Video laden zu können
videoReader = VideoReader(videoPath);
frameConverter = FrameConverter(brightnessThreshold);
% 1. Video laden und Frames extrahieren
videoFrameExtractor = VideoFrameExtractor(videoReader, frameConverter);
fprintf('Create VideoFrameExtractor object...\n');
extractedBinarizedFrames = videoFrameExtractor.extractFrames();

% Frames aus Video inspizieren
% FrameInspector.displayFrameResolution(extractedVideoFrames);
% FrameInspector.displayFrame(extractedBinarizedFrames, 90);
% FrameInspector.displayPixelValues(extractedVideoFrames, 100);
% FrameInspector.displayFrameRegion(extractedVideoFrames, 90, 300:1000, 350:1650);


% % 2. Frames summieren
% frameSummation = FrameSummation(videoProcessor.extractedFrames);
% summedMatrix = frameSummation.computeSum();
% 
% % 3. Visualisierung
% Visualization.displaySummedMatrix(summedMatrix); % Summierte Matrix anzeigen
% Visualization.displayFrame(videoProcessor.extractedFrames(:, :, 30), 30); % 30. Frame anzeigen

% fprintf('data type of frame before transformation:\n');
                % disp(class(frame)); % Gibt den Datentyp des Frames aus
                % if size(frame, 3) == 3
                %     %fprintf('Convert Frame %d to greyscale...\n', frameIndex);
                %     frame = rgb2gray(frame); % In Graustufen umwandeln
                % end


        % function obj = showFrame(frame)
        %     imshow(obj.extractedFrames(:,:,frame));
        % end