%Takes in the Settings structure and does HROIM runs
%based on these settings ( See GetHROIMDefaultSettings).
%calls output display functionns on completion
%Jay Basinger 3/11/2011
%

function Settings = HREBSDMain(Settings)
% tic
if Settings.EnableProfiler; profile on; end;
if Settings.DisplayGUI; disp('Dont forget to change PC if the image is cropped by ReadEBSDImage.m'); end;
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

%Check if EMsoft is set up correctly
if strcmp(Settings.HROIMMethod,'Dynamic Simulated')
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
    
    %Tet Patterns
    if 1
        %Settings.Material = 'SiTet_19_0';
        Settings.Phase(:) = {Settings.Material};
        Settings.Angles(:,3) = Settings.Angles(:,3)-pi/4; %Rotate crystal by 45 degrees
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
        [F1,~,~] = CalcF(RefImage,ScanImage,gr,eye(3),ImageInd,Settings,curMaterial);
        for iq=1:3
            [rr,~]=poldec(F1); % extract the rotation part of the deformation, rr
            gr=rr'*gr; % correct the rotation component of the deformation so that it doesn't affect strain calc
            RefImage = genEBSDPatternHybrid_fromEMSoft(gr,xstar,ystar,zstar,pixsize,mperpix,elevang,curMaterial,Av);
            
            clear global rs cs Gs
            [F1,~,~] = CalcF(RefImage,ScanImage,gr,eye(3),ImageInd,Settings,curMaterial);
        end
        Settings.RefImage = RefImage;
    end
end

%Sets default color scheme for all figures and axes
set(0,'DefaultFigureColormap',jet);

%Common to all scan types
data.cols = Settings.Nx;
data.rows = Settings.Ny;

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
                {Settings.Angles;Settings.IQ;Settings.CI;Settings.Fit}, Settings.grainID, Settings.KernelAvgMisoPath);
        else
            [Settings.RefImageNames, Settings.Phi1Ref, ...
                Settings.PHIRef, Settings.Phi2Ref, Settings.RefInd] = GetRefImageNames(Settings.ImageNamesList, ...
                {Settings.Angles;Settings.IQ;Settings.CI;Settings.Fit}, Settings.grainID);
        end
    end  
end

%% Pattern Center Calibration
if Settings.DoUsePCFile
    %disp('using pc file')
    %load PCFile
    %PC calibration file should contain either a few PC points or be a .mat
    %list of PC/EBSD Image.
    
    %Determine which we are loading:
    PCPath = Settings.PCFilePath;
    
    dotpos = find(PCPath == '.');
    Extension = PCPath(dotpos+1:end);
    
    if strcmp(Extension,'txt')
        
        
        %Read in PC Calibration file (in percent of the phosphor screen)
        PCData = ReadPCCalibFile(Settings.PCFilePath);
        PCData{2} = PCData{2}.*0.01; %convert to a fraction rather than percent of phospor;
        PCData{3} = PCData{3}.*0.01;
        PCData{4} = PCData{4}.*0.01;
        if size(PCData{1},1) == 1
            Settings.XStar(1:length(ImageNamesList)) = PCData{2};
            Settings.YStar(1:length(ImageNamesList)) = PCData{3};
            Settings.ZStar(1:length(ImageNamesList)) = PCData{4};
        else
            [Settings.XStar, Settings.YStar, Settings.ZStar] = FitPCPlaneText(PCData, Settings.XData, Settings.YData);
        end
    elseif strcmp(Extension,'mat') %this is for backwards compatibility with Josh's format for PC calibration files.
        %Hopefully the variable they all contain is named cuttoff...
        
        
        PCPath = Settings.PCFilePath;
        TempVar = load(PCPath);
        SSEList = cell2mat(TempVar.data.SSE);
        numbers = 1:length(SSEList);
        Non101s = numbers(SSEList < 101);
        BestSSEs = numbers(SSEList < ...
            (mean(SSEList)));% - std(SSEList(Non101s)) ) );
        TempList = vertcat(TempVar.cuttoff{:});
        PCList = TempList(BestSSEs,:);
        %         PCList = vertcat(TempVar.cuttoff{:});
        PCData{2} = PCList(:,1);
        PCData{3} = PCList(:,2);
        PCData{4} = PCList(:,3);
        %         PCData{5} = Settings.XData(1:end-1);
        %         PCData{6} = Settings.YData(1:end-1);
        PCData{5} = Settings.XData(BestSSEs);
        PCData{6} = Settings.YData(BestSSEs);
        %
        [Settings.XStar Settings.YStar Settings.ZStar] = FitPCPlaneText(PCData, Settings.XData(1:end), Settings.YData(1:end));
        
        %                 Settings.XStar(1:length(ImageNamesList)) = PCList(:,1);
        %                 Settings.YStar(1:length(ImageNamesList)) = PCList(:,2);
        %                 Settings.ZStar(1:length(ImageNamesList)) = PCList(:,3);
        %
        %         [Settings.XStar,Settings.YStar,Settings.ZStar,fval] = BatchPC(PCPath, Settings.ScanFilePath, Settings.GrainFilePath, Settings);
        
    else
        errordlg('PC calibration file type is invalid','PC Calibration File Path Error');
    end
    
