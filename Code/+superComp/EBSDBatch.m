function EBSDBatch(jobInd)
%EBSDBATCH Starts a batch on a supercomputer.

loaded = load('./Settings.mat', 'Settings');
Settings = loaded.Settings;

job_inds = Settings.indVectors{jobInd};

outputPath = strrep(Settings.OutputPath, '\', '/');
[~, outName, outExt] = fileparts(outputPath);

firstImagePath = fullfile(pwd, Settings.FirstImagePath);

scanFilePath = strrep(Settings.ScanFilePath, '\', '/');
[~, scanName, scanExt] = fileparts(scanFilePath);

addpath('Code')

Settings.ScanFilePath = ['~/compute/OpenXY/' scanName scanExt];
if ~exist(outName, 'dir')
    mkdir(outName)
end
Settings.OutputPath = ...
    ['~/compute/OpenXY/' outName '/' outName '_' num2str(jobInd) outExt];
Settings.FirstImagePath = firstImagePath;
Settings.patterns = patterns.makePatternProvider(Settings);
Settings.DisplayGUI = false;
Settings.DoParallel = 1;
try
HREBSDMain(Settings, job_inds);
catch ME
    disp(ME.getReport)
end
