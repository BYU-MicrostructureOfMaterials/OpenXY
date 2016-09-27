clear all
close all
clc

% Before running this you will need to run Run_OpenXY.m and set all the
% settings how you want them. Save the settings file file as
% "Settings_Batch_File". If you are already sure that your
% "Settings_Batch_File" settings are correct then you can comment out the
% Settings section. Change the values in the Settings section of this
% code (to what you want).

load Batch_Analyze_Settings % Choose a settings file you want to use on all your scans

%% Settings
%You can change these to what you want or comment them out

Settings.DisplayGUI = 1;
Settings.ScanType = 'Square'; % 'Square' or 'Hexagonl'
Settings.Material = 'tantalum'; % What material do you want to use
Settings.DoParallel = 3; % How many cores do you want running the jobs
Settings.ROISizePercent = 25; % How large do you want your ROIs
Settings.NumROIs = 20; % Number of ROIs
Settings.ROIStyle = 'Radial'; % 'Radial' or 'Grid'
Settings.DoStrain = 0; % Do you want to calculate strain or not
Settings.CalcDerivatives = 1; % Do you want to calculated dislocaiton density
Settings.HROIMMethod = 'Real'; %'Simulated', 'Real', or 'Dynamic Simulated'
Settings.PlaneFit = 'From Tiff Images'; % Pattern center method
Settings.mperpix = 25.5; % Microns/Pixel
Settings.DoUsePCFile = 0;

Settings.ScanParams.material = 'tantalum';
Settings.PCCal.PCMethod = 'FromTiff';


%% Choose Files to Load
% Select all folders which you want to perfom cross correlation on. Each
% folder you select should contain an .ang file, grain file, and folder
% containing your images. All of these things described should be named the
% same thing. You may also have a .osc and .ohp file in your folder you
% select but it is not necisarry. If you have any extra files besides these
% it might not work.
% For example, you should select a folder named scan1. Inside of scan1 you
% should have scan1.ang, scan1.txt, and a folder named scan1 which contains
% your images

filepath=char(Batch_Analyze_uipickfiles);
numfiles=size(filepath,1); % calculates the number of folders that you chose

%% Set up Settings variable so that OpenXY can be run
% You may need to make some changes to this section if you
% are doing something special (like Oxford scan data). Look at the
% comments for more details.

