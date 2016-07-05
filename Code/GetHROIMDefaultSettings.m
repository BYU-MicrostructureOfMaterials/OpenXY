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
Settings.Material = 'Scan File'; %Options from GetMaterialsList.m
Settings.DoParallel = NumberOfCores - 1;
Settings.DoShowPlot = false;
Settings.ImageTag = false;
Settings.DisplayGUI = true;

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
Settings.DoStrain = 1;
Settings.HROIMMethod = 'Real'; %{'Simulated', 'Real'}, %Someday will add Hybrid
Settings.IterationLimit = 6;
Settings.RefImageInd = 0;
Settings.StandardDeviation = 2;
Settings.MisoTol = 5; %Degrees
Settings.GrainRefImageType = 'IQ > Fit > CI'; %{'Min Kernel Avg Miso','IQ > Fit > CI','Manual'} - more may yet be added, eg. %'Min Fit','1/Fit * CI', etc.' 
Settings.GrainMethod = 'Grain File'; %{'Grain File','Find Grains'}
Settings.MinGrainSize = 0;
%Dislocation Density Settings
Settings.CalcDerivatives = false;
Settings.NumSkipPts = 0;
Settings.IQCutoff = 0;
%Split Dislocation Density
Settings.DoDDS = false;
Settings.rdoptions.minscheme = 2; %{'No weighting', 'Energy','CRSS'}
Settings.rdoptions.L1 = 1;
Settings.rdoptions.x0type = 0;
Settings.rdoptions.Pantleon = 1; 
%Kernel Average Misorientation
Settings.KernelAvgMisoPath = '';
%Calculation Options
Settings.EnableProfiler = 0;

%% PC Calibration
Settings.PlaneFit = 'Naive';

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



