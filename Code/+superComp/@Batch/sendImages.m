function sendImages(obj)
%TODO Add this
disp('Sending Images')

Settings = obj.Settings;
localPath = fileparts(Settings.FirstImagePath);
len = length(localPath);

pathComponents = strsplit(localPath,filesep);

fileNames = cellfun(@(x) x(len+2:end), Settings.ImageNamesList,...
    'UniformOutput', false);

folderName = strrep(pathComponents{end}, ' ', '\ ');

command = ['mkdir ~/compute/OpenXY;mkdir ~/compute/OpenXY/' folderName];
obj.connection = ssh2_command(obj.connection,command);
obj.connection = scp_put(obj.connection, fileNames,...
    ['~/compute/OpenXY/' folderName],localPath);
end