function PCData = PCStrainMinimization(Settings,PlaneFit,Inds)
    if nargin < 3
        %Select Calibration Points
        try
            Inds = SelectCalibrationPoints([Settings.Nx,Settings.Ny],Settings.IQ,Settings.Angles);
        catch ME
            rethrow(ME)
        end
    end
    
    %Perform Strain Minimization PC Calibration
    Algorithm = 'fminsearch';
    npoints = length(Inds);
    CalibrationPointsPC = zeros(npoints,3);
    if Settings.DoParallel > 1
        NumCores = Settings.DoParallel;
        try
            ppool = gcp('nocreate');
            if isempty(ppool)
                parpool(NumCores);
            end
        catch
            ppool = matlabpool('size');
            if ~ppool
                matlabpool('local',NumCores); 
            end
        end
        pctRunOnAll javaaddpath('java')
        ppm = ParforProgMon( 'Point Calibration ', npoints,1,400,50 );
        
        parfor (i=1:npoints)
            PCref = PCMinSinglePattern(Settings, Settings.ScanParams, Inds(i), Algorithm);
            disp(['Point: ' num2str(i)])
            CalibrationPointsPC(i,:) = PCref';
            ppm.increment();
        end
        ppm.delete();
    else
        %Single Processor Calculation
        for i = 1:npoints
            PCref = PCMinSinglePattern(Settings, Settings.ScanParams, Inds(i), Algorithm);
            disp(['Point: ' num2str(i)])
            CalibrationPointsPC(i,:) = PCref';
        end
    end
    
    %Calculate Mean Pattern Center
    if strcmp(PlaneFit,'Naive')
        PCData.MeanXStar = mean(CalibrationPointsPC(:,1)+(Settings.XData(Inds))/Settings.PhosphorSize);
		PCData.MeanYStar = mean(CalibrationPointsPC(:,2)-(Settings.YData(Inds))/Settings.PhosphorSize*sin(Settings.SampleTilt-Settings.CameraElevation));
		PCData.MeanZStar = mean(CalibrationPointsPC(:,3)-(Settings.YData(Inds))/Settings.PhosphorSize*cos(Settings.SampleTilt-Settings.CameraElevation));
    else
        PCData.MeanXStar = mean(CalibrationPointsPC(:,1));
        PCData.MeanYStar = mean(CalibrationPointsPC(:,2));
        PCData.MeanZStar = mean(CalibrationPointsPC(:,3));
    end
    PCData.CalibrationPointsPC = CalibrationPointsPC;
    PCData.CalibrationIndices = Inds;