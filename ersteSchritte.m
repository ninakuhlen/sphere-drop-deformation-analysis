%% Prüfe, ob MATLAB die Kamera erkennt:
info = imaqhwinfo;
disp(info.InstalledAdaptors);

%% Erstelle ein Kamera-Objekt:
vid = videoinput('gentl', 1); % 1 ist die ID deiner Kamera

%% Live-Vorschau starten:
preview(vid);

%% Bild aufnehmen:
img = getsnapshot(vid);
imshow(img);