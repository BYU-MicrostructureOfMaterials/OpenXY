function EBSDBatch(settingsPath,firstImagePath)

load(settingsPath,'Settings')
outputPath = strrep(Settings.OutputPath, '\', '/');
[~, outName, outExt] = fileparts(outputPath);
Settings.OutputPath = [outName, outExt];
disp(Settings.OutputPath)
disp(firstImagePath)

cd('Code')

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