elseif ~isfield(Settings,'XStar')
    if Settings.DisplayGUI; disp('No PC calibration at all'); end;
    %Default Naive Plane Fit *****need to include Settings.SampleAzimuthal
    %and Settings.CameraAzimuthal ******
    Settings.XStar(1:Settings.ScanLength) = Settings.ScanParams.xstar-Settings.XData/Settings.PhosphorSize;
    Settings.YStar(1:Settings.ScanLength) = Settings.ScanParams.ystar+Settings.YData/Settings.PhosphorSize*sin(Settings.SampleTilt-Settings.CameraElevation);
    Settings.ZStar(1:Settings.ScanLength) = Settings.ScanParams.zstar+Settings.YData/Settings.PhosphorSize*cos(Settings.SampleTilt-Settings.CameraElevation);
end

     
% *******
% temporary using PCs from Jay's code for Vaudin s01-I08 7-1 03Images
%  Settings.XStar(1:length(ImageNamesList)) = 0.494306925 + (0.486407322-0.494306925)*Settings.XData/192;
%     Settings.YStar(1:length(ImageNamesList)) = 0.744032271+(0.744902133-0.744032271)*Settings.XData/192;
%     Settings.ZStar(1:length(ImageNamesList)) = 0.636398250+(0.6400597745-0.636398250)*Settings.XData/192;
% 
%   old method - constant PC
%         Settings.XStar(1:length(ImageNamesList)) = ScanParams.xstar;
%     Settings.YStar(1:length(ImageNamesList)) = ScanParams.ystar;
%     Settings.ZStar(1:length(ImageNamesList)) = ScanParams.zstar;
%save('SettingsHREBSD.mat','Settings');

%% Run Analysis
%Use a parfor loop if allowed multiple processors.
tic
%Initialize Variables
F = repmat({zeros(3)},1,Settings.ScanLength);
g = repmat({zeros(3,1)},1,Settings.ScanLength);
U = repmat({zeros(3)},1,Settings.ScanLength);
SSE = repmat({0},1,Settings.ScanLength);

if Settings.DoParallel > 1
    NumberOfCores = Settings.DoParallel;
    try
        ppool = gcp('nocreate');
        if isempty(ppool)
            parpool(NumberOfCores);
        end
    catch
        ppool = matlabpool('size');
        if ~ppool
            matlabpool('local',NumberOfCores); 
        end
    end
    
    N = Settings.ScanLength;
    pctRunOnAll javaaddpath('java')
    if Settings.DisplayGUI
        disp('Starting cross-correlation');
        ppm = ParforProgMon('Cross Correlation Analysis ',N,1,400,50);
    end
    parfor(ImageInd = 1:N,NumberOfCores)
%         disp(ImageInd)
        %Returns F as either a cell array of deformation gradient tensors
        %or a structure F.a F.b F.c of deformation gradient tensors for
        %each point in the L grid
        
        [F{ImageInd}, g{ImageInd}, U{ImageInd}, SSE{ImageInd}, XX{ImageInd}] = ...
            GetDefGradientTensor(ImageInd,Settings,Settings.Phase{ImageInd});
        
        %{
        commented out this (outputs strain matrix - I think - DTF 5/15/14)
        if strcmp(Settings.ScanType,'L')
            U{ImageInd}.b - eye(3)
        else
            U{ImageInd} - eye(3)
        end
        %}
        
        if Settings.DisplayGUI; ppm.increment(); end;
    end
    if Settings.DisplayGUI; ppm.delete(); end;
    
else
    if Settings.DisplayGUI; h = waitbar(0,'Single Processor Progress'); end;
    
    for ImageInd = 1:Settings.ScanLength
        %         tic
%         disp(ImageInd)
        
        [F{ImageInd}, g{ImageInd}, U{ImageInd}, SSE{ImageInd}, XX{ImageInd}] = ...
            GetDefGradientTensor(ImageInd,Settings,Settings.Phase{ImageInd});
        
        % commented out this (outputs strain matrix - I think - DTF 5/15/14)
%         if strcmp(Settings.ScanType,'L')
%             U{ImageInd}.b - eye(3)
%         else
%             U{ImageInd} - eye(3)
%         end
        
        if Settings.DisplayGUI; waitbar(ImageInd/Settings.ScanLength,h); end;
        %         IterTime(ImageInd) = toc
