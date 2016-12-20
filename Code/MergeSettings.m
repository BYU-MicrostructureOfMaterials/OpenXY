function [ Settings ] = MergeSettings( Settings, NewSettings )
%MERGESETTINGS Combines two Settings files into one. Copies only initialization data for GUIs
%   INPUT:
%       Settings: Original settings structure to be changed. Should be complete
%       NewSettings: New Settings structure to be copied into Settings
%   OUTPUT:
%       Settings: Merged Settings structure

function copyParam(ParamName,ValidEntries, OldName)
if isfield(Settings,ParamName) && isfield(NewSettings,ParamName)
    
    if nargin == 2
        if ~isempty(ValidEntries)
            if strmatch(num2str(NewSettings.(ParamName)),ValidEntries,'exact')
                Settings.(ParamName) = NewSettings.(ParamName);
            end
        end
    else
        Settings.(ParamName) = NewSettings.(ParamName);
    end
end


% For backwards compatibility when reading in older Settings structures
% (i.e. ScanFilePath used to be called AngFilePath)
if nargin == 3
    if isfield(Settings,ParamName) && isfield(NewSettings,OldName)
       Settings.(ParamName) = NewSettings.(OldName); 
    end
end
end

%% Main GUI
%Scan Data
copyParam('ScanFilePath',{},'AngFilePath');
copyParam('FirstImagePath');
copyParam('OutputPath');
%MainGUI Settings
copyParam('ScanType',{'Square','Hexagonal'});
copyParam('Material',GetMaterialsList);
copyParam('DoParallel');
copyParam('DoShowPlot');
copyParam('DoPCStrainMin');
copyParam('GrainVals');

%% ROI/Filter Settings
%ROI Settings
copyParam('ROISizePercent');
copyParam('NumROIs');
copyParam('ROIStyle',{'Grid','Radial','Intensity'});
copyParam('ROIFilter');
%Filter Settings
copyParam('ImageFilter');
copyParam('ImageFilterType',{'standard','localthresh'});

%% Advanced Settings
%HROIM Settings
copyParam('DoStrain');
copyParam('HROIMMethod',{'Simulated', 'Real', 'Dynamic Simulated'});
copyParam('IterationLimit');
copyParam('RefImageInd');
copyParam('StandardDeviation');
copyParam('MisoTol');
copyParam('GrainRefImageType',{'Min Kernel Avg Miso','IQ > Fit > CI','Manual'});
copyParam('GrainMethod',{'Grain File','Find Grains'});
copyParam('MinGrainSize');

%Dislocation Density Settings
copyParam('GNDMethod',{'Full','Partial','Orientation'});
copyParam('CalcDerivatives');
copyParam('DoDDS');
copyParam('NumSkipPts');
copyParam('IQCutoff');
copyParam('DDSMethod',{'Nye-Kroner', 'Nye-Kroner (Pantleon)','Distortion Matching'});
copyParam('rdoptions')

%Kernel Average Misorientation
copyParam('KernelAvgMisoPath');

%% Microscope Settings
copyParam('AccelVoltage');
copyParam('SampleTilt');
copyParam('SampleAzimuthal');
copyParam('CameraElevation');
copyParam('CameraAzimuthal');
copyParam('mperpix');

%% Other
if isfield(NewSettings,'PCList')
    Settings.PCList = NewSettings.PCList;
end
if isfield(NewSettings,'ScanData')
    Settings.ScanData = NewSettings.ScanData;
end
if isfield(NewSettings,'grainID') && strcmp(Settings.GrainRefImageType,'Manual')
    Settings.grainID = NewSettings.grainID;
end
if isfield(NewSettings,'Inds')
    Settings.Inds = NewSettings.Inds;
end
if isfield(NewSettings,'RefInd')
    Settings.RefInd = NewSettings.RefInd;
end
if isfield(NewSettings,'ScanParams')
    Settings.ScanParams = NewSettings.ScanParams;
end

%% Pull in Previous Data
if isfield(NewSettings,'data')
    sel = questdlg('The Analysis file has previous data. Would you like to import it?','Previous Analysis Detected','Yes','No','Yes');
    if strcmp(sel,'Yes')
        Settings.data = NewSettings.data;
        Settings.NewAngles = NewSettings.NewAngles;
    end
end
    

end

