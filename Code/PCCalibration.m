function CalibrationPointsPC = PCCalibration(Settings,ScanParams,Algorithm)
%Perform Calibration
npoints = length(Settings.CalibrationPointIndecies);
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
    M = NumCores;
    pctRunOnAll javaaddpath('java')
    ppm = ParforProgMon( 'Point Calibration ', npoints,1,400,50 );

    parfor (i=1:npoints)
        PCref = PCMinSinglePattern(Settings, ScanParams, Settings.CalibrationPointIndecies(i),Algorithm);
        disp(['Point: ' num2str(i)])
        CalibrationPointsPC(i,:) = PCref';
        ppm.increment();
    end
    ppm.delete();
else
    %Single Processor Calculation
    for i = 1:npoints
        PCref = PCMinSinglePattern(Settings, ScanParams, Settings.CalibrationPointIndecies(i),Algorithm);
        disp(['Point: ' num2str(i)])
        CalibrationPointsPC(i,:) = PCref';
    end
end