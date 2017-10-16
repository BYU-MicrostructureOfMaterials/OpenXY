function Settings = HREBSDPrep(Settings)

%% Set up Initial Params
%The assumption is made that all following images in the scan
%are the same size and square.
fftw('planner','exhaustive');

%% Orientation-based GND Option
if strcmp(Settings.GNDMethod,'Orientation') && ~Settings.DoStrain && ~isfield(Settings,'PixelSize')
    Settings.PixelSize = 0;
    Settings.PhosphorSize = 3700;
end

%FirstPic = ReadEBSDImage(Settings.FirstImagePath,Settings.ImageFilter);
Settings.largefftmeth = fftw('wisdom');
%Settings.PixelSize = size(FirstPic,1);
Settings.ROISize = round((Settings.ROISizePercent * .01)*Settings.PixelSize);

%% Import Scan (for Fast GUI)
if ~isfield(Settings,'ImageNamesList')
    disp('Reading Scan File...')
    Settings = ImportScanInfo(Settings,Settings.ScanFilePath);
    if ~isempty(Settings.FirstImagePath)
        Settings.ImageNamesList = ImportImageNamesList(Settings);
    end
end

%% Validate Variables
if strcmp(Settings.ROIStyle,'Grid')
    Settings.NumROIs = 48;
end

%% Validate SplitDD Materials
if Settings.DoDDS && ~CheckSplitDDMaterials(unique(Settings.Phase))
    Settings.DoDDS = false;
end

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
        if size(Settings.ImageNamesList,1)>1
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
        else
            ScanImage = ReadH5Pattern(Settings.ScanFilePath,Settings.ImageNamesList,...
                Settings.imsize,Settings.ImageFilter,Settings.RefImageInd);
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
if isfield(Settings,'Inds') && isfield(Settings,'Resize') && ...
        length(Settings.Inds) < Settings.ScanLength
    Settings.ScanLength = length(Settings.Inds);
    Oldsize = [Settings.Nx Settings.Ny];
    Settings.Nx = Settings.Resize(1);
    Settings.Ny = Settings.Resize(2);
    Settings.Resize = Oldsize;
else
    Inds = 1:Settings.ScanLength;
    Settings.Inds = Inds;
end


%% Get Reference Image(s) when not Simulated Method
% Get reference images and assign the name to each scan image (or main
% image - image b in the case of an L-grid scan)
if ~strcmp(Settings.HROIMMethod,'Simulated')&& ~isfield(Settings,'RefInd')
    disp('Getting Reference Image Indices...')
    if Settings.RefImageInd~=0
        Settings.RefInd(1:Settings.ScanLength,1)= Settings.RefImageInd;
    else
        if strcmp(Settings.GrainRefImageType,'Min Kernel Avg Miso')
            Settings.RefInd = GetRefImageInds(...
                {Settings.Angles;Settings.IQ;Settings.CI;Settings.Fit}, Settings.grainID, Settings.KernelAvgMisoPath);
        else 
            Settings.RefInd = GetRefImageInds(...
                {Settings.Angles;Settings.IQ;Settings.CI;Settings.Fit}, Settings.grainID);
        end
    end  
end

%% Split Grains
if true
    [Settings.subgrainPaths, Settings.subgrainID, Settings.subRefInd] = SubGrainPaths(Settings);
else
    Settings.subGrainPaths = [];
    Settings.subgrainID = Settings.grainID;
    Settings.subRefInd = Settings.RefInd;
end

%% Pattern Center Calibration
if ~isfield(Settings,'XStar')
    if isfield(Settings,'PCList') % For Fast GUI
        index = find([Settings.PCList{:,8}]);
        Settings.PlaneFit = Settings.PCList{index,6};
        xstar = Settings.PCList{index,1};
        ystar = Settings.PCList{index,2};
        zstar = Settings.PCList{index,3};
    else
        if Settings.DisplayGUI; disp('No PC calibration at all'); end;
        xstar = Settings.ScanParams.xstar;
        ystar = Settings.ScanParams.ystar;
        zstar = Settings.ScanParams.zstar;
    end
    %Default Naive Plane Fit *****need to include Settings.SampleAzimuthal
    %and Settings.CameraAzimuthal ******
    FullLength = length(Settings.XData);
    if isfield(Settings,'PlaneFit') && strcmp(Settings.PlaneFit,'Naive')
        Settings.XStar(1:FullLength) = xstar-Settings.XData/Settings.PhosphorSize;
        Settings.YStar(1:FullLength) = ystar+Settings.YData/Settings.PhosphorSize*sin(Settings.SampleTilt-Settings.CameraElevation);
        Settings.ZStar(1:FullLength) = zstar+Settings.YData/Settings.PhosphorSize*cos(Settings.SampleTilt-Settings.CameraElevation);
    else
        Settings.XStar(1:FullLength) = xstar;
        Settings.YStar(1:FullLength) = ystar;
        Settings.ZStar(1:FullLength) = zstar;
    end
end

Settings.HREBSDPrep = true;