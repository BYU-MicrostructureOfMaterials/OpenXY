
load Settings

if isempty(Settings.ScanFilePath)
    return;
end

%% Set up Settings
Settings.HROIMMethod = 'Simulated'; %{'Simulated', 'Real', 'Dynamic Simulated'}
Settings.DisplayGUI = 1;
Settings.DoParallel = 3;
Settings.Material = 'silicon_BEJ';
%Algorithms = {'fminsearch','crosscor'};  %{'fminsearch','pso','crosscor'};
%AlgorithmNames = {'StrainMin','Crosscor'};
PCs = [0.527904126, 0.924307658, 0.614235106;... %Original
       0.531065288, 0.925589618, 0.612786794;... %Filt
       0.548281923,0.928566771,0.617336204]; %No Filt

PCname = {'Original','Filt','NoFilt'};
Filt = [0 0  0 0;...
        9 90 0 0;...
        0 0  0 0];
load LineScanData

%Read Scan File
[path, name, ext] = fileparts(Settings.ScanFilePath);
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


[folder,file,ext] = fileparts(Settings.ScanFilePath);
[im_folder,im_file,im_ext] = fileparts(Settings.FirstImagePath);

for tet = 1:5
    im_file(end-4) = num2str(tet);
    im_folder(end-7) = num2str(tet);
    Settings.FirstImagePath = fullfile(im_folder,[im_file im_ext]);
    
    %Get Image Names
    if ~isempty(Settings.FirstImagePath)
        Settings.ImageNamesList = GetImageNamesList(Settings.ScanType, ...
            Settings.ScanLength,[Settings.Nx Settings.Ny], Settings.FirstImagePath, ...
            [Settings.XData(1),Settings.YData(1)], [XStep, YStep]);
    end
    
    for pc = 1:3
        Settings.XStar(1:Settings.ScanLength) = PCs(pc,1);
        Settings.YStar(1:Settings.ScanLength) = PCs(pc,2);
        Settings.ZStar(1:Settings.ScanLength) = PCs(pc,3);
        ScanName = ['S01_Sim BEJ Kin SiTet_0_' num2str(tet) ' ' PCname{pc} '.ctf'];
        Settings.OutputPath = fullfile(folder,ScanName);
        Settings.ImageFilter = Filt(pc,:);
        
        %% Run OpenXY
        disp('Starting Analysis')
        HREBSDMain(Settings);
    end
end
