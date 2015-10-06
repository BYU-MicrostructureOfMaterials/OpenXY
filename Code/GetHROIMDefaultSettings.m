function Settings = GetHROIMDefaultSettings()
%GETHROIMDEFAULTSETTINGS
%Settings = GetHROIMDefaultSettings()
%Stores and returns default settings for the Settings structure used in the
%HR-EBSD code. Includes defaults to Advanced Settings (accessed
%through the advanced settings button.
%Edit values within the file to make them the default for local copies of
%the code.

%% Main GUI
NumberOfCores = feature('numCores');
%MainGUI Settings
Settings.ScanFilePath = '';
Settings.FirstImagePath = '';
Settings.OutputPath = '';
Settings.ScanType = 'Square'; %{'Square','Hexagonal'};
Settings.Material = 'Auto-detect'; %Options from GetMaterialsList.m
Settings.DoParallel = NumberOfCores - 1;
Settings.DoShowPlot = false;
Settings.DoPCStrainMin = false;
Settings.ImageTag = false;

%% ROI/Filter Settings
%ROI Settings
Settings.ROISizePercent = 25;
Settings.NumROIs = 23;
Settings.ROIStyle = 'Grid'; %{'Grid','Radial','Intensity'}
Settings.ROIFilter = [2 50 1 1];
%Filter Settings
Settings.ImageFilterType='standard'; %{'standard','localthresh'}
Settings.ImageFilter = [9 90 0 0];

%% Advanced Settings
%HROIM Settings
Settings.HROIMMethod = 'Real'; %{'Simulated', 'Real'}, %Someday will add Hybrid
Settings.IterationLimit = 6;
Settings.RefImageInd = 0;
Settings.StandardDeviation = 2;
Settings.MisoTol = 5; %Degrees
Settings.GrainRefImageType = 'IQ > Fit > CI'; %{'Min Kernel Avg Miso','IQ > Fit > CI'} - more may yet be added, eg. %'Min Fit','1/Fit * CI', etc.' 
%Dislocation Density Settings
Settings.CalcDerivatives = false;
Settings.DoDDS = false;
Settings.NumSkipPts = 0;
Settings.IQCutoff = 0;
Settings.DDSMethod = 'Nye-Kroner'; %{'Nye-Kroner', 'Nye-Kroner (Pantleon)','Distortion Matching'}
%Kernel Average Misorientation
Settings.KernelAvgMisoPath = '';
%Calculation Options
Settings.EnableProfiler = 0;

%% Microscope Settings
Settings.AccelVoltage = 20; %keV
Settings.SampleTilt = 70*pi/180; %degrees
Settings.SampleAzimuthal = 0*pi/180; %degrees
Settings.CameraElevation = 10*pi/180; %degrees
Settings.CameraAzimuthal = 0*pi/180; %degrees
Settings.mperpix = 25;

%% Old Variables
Settings.DoUsePCFile = 0;
Settings.PCFilePath = [];
%Options are: {'Real Sample','Real Crystal','Collin Sample','Collin Crystal'}; 
Settings.FCalcMethod = 'Collin Crystal';



