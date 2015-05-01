%Takes in the Settings structure and does HROIM runs
%based on these settings ( See GetHROIMDefaultSettings).
%calls output display functionns on completion
%Jay Basinger 3/11/2011

function Settings = HREBSDMain(Settings)
% tic
profile on
disp('Dont forget to change PC if the image is cropped by ReadEBSDImage.m')
%% Read in the first image and get the pixel size.
%The assumption is made that all following images in the scan
%are the same size and square.
fftw('planner','exhaustive');

FirstPic = ReadEBSDImage(Settings.FirstImagePath,Settings.ImageFilter);
Settings.largefftmeth = fftw('wisdom');
Settings.PixelSize = size(FirstPic,1);
Settings.ROISize = round((Settings.ROISizePercent * .01)*Settings.PixelSize);

%% Add Sub-folder(s)
addpath('DDS');

%Sets default color scheme for all figures and axes
set(0,'DefaultFigureColormap',jet);

%% Check Scan Type
%Options: 'L', Square, Hexagonal
%Check to see if it is an L-grid scan, apply xycorrection and generate a
%square-grid equivalent for later display. These call slightly modified
%versions of Sadegh's original Step0 and Step1 code.
LImageNamesList = [];
if ~isfield(Settings,'Angles')
    [SquareFileVals, ScanParams] = ReadScanFile(Settings.ScanFilePath); 
    Settings.ScanLength = size(SquareFileVals{1},1);
    Settings.Angles(:,1) = SquareFileVals{1};
    Settings.Settings.Angles(:,2) = SquareFileVals{2};
    Settings.Angles(:,3) = SquareFileVals{3};
    Settings.XData = SquareFileVals{4};
    Settings.YData = SquareFileVals{5};
    Settings.IQ = SquareFileVals{6};
    Settings.CI = SquareFileVals{7};
    Settings.Fit = SquareFileVals{10};
end

%Unique x and y
X = unique(Settings.XData);
Y = unique(Settings.YData);

%Number of steps in x and y
Nx = length(X);
Ny = length(Y);

switch Settings.ScanType;   
    case 'Square'
        %Step size in x and y
        XStep = X(2)-X(1);
        if length(Y) > 1
            YStep = Y(2)-Y(1);
        else
            YStep = 0; %Line Scans
        end
        
        %Create image file name list
        Settings.ImageNamesList = GetImageNamesList(Settings.ScanType, Settings.ScanLength,[Nx Ny], Settings.FirstImagePath, [X(1),Y(1)], [XStep, YStep]);
%         ImageNamesList = GetImageNamesListHkl(Settings.ScanType, ScanLength,[Nx Ny], Settings.FirstImagePath); %*****TEMPORARY FOR VAUDIN FILES
%         disp('using hkl naming in HREBSDMain.m at line 100')
        
    case 'Hexagonal'
        %Step size in x and y
        XStep = X(3)-X(1);
        YStep = Y(3)-Y(1);
        
        Settings.ImageNamesList = GetImageNamesList(Settings.ScanType, Settings.ScanLength,[Nx Ny], Settings.FirstImagePath, [X(1),Y(1)], [XStep, YStep]);
        
    case 'L'
        CorrectedXYAngPath = LGridXYConvert(Settings.ScanFilePath,Settings.CustomFilePath);
        if isempty(CorrectedXYAngPath)
            errordlg('Error reading .ang file in LGridXYConvert','Error','modal')
            return;
        end
        
        SquareGridAngPath = LGrid2SquareConvert(Settings.ScanFilePath,Settings.CustomFilePath);
        if isempty(SquareGridAngPath)
            errordlg('Error reading .ang file in LGrid2SquareConvert','Error','modal')
            return;
        end
        
        %For L-grid, we need to use the corrected XY and may use
        %SquareGrid-converted file
        [LFileVals ScanParams] = ReadScanFile(CorrectedXYAngPath);
        
        LAngles(:,1) = LFileVals{1};
        LAngles(:,2) = LFileVals{2};
        LAngles(:,3) = LFileVals{3};
        LXData = LFileVals{4};
        LYData = LFileVals{5};
        
        
        [SquareFileVals, ScanParams] = ReadScanFile(SquareGridAngPath); 
        ScanLength = size(SquareFileVals{1},1);
        Angles(:,1) = SquareFileVals{1};
        Angles(:,2) = SquareFileVals{2};
        Angles(:,3) = SquareFileVals{3};
        XData = SquareFileVals{4};
        YData = SquareFileVals{5};
        
        %Unique x and y
        X = unique(XData);
        Y = unique(YData);

        %Number of steps in x and y
        Nx = length(X);
        Ny = length(Y);
        
        ScanLength = size(LFileVals{1},1);
        ConvertedLength = size(SquareFileVals{1},1);
        
        %Create image file name list
        %Get names for L-Grid and then just the main points for a square grid.
        LImageNamesList = GetImageNamesList(Settings.ScanType, ScanLength, Ny, Settings.FirstImagePath);
        ImageNamesList = LImageNamesList(:,2);
        Settings.LImageNamesList = LImageNamesList;
