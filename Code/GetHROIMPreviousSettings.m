function Settings = GetHROIMPreviousSettings()

tempfile = load([pwd '\Settings.mat']);
PrevSettings = tempfile.Settings;
clear tempfile

function copyParam(ParamName)
if isfield(Settings,ParamName) && isfield(PrevSettings,ParamName)
    Settings.(ParamName) = PrevSettings.(ParamName);
end
end

%% Main GUI
%MainGUI Settings
copyParam('ScanType');
copyParam('Material');
copyParam('DoParallel');
copyParam('DoShowPlot');
copyParam('DoPCStrainMin');

%% ROI/Filter Settings
%ROI Settings
copyParam('ROISizePercent');
copyParam('NumROIs');
copyParam('ROIStyle');
copyParam('ROIFilter');
%Filter Settings
copyParam('ROIFilter');
copyParam('ROIFilter');
Settings.ImageFilterType='standard'; %{'standard','localthresh'}
Settings.ImageFilter = [9 90 0 0];

%% Advanced Settings
%HROIM Settings
copyParam('HROIMMethod');
copyParam('IterationLimit');
copyParam('RefImageInd');
copyParam('StandardDeviation');
copyParam('MisoTol');
copyParam('GrainRefImageType');

%Dislocation Density Settings
copyParam('CalcDerivatives');
copyParam('DoDDS');
copyParam('NumSkipPts');
copyParam('IQCutoff');
copyParam('DDSMethod');

%Kernel Average Misorientation
copyParam('KernelAvgMisoPath');

%% Microscope Settings
copyParam('AccelVoltage');
copyParam('SampleTilt');
copyParam('SampleAzimuthal');
copyParam('CameraElevation');
copyParam('CameraAzimuthal');


%% Main Settings


Settings.AccelVoltage = PrevSettings.AccelVoltage; %keV
Settings.SampleTilt = PrevSettings.SampleTilt; %radians
Settings.SampleAzimuthal = PrevSettings.SampleAzimuthal; %radians
Settings.CameraElevation = PrevSettings.CameraElevation; %radisns
Settings.CameraAzimuthal = PrevSettings.CameraAzimuthal; %radians
Settings.ScanFilePath = PrevSettings.ScanFilePath;
Settings.GrainFilePath = PrevSettings.GrainFilePath;
if isfield(PrevSettings,'CustomFilePath')
    Settings.CustomFilePath = PrevSettings.CustomFilePath;
end
Settings.FirstImagePath = PrevSettings.FirstImagePath;
Settings.OutputPath = PrevSettings.OutputPath;
Settings.DoUsePCFile = PrevSettings.DoUsePCFile;
if isfield(PrevSettings, 'PCFilePath')
    Settings.PCFilePath = PrevSettings.PCFilePath;
end
if isfield(PrevSettings, 'DoPCStrainMin')
    Settings.DoPCStrainMin = PrevSettings.DoPCStrainMin;
end
Settings.DoParallel = PrevSettings.DoParallel;
Settings.DoShowPlot = PrevSettings.DoShowPlot;
Settings.ImageFilterType=PrevSettings.ImageFilterType;
Settings.Material = PrevSettings.Material;
Settings.ScanType = PrevSettings.ScanType;

%% Advanced Settings
Settings.ROISizePercent = PrevSettings.ROISizePercent;
Settings.NumROIs = PrevSettings.NumROIs;
Settings.ROIStyle = PrevSettings.ROIStyle;
Settings.ROIFilter = PrevSettings.ROIFilter; %[lcutoff ucutoff yes/no yes/no];
Settings.ImageFilter = PrevSettings.ImageFilter;
% Settings.ImageFilter = [2 150 0 0];
Settings.HROIMMethod = PrevSettings.HROIMMethod;
Settings.CalcDerivatives = PrevSettings.CalcDerivatives;
Settings.NumSkipPts = PrevSettings.NumSkipPts;
Settings.MisoTol = PrevSettings.MisoTol; %Degrees
Settings.IQCutoff = PrevSettings.IQCutoff;
Settings.IterationLimit = PrevSettings.IterationLimit;
if isfield(PrevSettings, 'RefImageInd')
    Settings.RefImageInd = PrevSettings.RefImageInd;
end
if isfield(PrevSettings, 'DoDDS')
    Settings.DoDDS = PrevSettings.DoDDS;
else
    Settings.DoDDS = 0;
end
Settings.FCalcMethod = PrevSettings.FCalcMethod;
Settings.GrainRefImageType = PrevSettings.GrainRefImageType;
Settings.KernelAvgMisoPath = PrevSettings.KernelAvgMisoPath;
Settings.StandardDeviation = PrevSettings.StandardDeviation;
end