for sc = 1:numfiles % Loops through all your scans that you selected
    
    %Read in file locations
    curfilepath=deblank(filepath(sc,:));
    ang_file=dir([curfilepath '\*.ctf']); % Normaly you want '\*.ang'. For Oxford you want '\*.ctf'
    Settings.ScanFilePath=[curfilepath '\' ang_file.name];
    [path,name,ext]=fileparts(Settings.ScanFilePath);
    image_file=dir([curfilepath '\' name '\0_0.*']); % Normaly you want '\*x0y0.*'. You may need to change this depending on your nameing system
    Settings.FirstImagePath=[curfilepath '\' name '\' image_file.name];
    Settings.OutputPath=[curfilepath '\OpenXY_Results.ang'];
    
    %Read Scan File
    Settings = rmfield(Settings,'Angles');
    Settings = ImportScanInfo(Settings,[name ext],path);
    
    %Read Grain File
    Settings.grainID = []; Settings.Phase = [];
    [Settings.grainID, Settings.Phase] = GetGrainInfo(Settings.ScanFilePath, Settings.Material, Settings.ScanParams, Settings.Angles, Settings.MisoTol);
    
    %Get ImagesNamesList
    X = unique(Settings.XData);
    Y = unique(Settings.YData);
    
    %Step size in x and y
    if strcmp(Settings.ScanType,'Square')
        XStep = X(2)-X(1);
        if length(Y) > 1
            YStep = Y(2)-Y(1);
        else
            YStep = 0; %Line Scans
        end
    else
        XStep = X(3)-X(1);
        YStep = Y(3)-Y(1);
    end
    
    %Get Image Names
    if ~isempty(Settings.FirstImagePath)
        % Normaly use GetImageNamesList function. If your files are just
        % named #_#.tiff then change to Batch_GetImageNamesList
        Settings.ImageNamesList = Batch_GetImageNamesList(Settings.ScanType, ...  
            Settings.ScanLength,[Settings.Nx Settings.Ny], Settings.FirstImagePath, ...
            [Settings.XData(1),Settings.YData(1)], [XStep, YStep]);
    end
    
%% PC calibration from .tiff images

% Uncomment this section if you want to get PC from your .tiff images.
% Otherwise you should comment this section out.
   
    VHRatio = Settings.VHRatio;
    lscan = Settings.ScanLength;

    Nx = Settings.Nx;
    Ny = Settings.Ny;
    
    if Ny>1
        getdat = [1 2 Nx];% This is usually Nx+1 but sometimes this needs to be Nx (when files are named 0_0.tiff)
    else
        getdat = [1 2];
    end
    for loopvar=1:length(getdat)
        i = getdat(loopvar);
        info = imfinfo(Settings.ImageNamesList{i});

        xistart = strfind(info.UnknownTags.Value,'<pattern-center-x-pu>');
        xifinish = strfind(info.UnknownTags.Value,'</pattern-center-x-pu>');

        thisx = str2double(info.UnknownTags.Value(xistart+length('<pattern-center-x-pu>'):xifinish-1));
        xread(loopvar) = (thisx - (1-VHRatio)/2)/VHRatio;

        yistart = strfind(info.UnknownTags.Value,'<pattern-center-y-pu>');
        yifinish = strfind(info.UnknownTags.Value,'</pattern-center-y-pu>');

        yread(loopvar) = str2double(info.UnknownTags.Value(yistart+length('<pattern-center-y-pu>'):yifinish-1));

        zistart = strfind(info.UnknownTags.Value,'<detector-distance-pu>');
        zifinish = strfind(info.UnknownTags.Value,'</detector-distance-pu>');

        zread(loopvar) = str2double(info.UnknownTags.Value(zistart+length('<detector-distance-pu>'):zifinish-1))/VHRatio;
    end
    
    PTX = mod((1:Nx*Ny) - 1,Nx);
    PTY = floor(((1:Nx*Ny) - 1)/Nx);
    
    xxstep = xread(2) - xread(1);
    xystep = yread(2) - yread(1);
    xzstep = zread(2) - zread(1);
    
    if Ny>1
        yxstep = xread(3) - xread(1);
        yystep = yread(3) - yread(1);
        yzstep = zread(3) - zread(1);

        handles.TiffXstar = xread(1) + PTX*xxstep + PTY*yxstep;
        handles.TiffYstar = yread(1) + PTX*xystep + PTY*yystep;
        handles.TiffZstar = zread(1) + PTX*xzstep + PTY*yzstep;
    else
        handles.TiffXstar = xread(1) + PTX*xxstep;
        handles.TiffYstar = yread(1) + PTX*xystep;
        handles.TiffZstar = zread(1) + PTX*xzstep;
    end
    
    
    Settings.XStar = handles.TiffXstar;
    Settings.YStar = handles.TiffYstar;
    Settings.ZStar = handles.TiffZstar;
    
	Settings.Xstar = handles.TiffXstar;
    Settings.Ystar = handles.TiffYstar;
    Settings.Zstar = handles.TiffZstar;
    
    PCCal.TiffXstar = handles.TiffXstar;
    PCCal.TiffYstar = handles.TiffYstar;
    PCCal.TiffZstar = handles.TiffZstar;
    
    Settings.PCCal = PCCal;

%% PC calibration from .ang

% Uncomment this section if you want the PC from your .ang file to be the
% PC for your entire scan. If you want a plane fit of the PC you will need
% to add more code. Comment this section out if you want to get PC from
% .tiff

%     Settings.XStar = [];
%     Settings.YStar = [];
%     Settings.ZStar = [];
%     
%     Settings.XStar = Settings.ScanParams.xstar*ones(size(Settings.ImageNamesList));
%     Settings.YStar = Settings.ScanParams.ystar*ones(size(Settings.ImageNamesList));
%     Settings.ZStar = Settings.ScanParams.zstar*ones(size(Settings.ImageNamesList));
    
%% Run OpenXY
    disp('Starting Analysis')
    tic
    HREBSDMain(Settings);
    runtime=toc;
    if sc==1
        Run_Time=runtime;
    else
        Run_Time=vertcat(Run_Time,runtime);
    end
    
    Percent_Done=(sc/numfiles)*100
end
