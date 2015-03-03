function Settings = GetHROIMDefaultSettings()
%GETHROIMDEFAULTSETTINGS
%Settings = GetHROIMDefaultSettings()
%Stores and returns default settings for the Settings structure used in the
%HR-EBSD Green Machine code. Includes defaults to Advanced Settings (accessed
%through the advanced settings button.
%Edit values within the file to make them the default for local copies of
%the Green Machine code.

%% Main GUI
NumberOfCores = feature('numCores');

Settings.AccelVoltage = 20; %keV
Settings.SampleTilt = 70*pi/180; %degrees
Settings.SampleAzimuthal = 0*pi/180; %degrees
Settings.CameraElevation = 10*pi/180; %degrees
Settings.CameraAzimuthal = 0*pi/180; %degrees
Settings.AngFilePath = 'No file selected';
Settings.GrainFilePath = 'No file selected';
Settings.CustomFilePath = 'No file selected';
Settings.FirstImagePath = 'No file selected';
Settings.OutputPath = 'No file selected';
Settings.DoUsePCFile = 0;
Settings.DoPCStrainMin = 0;
Settings.PCFilePath = [];
Settings.DoParallel = NumberOfCores - 1;
Settings.DoShowPlot = 0;
Settings.ImageFilterType='standard';

%Options are in output by GetMaterialsList.m
Settings.Material = 'grainfile';

%Options are: {'Square','Hexagonal','L'};
Settings.ScanType = 'Square';

%% Advanced Settings

Settings.ROISizePercent = 25;
Settings.NumROIs = 23;

%Options are: {'Grid','Radial'}
Settings.ROIStyle = 'Radial';

Settings.ROIFilter = [2 50 1 1]; %[lcutoff ucutoff yes/no yes/no];
Settings.ImageFilter = [9 90 0 0];
% Settings.ImageFilter = [2 150 0 0];

%Options are: 'Simulated', 'Real-Single Ref', 'Real-Grain Ref', %Someday will add Hybrid - also
%called by Josh the "unholy alliance"
Settings.HROIMMethod = 'Simulated';

%Derivatives Settings
Settings.CalcDerivatives = 0;
Settings.NumSkipPts = 0;
Settings.MisoTol = 5; %Degrees
Settings.IQCutoff = 0;

Settings.IterationLimit = 6;
Settings.RefImageInd = 0;
Settings.DoDDS = 0;
Settings.DDSMethod = 1;


%Options are: {'Real Sample','Real Crystal','Collin Sample','Collin Crystal'}; 
Settings.FCalcMethod = 'Collin Crystal';

%Options are: {'Min Kernel Avg Miso','IQ > Fit > CI'} - more may yet be added, eg.
%'Min Fit','1/Fit * CI', etc.' 
Settings.GrainRefImageType = 'IQ > Fit > CI';
Settings.KernelAvgMisoPath = [];
Settings.StandardDeviation = 2;





