% Enter the path of the folder/file
fileName = "30_deg_view_B"; 
nameORpath = "..\res\videos\"+ fileName + "_processed.avi";
% check if the folder exists
if exist(nameORpath) == 7
    disp('folder exists')
else
    disp('folder does not exists')
end
% check if the file exists
if exist(nameORpath) == 2
    disp('file exists')
else
    disp('file does not exists')
end
% check if you have write access
[status, attributes] = fileattrib(nameORpath);
if status && attributes.UserWrite
    disp('You have write access');
else
    disp("You don't have write access");
end