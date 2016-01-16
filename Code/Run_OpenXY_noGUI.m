
load Settings

if isempty(Settings.ScanFilePath)
    return;
end

%% Set up Settings
Settings.HROIMMethod = 'Simulated'; %{'Simulated', 'Real', 'Dynamic Simulated'}
Settings.DisplayGUI = 1;
Settings.Material = 'silicon_BEJ';
Algorithms = {'fminsearch','crosscor'};  %{'fminsearch','pso','crosscor'};
AlgorithmNames = {'StrainMin','Crosscor'};
PCs = [0.524882875, 0.888725907,0.613331067;
        0.526360583, 0.922586955, 0.614599788];
scans = {'i02','S01'};
Cals = {'003',7:9; '333',1:9};
load LineScanData

for sc = 1:2
    scan = scans{sc};
    Settings.ScanFilePath = ScanData.(scan).ScanFilePath;
    Settings.FirstImagePath = ScanData.(scan).FirstImagePath;
    [path, name, ext] = fileparts(Settings.ScanFilePath);
    Settings = ImportScanInfo(Settings,[name ext],path);
    
    
    
    for al = 1:2
        Algorithm = Algorithms{al};
        AlgorithmName = AlgorithmNames{al};
        
        for cal = 1:2
            CalPoints = Cals{cal,2};
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