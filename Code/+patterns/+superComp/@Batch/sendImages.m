function sendImages(obj)
%TODO Add this
disp('Sending Images')

Settings = obj.Settings;

localPath = fileparts(Settings.FirstImagePath);
switch class(Settings.patterns)
    case 'patterns.ImagepatternProvider'
        len = length(localPath);
        fileNames = cellfun(@(x) x(len+2:end),...
            Settings.patterns.imageNames, 'UniformOutput', false);
        
    case 'patterns.DummyPatternProvider'
        error('OpenXY:SuperComputer:ImagesNotFound', 'Cannot find images');

    otherwise
        fileNames = Settings.patterns.fileName;
        
end


pathComponents = strsplit(localPath,filesep);
folderName = strrep(pathComponents{end}, ' ', '\ ');

command = ['mkdir ~/compute/OpenXY;mkdir ~/compute/OpenXY/' folderName];
obj.connection = ssh2_command(obj.connection,command);
obj.connection = scp_put(obj.connection, fileNames,...
    ['~/compute/OpenXY/' folderName],localPath);
end
