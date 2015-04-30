function [ Settings ] = MergeSettings( Settings, NewSettings )
%MERGESETTINGS Combines two Settings files into one. Copies only initialization data for GUIs
%   INPUT:
%       Settings: Original settings structure to be changed. Should be complete
%       NewSettings: New Settings structure to be copied into Settings
%   OUTPUT:
%       Settings: Merged Settings structure

function copyParam(ParamName,OldName)
if isfield(Settings,ParamName) && isfield(NewSettings,ParamName)
    Settings.(ParamName) = NewSettings.(ParamName);
end
% For backwards compatibility when reading in older Settings structures
% (i.e. ScanFilePath used to be called AngFilePath)
if nargin == 2
    if isfield(Settings,ParamName) && isfield(NewSettings,OldName)
       Settings.(ParamName) = NewSettings.(OldName); 
    end
end
end

%% Main GUI
%Scan Data
copyParam('ScanFilePath','AngFilePath');
copyParam('FirstImagePath');
copyParam('OutputPath');
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
copyParam('ImageFilter');
copyParam('ImageFilterType');

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


end

