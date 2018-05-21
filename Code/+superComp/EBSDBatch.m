function EBSDBatch(settingsPath,firstImagePath)

load(settingsPath,'Settings')
[~, outName, outExt] = fileparts(Settings.OutputPath);
Settings.OutputPath = [outName, outExt];
disp(Settings.OutputPath)

cd('SuperOpenXY')

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