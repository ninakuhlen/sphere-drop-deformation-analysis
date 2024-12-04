# sphere-drop-deformation-analysis
An image processing study project about a sphere drop deformation analysis

## Requirements
The procedures described in this document assume that the following software and hardware is present:
- MATLAB R2017a (9.2.0.556344) 64-bit with the Image Acquisition Toolbox version 5.2 (R2017a)
- Image Acquisition Toolbox Support Package for GenICam Interface version 17.2.0.0, which enables you to acquire video and images from GenTL-compliant cameras 
- Image Acquisition Toolbox Support Package for GigE Vision Hardware version 17.2.0.0, which is required for advanced IP address configuration and troubleshooting of GigE cameras
- Basler pylon Camera Software Suite 5.0.11 including the pylon GigE and USB GenTL 64-bit producers
- Basler GigE and/or Basler USB 3.0 cameras 
- GigE network card and/or USB 3.0 host controller card recommended by Basler 
- GigE and or USB 3.0 cables recommended by Basler

## Troubleshooting: Kamera wird in MATLAB nicht erkannt
### Problem
Die Kamera funktioniert im Pylon Viewer, wird jedoch in MATLAB nicht erkannt. Nach der Ausführung von:
<code>info = imaqhwinfo('gentl');</code>
erscheint die Warnung
<code>Warning: No devices were detected for the 'gentl' adaptor.</code>

### Ursache
MATLAB benötigt Zugriff auf die GenTL-Treiber (.cti-Dateien) der Basler Kamera, die im Pylon SDK enthalten sind.
Diese Treiber müssen über eine Umgebungsvariable (GENICAM_GENTL64_PATH oder GENICAM_GENTL32_PATH) dem System bekannt gemacht werden.
Ohne diese Konfiguration kann MATLAB die Kamera nicht erkennen.

### Lösung
#### Schritt 1: Umgebungsvariable setzen
1. Kommandozeilenfenster mit Administratorrechten öffnen:
Unter Windows das Startmenü öffnen, "cmd" suchen, Rechtsklick auf "Eingabeaufforderung" und "Als Administrator ausführen" wählen.
2. Zum Verzeichnis der GenTL-Treiber navigieren:
Das Verzeichnis mit den .cti-Dateien befindet sich normalerweise im Runtime-Ordner der Pylon-Installation.
Der genaue Ordnername kann je nach Systemarchitektur und Pylon-Version variieren:
- Beispiel für 64-Bit-Systeme:
    `C:\Program Files\Basler\pylon X.X.X\Runtime\x64`
- Beispiel für 32-Bit-Systeme:
    `C:\Program Files\Basler\pylon X.X.X\Runtime\Win32`
- `X.X.X` ist durch die installierte Version der Pylon-Software zu ersetzen.
3. Die Umgebungsvariable setzen:
- Beispiel für 64-Bit-Systeme:
    <code>setx GENICAM_GENTL64_PATH "%cd%" /M</code>
- Beispiel für 32-Bit-Systeme:
    <code>setx GENICAM_GENTL32_PATH "%cd%" /M</code>
4. Neustart des Systems, um die Änderungen wirksam zu machen.
#### Schritt 2: Überprüfung in MATLAB
1. Überprüfung der gesetzten Umgebungsvariable:
<code>getenv('GENICAM_GENTL64_PATH')</code>
oder
<code>getenv('GENICAM_GENTL32_PATH')</code>
Die Ausgabe sollte den Pfad zum Verzeichnis der .cti-Dateien anzeigen.

2. Test der Kameraerkennung:
<code>info = imaqhwinfo('gentl');
disp(info.DeviceInfo);</code>
Die Kamera sollte korrekt erkannt werden.

### Hinweise
- Der Pylon Viewer darf während des Zugriffs durch MATLAB nicht geöffnet sein, da dies zu Konflikten führen kann.
- Der Verzeichnisname des GenTL-Treiber-Ordners kann je nach System und Pylon-Version unterschiedlich sein. Es ist wichtig, vor der Konfiguration den genauen Ordnerpfad zu prüfen.

### Quellen
- https://learn.microsoft.com/de-de/windows-server/administration/windows-commands/setx
- https://de.mathworks.com/help/matlab/ref/getenv.html
