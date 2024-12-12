% analyze_video_frame.m
% Skript zur Analyse der RGB-Kanäle eines Frames aus einem Video

% load('../configs/configs.mat'); % Lädt die Variablen aus der configs.mat-Datei
% Parameter: Datei und Frame-Nummer
videoPath = '../../testVideo1.avi'; % Pfad zur Videodatei
frameIndex = 130; % Der gewünschte Frame

% Prüfen, ob die Datei existiert
if ~isfile(videoPath)
    error('The file does not exist: %s', videoPath);
end

% Video laden
fprintf('Loading video from: %s\n', videoPath);
video = VideoReader(videoPath);

% Frames extrahieren
fprintf('Extracting frames from the video...\n');
frames = [];
frameIdx = 1;

while hasFrame(video)
    frame = readFrame(video);
    frames(:, :, :, frameIdx) = frame; % 4D-Matrix für RGB-Frames
    frameIdx = frameIdx + 1;
end

fprintf('Extracted %d frames from the video.\n', frameIdx - 1);

% Sicherstellen, dass der gewünschte Frame existiert
if frameIndex > size(frames, 4)
    error('The video contains only %d frames. Frame %d is out of range.', size(frames, 4), frameIndex);
end

% Gewünschten Frame auswählen
frame = frames(:, :, :, frameIndex);

% RGB-Kanäle analysieren
fprintf('Analyzing RGB channels for frame %d...\n', frameIndex);

% Kanäle extrahieren
R = frame(:, :, 1); % Roter Kanal
G = frame(:, :, 2); % Grüner Kanal
B = frame(:, :, 3); % Blauer Kanal

% Prüfen, ob die Kanäle identisch sind
if isequal(R, G) && isequal(G, B)
    fprintf('All RGB channels are identical. No need for rgb2gray.\n');
else
    fprintf('RGB channels are not identical. Consider using rgb2gray.\n');
end

% Prüfen, ob einer der Kanäle nur aus Nullen besteht
if all(R(:) == 0)
    fprintf('The Red channel is entirely zeros.\n');
end
if all(G(:) == 0)
    fprintf('The Green channel is entirely zeros.\n');
end
if all(B(:) == 0)
    fprintf('The Blue channel is entirely zeros.\n');
end

% Debug-Ausgabe der Kanäle
fprintf('Red channel: Min = %d, Max = %d\n', min(R(:)), max(R(:)));
fprintf('Green channel: Min = %d, Max = %d\n', min(G(:)), max(G(:)));
fprintf('Blue channel: Min = %d, Max = %d\n', min(B(:)), max(B(:)));

% Visualisierung der Kanäle
figure;
subplot(1, 3, 1);
imshow(R, []);
title('Red Channel');

subplot(1, 3, 2);
imshow(G, []);
title('Green Channel');

subplot(1, 3, 3);
imshow(B, []);
title('Blue Channel');

fprintf('RGB channel analysis completed.\n');