end

%Common to all scan types
data.cols = Nx;
data.rows = Ny;
Settings.Nx = Nx;
Settings.Ny = Ny;

%% Get Grain ID's
if ~isfield(Settings,'grainID') || ~isfield(Settings,'Phase')
    [Settings.grainID, Settings.Phase] = GetGrainInfo(...
            Settings.ScanFilePath, Settings.Material, Settings.ScanParams, Settings.Angles, Settings.MisoTol);
end

%% Get Reference Image(s) when not Simulated Method
% Get reference images and assign the name to each scan image (or main
% image - image b in the case of an L-grid scan)
if ~strcmp(Settings.HROIMMethod,'Simulated')
    RefImageInd = Settings.RefImageInd;  
    if RefImageInd~=0
        datalength = Settings.ScanLength;
        Settings.RefImageNames = cell(datalength,1);
        Settings.RefImageNames(:)= {Settings.ImageNamesList{RefImageInd}};
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
    
elseif Settings.DoPCStrainMin
    disp('Running PC GUI')
    save('Settings.mat','Settings')
    PCCalGUI();
    uiwait;
    load Settings;
    if Settings.Exit
        return;
    end
end
if ~Settings.DoPCStrainMin
    disp('No PC calibration at all')
    Settings.XStar(1:length(Settings.ImageNamesList)) = Settings.ScanParams.xstar;
    Settings.YStar(1:length(Settings.ImageNamesList)) = Settings.ScanParams.ystar;
    Settings.ZStar(1:length(Settings.ImageNamesList)) = Settings.ScanParams.zstar;
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
    % addpath cd
    javapaths = javaclasspath('-dynamic');
    if isempty(strfind(javapaths,cd))
        pctRunOnAll javaaddpath('java')
    end
    
    disp('Starting cross-correlation');
    N = Settings.ScanLength;
    ppm = ParforProgMon('Cross Correlation Analysis ',N,1,400,50);
    parfor(ImageInd = 1:N,NumberOfCores)
%         disp(ImageInd)
        %Returns F as either a cell array of deformation gradient tensors
        %or a structure F.a F.b F.c of deformation gradient tensors for
        %each point in the L grid
        
        [F{ImageInd} g{ImageInd} U{ImageInd} SSE{ImageInd}] = ...
            GetDefGradientTensor(ImageInd,Settings,Settings.Phase{ImageInd});
        
        %{
        commented out this (outputs strain matrix - I think - DTF 5/15/14)
        if strcmp(Settings.ScanType,'L')
            U{ImageInd}.b - eye(3)
        else
            U{ImageInd} - eye(3)
        end
        %}
        
        ppm.increment();
    end
    ppm.delete();
    
else
    h = waitbar(0,'Single Processor Progress');
    
    for ImageInd = 1:length(ImageNamesList)
        %         tic
%         disp(ImageInd)
        
        [F{ImageInd} g{ImageInd} U{ImageInd} SSE{ImageInd}] = ...
            GetDefGradientTensor(ImageInd,Settings,Settings.Phase{ImageInd});
        
        % commented out this (outputs strain matrix - I think - DTF 5/15/14)
%         if strcmp(Settings.ScanType,'L')
%             U{ImageInd}.b - eye(3)
%         else
%             U{ImageInd} - eye(3)
%         end
        
        waitbar(ImageInd/length(ImageNamesList),h);
        %         IterTime(ImageInd) = toc
%         if ImageInd>50
%             keyboard
%         end
    end
    close(h);
end
Time = toc/60;
disp(['Time to finish: ' num2str(Time) ' minutes'])

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
profile off
profile viewer
%% Output Plotting
% save([OutputPathWithSlash 'Data_' FileName],'data');
input{1} = [SaveFile '.mat'];
OutputPlotting(input); %moved here due to error writing ang file for vaudin files ****
%%

WriteHROIMAngFile(Settings.ScanFilePath,fullfile(OutputPath, ['Corr_' FileName '.ang']),...
    Settings.NewAngles(:,1),Settings.NewAngles(:,2),Settings.NewAngles(:,3)...
    ,Settings.SSE);

% profile viewer
% profile off

% keyboard
% profsave(profile('info'),'profile_results')
%Call output display GUI for curvature, dislocation density, strain, etc.
%output.

