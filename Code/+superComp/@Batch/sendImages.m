function sendImages(obj)
%TODO Add this
disp('Sending Images')

Settings = obj.Settings;
path = fileparts(Settings.FirstImagePath);
path = strsplit(path,filesep);
folderName = path{end};

command = ['mkdir ~/compute/OpenXY;mkdir ~/compute/OpenXY/' folderName];
obj.connection = ssh2_command(obj.connection,command);
obj.connection = scp_put(obj.connection, Settings.ImageNamesList,...
    ['~/compute/OpenXY/' folderName]);
end