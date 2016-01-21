
load Settings

if isempty(Settings.ScanFilePath)
    return;
end

%% Set up Settings
Settings.HROIMMethod = 'Simulated'; %{'Simulated', 'Real', 'Dynamic Simulated'}
Settings.DisplayGUI = 1;
Settings.DoParallel = 3;
Settings.Material = 'silicon_BEJ';
Algorithms = {'fminsearch','crosscor'};  %{'fminsearch','pso','crosscor'};
AlgorithmNames = {'StrainMin','Crosscor'};
PCs = [0.524882875, 0.888725907,0.613331067;
        0.526360583, 0.922586955, 0.614599788];
scans = {'i02','S01'};
Cals = {'003',7:9; '333',1:9};
Settings = rmfield(Settings,'ScanData');
load LineScanData

for sc = 2:2
    scan = scans{sc};
    Settings.ScanFilePath = ScanData.(scan).ScanFilePath;
    Settings.FirstImagePath = ScanData.(scan).FirstImagePath;
    
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
    %Get Image Names
    if ~isempty(Settings.FirstImagePath)
        Settings.ImageNamesList = GetImageNamesList(Settings.ScanType, ...
            Settings.ScanLength,[Settings.Nx Settings.Ny], Settings.FirstImagePath, ...
            [Settings.XData(1),Settings.YData(1)], [XStep, YStep]);
    end
    
    for al = 1:1
        Algorithm = Algorithms{al};
        AlgorithmName = AlgorithmNames{al};
        
        for cal = 1:2
            CalPoints = ScanData.(scan).CalPoints(Cals{cal,2});
            CalName = Cals{cal,1};
            ScanName = [scan ' BEJ Kin ' AlgorithmName ' ' CalName '.ctf'];
            Settings.OutputPath = fullfile(ScanData.(scan).folder,ScanName);
            
            disp(['Starting Scan ' ScanName])

            %% PC Calibration
            S01Points = [4 22 28;... S01 1st band
                        99 114 138;... S01 2nd band
                        212,224,231]; %S01 3rd band
            i02Points = [9 20 27;... i02 1st band
                        96 108 121;... i02 2nd band
                        204 220 231]; %i02 3rd band
            Settings.CalibrationPointIndecies = CalPoints;
            ScanParams = Settings.ScanParams;
              
            Settings.XStar = [];
            Settings.YStar = [];
            Settings.ZStar = [];
            if 0
                ScanParams.xstar = Settings.ScanParams.xstar;
                ScanParams.ystar = Settings.ScanParams.ystar;
                ScanParams.zstar = Settings.ScanParams.zstar;
            else
                ScanParams.xstar = PCs(sc,1);
                ScanParams.ystar = PCs(sc,2);
                ScanParams.zstar = PCs(sc,3);
            end
            Settings.CalibrationPointsPC = zeros(length(CalPoints),3);
            psize = Settings.PhosphorSize;

            if 1
                Settings.CalibrationPointsPC = PCCalibration(Settings,ScanParams,Algorithm);
                
                %Apply Naive Plane Fit
                MeanXstar = mean(Settings.CalibrationPointsPC(:,1)+(Settings.XData(Settings.CalibrationPointIndecies))/psize);
                MeanYstar = mean(Settings.CalibrationPointsPC(:,2)-(Settings.YData(Settings.CalibrationPointIndecies))/psize*sin(Settings.SampleTilt));
                MeanZstar = mean(Settings.CalibrationPointsPC(:,3)-(Settings.YData(Settings.CalibrationPointIndecies))/psize*cos(Settings.SampleTilt));
            else
                MeanXstar = Settings.PCCal.MeanXstar;
                MeanYstar = Settings.PCCal.MeanYstar;
                MeanZstar = Settings.PCCal.MeanZstar;
            end

            Settings.XStar = MeanXstar-(Settings.XData)/psize;
            Settings.YStar = MeanYstar+(Settings.YData)/psize*sin(Settings.SampleTilt);
            Settings.ZStar = MeanZstar+(Settings.YData)/psize*cos(Settings.SampleTilt);

            %% Run OpenXY
            disp('Starting Analysis')
            HREBSDMain(Settings);
        end
    end
end