%         if ImageInd>50
%             keyboard
%         end
    end
    if Settings.DisplayGUI; close(h); end;
end
Time = toc/60;
if Settings.DisplayGUI; disp(['Time to finish: ' num2str(Time) ' minutes']); end;

%% Save output and write to .ang file
for jj = 1:Settings.ScanLength
   
    data.IQ{jj} = Settings.IQ(jj);
    
    if strcmp(Settings.ScanType,'L')
        [phi1 PHI phi2] = gmat2euler(g{jj}.b);
        Settings.g{jj} = g{jj}.b;
        Settings.F{jj} = F{jj}.b;
        Settings.Fa{jj} = F{jj}.a;
        Settings.Fc{jj} = F{jj}.c;
        Settings.U{jj} = U{jj}.b;
        Settings.Ua{jj} = U{jj}.a;
        Settings.Uc{jj} = U{jj}.c;
        Settings.SSE{jj} = SSE{jj}.b;
        Settings.SSEa{jj} = SSE{jj}.a;
        Settings.SSEc{jj} = SSE{jj}.c;
        data.SSE{jj} = SSE{jj}.b;
        data.SSEa{jj} = SSE{jj}.a;
        data.SSEc{jj} = SSE{jj}.c;
        data.F{jj} = F{jj}.b;
        data.Fa{jj} = F{jj}.a;
        data.Fc{jj} = F{jj}.c;
    else
        
        [phi1 PHI phi2] = gmat2euler(g{jj});
        Settings.SSE{jj} = SSE{jj};
        Settings.g{jj} = g{jj};
        data.SSE{jj} = SSE{jj};
        data.F{jj} = F{jj};
        data.phi1rn{jj} = phi1;
        data.PHIrn{jj} = PHI;
        data.phi2rn{jj} = phi2;
        Settings.XX = XX;
        
    end
    
    data.g{jj} = [phi1 PHI phi2];
    Settings.NewAngles(jj,1:3) = [phi1 PHI phi2];
    
end
if strcmp(Settings.ScanType,'L')
    
    data.phi1rn = LFileVals{1};
    data.PHIrn = LFileVals{2};
    data.phi2rn = LFileVals{3};
    data.xpos = LFileVals{4};
    data.ypos = LFileVals{5};
    
else
    data.xpos = Settings.XData;
    data.ypos = Settings.YData;
end

Settings.AverageSSE = mean([Settings.SSE{:}]);

%%
%Save deformation gradient, rotation, strain tensors, and SSE.
Settings.data = data;
[OutputPath, FileName, ~] = fileparts(Settings.OutputPath);
SaveFile = fullfile(OutputPath,['AnalysisParams_' FileName]);
Settings.AnalysisParamsPath = SaveFile;
save([SaveFile '.mat'], 'Settings');

%% Calculate derivatives
if Settings.CalcDerivatives
    MaxMisorientation = Settings.MisoTol;
    IQcutoff = Settings.IQCutoff;
    VaryStepSizeI = Settings.NumSkipPts;
    
    if Settings.DisplayGUI; disp('Starting Dislocation Density Calculation'); end;
    DislocationDensityCalculate(Settings,MaxMisorientation,IQcutoff,VaryStepSizeI)
    
    % Split Dislocation Density (Code by Tim Ruggles, added 3/5/2015)
    if Settings.DoDDS
        temp = load([Settings.AnalysisParamsPath '.mat']);
        alpha_data = temp.alpha_data;
        clear temp
        rhos = SplitDD(Settings, alpha_data, Settings.DDSMethod);
        if ~isempty(rhos)
            save(Settings.AnalysisParamsPath,'rhos','-append');
        end
    end
end
if Settings.EnableProfiler
    profile off
    profile viewer
end

%% Write Corrected Scan File
[~,~,ext] = fileparts(Settings.ScanFilePath);
if strcmp(ext,'.ang')
    WriteHROIMAngFile(Settings.ScanFilePath,fullfile(OutputPath, ['Corr_' FileName '.ang']),...
        Settings.NewAngles(:,1),Settings.NewAngles(:,2),Settings.NewAngles(:,3)...
        ,Settings.SSE);
elseif strcmp(ext,'.ctf')
    WriteHROIMCtfFile(Settings.ScanFilePath,fullfile(OutputPath, ['Corr_' FileName '.ctf']),...
        Settings.NewAngles(:,1),Settings.NewAngles(:,2),Settings.NewAngles(:,3)...
        ,Settings.SSE);
end

% keyboard
% profsave(profile('info'),'profile_results')
%Call output display GUI for curvature, dislocation density, strain, etc.
%output.

%% Output Plotting
% save([OutputPathWithSlash 'Data_' FileName],'data');
input{1} = [SaveFile '.mat'];
OutputPlotting(input); %moved here due to error writing ang file for vaudin files ****
