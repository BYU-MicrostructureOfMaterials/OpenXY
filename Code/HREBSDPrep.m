function Settings = HREBSDPrep(Settings)

%% Set up Initial Params
%The assumption is made that all following images in the scan
%are the same size and square.
fftw('planner','exhaustive');

%FirstPic = ReadEBSDImage(Settings.FirstImagePath,Settings.ImageFilter);
Settings.largefftmeth = fftw('wisdom');
%Settings.PixelSize = size(FirstPic,1);
Settings.ROISize = round((Settings.ROISizePercent * .01)*Settings.PixelSize);

%% Add Sub-folder(s)
addpath('DDS');

%% EMSoft Setup
if strcmp(Settings.HROIMMethod,'Dynamic Simulated')
    %Check Path
    if exist('SystemSettings.mat','file')
        load SystemSettings
        EMdataPath = fullfile(fileparts(EMsoftPath),'EMdata');
        if ~exist(EMdataPath,'dir')
            error('EMsoft path is incorrect. Re-select in Advanced Settings');
        end
    else
        error('EMsoft path is unknown. Re-select in Advanced Settings');
    end
    
    %Set up EMsoft Environment Variables
    PATH = getenv('PATH');
    PATHcell = textscan(PATH,'%s','Delimiter',':');
    if all(cellfun(@isempty,strfind(PATHcell{1},EMsoftPath)))
        PATH = [PATH ':' EMsoftPath filesep 'bin'];
        setenv('PATH',PATH);
        setenv('DYLD_LIBRARY_PATH',PATH);
        setenv('EMsoftpathname',[EMsoftPath filesep])
        setenv('EMdatapathname',[EMdataPath filesep])
    end
    
    %Single Pattern Option
    Settings.SinglePattern = 0;
    if Settings.SinglePattern
        Settings.RefImageInd = 4;
        
        %Read Image
        ImagePath = Settings.ImageNamesList{Settings.RefImageInd};
        if strcmp(Settings.ImageFilterType,'standard')
            ScanImage = ReadEBSDImage(ImagePath,Settings.ImageFilter);
        else
            ScanImage = localthresh(ImagePath);
        end
        gr = euler2gmat(Settings.Angles(Settings.RefImageInd,1) ...
            ,Settings.Angles(Settings.RefImageInd,2),Settings.Angles(Settings.RefImageInd,3));
        if isempty(ScanImage)
            error('Reference Image not found')
        end
        
        %Extract Variables
        curMaterial = Settings.Phase{Settings.RefImageInd};
        xstar = Settings.XStar(Settings.RefImageInd);
        ystar = Settings.YStar(Settings.RefImageInd);
        zstar = Settings.ZStar(Settings.RefImageInd);
        pixsize = Settings.PixelSize;
        mperpix = Settings.mperpix;
        elevang = Settings.CameraElevation;
        Av = Settings.AccelVoltage*1000; %put it in eV from KeV
        
        RefImage = genEBSDPatternHybrid_fromEMSoft(gr,xstar,ystar,zstar,pixsize,mperpix,elevang,curMaterial,Av);
        clear global rs cs Gs
        [F1,~,~] = CalcF(RefImage,ScanImage,gr,eye(3),ImageInd,Settings,curMaterial,Settings.RefImageInd);
        for iq=1:3
            [rr,~]=poldec(F1); % extract the rotation part of the deformation, rr
            gr=rr'*gr; % correct the rotation component of the deformation so that it doesn't affect strain calc
            RefImage = genEBSDPatternHybrid_fromEMSoft(gr,xstar,ystar,zstar,pixsize,mperpix,elevang,curMaterial,Av);
            
            clear global rs cs Gs
            [F1,~,~] = CalcF(RefImage,ScanImage,gr,eye(3),ImageInd,Settings,curMaterial,Settings.RefImageInd);
        end
        Settings.RefImage = RefImage;
    end
end

