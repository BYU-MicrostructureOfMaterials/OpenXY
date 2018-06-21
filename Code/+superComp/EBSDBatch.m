function EBSDBatch(settingsPath, firstImagePath, jobInd)
%EBSDBATCH Starts a batch on a supercomputer.

load(settingsPath,'Settings')

job_inds = Settings.indVectors{jobInd};

outputPath = strrep(Settings.OutputPath, '\', '/');
[~, outName, outExt] = fileparts(outputPath);

firstImagePath = fullfile(pwd, strrep(firstImagePath, '\', '/'));

scanFilePath = strrep(Settings.ScanFilePath, '\', '/');
[~, scanName, scanExt] = fileparts(scanFilePath);

addpath('Code')

Settings.ScanFilePath = ['~/compute/OpenXY/' scanName scanExt];
Settings.OutputPath = ...
    ['~/compute/OpenXY/' outName, '_', num2str(jobInd), outExt];
Settings.FirstImagePath = firstImagePath;
Settings.ImageNamesList = ImportImageNamesList(Settings);
Settings.DisplayGUI = false;
Settings.DoParallel = 1;
try
HREBSDMain(Settings, job_inds);
catch ME
    disp(ME.getReport)
end