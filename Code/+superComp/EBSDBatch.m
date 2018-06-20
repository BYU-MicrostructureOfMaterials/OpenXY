function EBSDBatch(settingsPath, firstImagePath)

load(settingsPath,'Settings')

outputPath = strrep(Settings.OutputPath, '\', '/');
[~, outName, outExt] = fileparts(outputPath);

firstImagePath = fullfile(pwd, strrep(firstImagePath, '\', '/'));

scanFilePath = strrep(Settings.ScanFilePath, '\', '/');
[~, scanName, scanExt] = fileparts(scanFilePath);

cd('Code')

Settings.ScanFilePath = ['~/compute/OpenXY/' scanName scanExt];
Settings.OutputPath = ['~/compute/OpenXY/' outName, outExt];
Settings.FirstImagePath = firstImagePath;
Settings.ImageNamesList = ImportImageNamesList(Settings);
Settings.OutputPath = './Out.ang';
Settings.DisplayGUI = false;
Settings.DoParallel = 1;
try
HREBSDMain(Settings);
catch ME
    disp(ME.getReport)
end