%% Set up Sub-scan
if isfield(Settings,'Inds') && isfield(Settings,'NewSize') && ...
        length(Settings.Inds) < Settings.ScanLength
    Inds = Settings.Inds;
    Settings.ScanLength = length(Settings.Inds);
    Settings.Nx = Settings.NewSize(1);
    Settings.Ny = Settings.NewSize(2);
else
    Inds = 1:Settings.ScanLength;
    Settings.Inds = Inds;
end


%% Get Grain ID's
if ~isfield(Settings,'grainID') || ~isfield(Settings,'Phase')
    [Settings.grainID, Settings.Phase] = GetGrainInfo(...
            Settings.ScanFilePath, Settings.Material, Settings.ScanParams, Settings.Angles, Settings.MisoTol);
end

%% Get Reference Image(s) when not Simulated Method
% Get reference images and assign the name to each scan image (or main
% image - image b in the case of an L-grid scan)
if ~strcmp(Settings.HROIMMethod,'Simulated')&& ~isfield(Settings,'RefImageNames')
    RefImageInd = Settings.RefImageInd;
    if RefImageInd~=0
        datalength = Settings.ScanLength;
        Settings.RefImageNames = cell(datalength,1);
        Settings.RefImageNames(:)= Settings.ImageNamesList(RefImageInd);
        Settings.Phi1Ref(1:datalength) = Settings.Angles(RefImageInd,1);
        Settings.PHIRef(1:datalength) = Settings.Angles(RefImageInd,2);
        Settings.Phi2Ref(1:datalength) = Settings.Angles(RefImageInd,3);
        Settings.RefInd(1:datalength)= RefImageInd;
    else
        if strcmp(Settings.GrainRefImageType,'Min Kernel Avg Miso')
            [Settings.RefImageNames, Settings.Phi1Ref, ...
                Settings.PHIRef, Settings.Phi2Ref, Settings.RefInd] = GetRefImageNames(Settings.ImageNamesList, ...
                {Settings.Angles(Inds,:);Settings.IQ(Inds);Settings.CI(Inds);Settings.Fit(Inds)}, Settings.grainID(Inds), Settings.KernelAvgMisoPath);
        elseif isfield(Settings,'RefInd')
            Settings.RefImageNames = Settings.ImageNamesList(Settings.RefInd);
        else 
            [Settings.RefImageNames, Settings.Phi1Ref, ...
                Settings.PHIRef, Settings.Phi2Ref, Settings.RefInd] = GetRefImageNames(Settings.ImageNamesList(Inds), ...
                {Settings.Angles(Inds,:);Settings.IQ(Inds);Settings.CI(Inds);Settings.Fit(Inds)}, Settings.grainID(Inds));
        end 
    end  
end

%% Pattern Center Calibration
if ~isfield(Settings,'XStar')
    if Settings.DisplayGUI; disp('No PC calibration at all'); end;
    %Default Naive Plane Fit *****need to include Settings.SampleAzimuthal
    %and Settings.CameraAzimuthal ******
    if isfield(Settings,'PlaneFit') && strcmp(Settings.PlaneFit,'Naive')
        Settings.XStar(1:Settings.ScanLength) = Settings.ScanParams.xstar-Settings.XData(Inds)/Settings.PhosphorSize;
        Settings.YStar(1:Settings.ScanLength) = Settings.ScanParams.ystar+Settings.YData(Inds)/Settings.PhosphorSize*sin(Settings.SampleTilt-Settings.CameraElevation);
        Settings.ZStar(1:Settings.ScanLength) = Settings.ScanParams.zstar+Settings.YData(Inds)/Settings.PhosphorSize*cos(Settings.SampleTilt-Settings.CameraElevation);
    else
        Settings.XStar(1:Settings.ScanLength) = Settings.ScanParams.xstar;
        Settings.YStar(1:Settings.ScanLength) = Settings.ScanParams.ystar;
        Settings.ZStar(1:Settings.ScanLegnth) = Settings.ScanParams.zstar;
    end
end
