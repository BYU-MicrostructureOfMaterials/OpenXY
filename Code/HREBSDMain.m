%Takes in the Settings structure and does HROIM runs
%based on these settings ( See GetHROIMDefaultSettings).
%calls output display functionns on completion
%Jay Basinger 3/11/2011

function Settings = HREBSDMain(Settings)
% tic
% profile n
disp('Dont forget to change PC if the image is cropped by ReadEBSDImage.m')
Settings.DoUsePCFile
Settings.DoPCStrainMin
%% Read in the first image and get the pixel size.
%The assumption is made that all following images in the scan
%are the same size and square.
fftw('planner','exhaustive');
% keyboard
FirstPic = ReadEBSDImage(Settings.FirstImagePath,Settings.ImageFilter);
Settings.largefftmeth = fftw('wisdom');
Settings.PixelSize = size(FirstPic,1);
Settings.ROISize = round((Settings.ROISizePercent * .01)*Settings.PixelSize);

%% Check Scan Type
%Options: 'L', Square, Hexagonal
%Check to see if it is an L-grid scan, apply xycorrection and generate a
%square-grid equivalent for later display. These call slightly modified
%versions of Sadegh's original Step0 and Step1 code.
LImageNamesList = [];

switch Settings.ScanType;
    
    case 'L'
        CorrectedXYAngPath = LGridXYConvert(Settings.AngFilePath,Settings.CustomFilePath);
        if isempty(CorrectedXYAngPath)
            errordlg('Error reading .ang file in LGridXYConvert','Error','modal')
            return;
        end
        
        SquareGridAngPath = LGrid2SquareConvert(Settings.AngFilePath,Settings.CustomFilePath);
        if isempty(SquareGridAngPath)
            errordlg('Error reading .ang file in LGrid2SquareConvert','Error','modal')
            return;
        end
        
        %For L-grid, we need to use the corrected XY and may use
        %SquareGrid-converted file
        [LFileVals ScanParams] = ReadAngFile(CorrectedXYAngPath);
        
        LAngles(:,1) = LFileVals{1};
        LAngles(:,2) = LFileVals{2};
        LAngles(:,3) = LFileVals{3};
        LXData = LFileVals{4};
        LYData = LFileVals{5};
        
        [SquareFileVals ScanParams] = ReadAngFile(SquareGridAngPath);
        
        Angles(:,1) = SquareFileVals{1};
        Angles(:,2) = SquareFileVals{2};
        Angles(:,3) = SquareFileVals{3};
        XData = SquareFileVals{4};
        YData = SquareFileVals{5};
        
        
        %Number of steps in x and y
        Nx = length(unique(XData));
        Ny = length(unique(YData));
        
        %Step size in x and y
        XStep = XData(2)-XData(1);
        YStep = YData(2)-YData(1);
        
        ScanLength = size(LFileVals{1},1);
        
        ConvertedLength = size(SquareFileVals{1},1);
        
        %Create image file name list
        %Get names for L-Grid and then just the main points for a square grid.
        LImageNamesList = GetImageNamesList(Settings.ScanType, ScanLength, Ny, Settings.FirstImagePath);
        
        ImageNamesList = LImageNamesList(:,2);
        
        Settings.LImageNamesList = LImageNamesList;
        
    case 'Square'
        
        [SquareFileVals ScanParams] = ReadAngFile(Settings.AngFilePath);
        
        ScanLength = size(SquareFileVals{1},1);
        
        Angles(:,1) = SquareFileVals{1};
        Angles(:,2) = SquareFileVals{2};
        Angles(:,3) = SquareFileVals{3};
        XData = SquareFileVals{4};
        YData = SquareFileVals{5};
        
        %Number of steps in x and y
        Nx = length(unique(XData));
        Ny = length(unique(YData));
        
        %Step size in x and y
        %         XStep = XData(2)-XData(1);
        %         YStep = YData(2)-YData(1);
        
        %Create image file name list
        ImageNamesList = GetImageNamesList(Settings.ScanType, ScanLength,[Nx Ny], Settings.FirstImagePath);
%         ImageNamesList = GetImageNamesListHkl(Settings.ScanType, ScanLength,[Nx Ny], Settings.FirstImagePath); %*****TEMPORARY FOR VAUDIN FILES
%         disp('using hkl naming in HREBSDMain.m at line 100')
        
    case 'Hexagonal'
        [SquareFileVals ScanParams] = ReadAngFile(Settings.AngFilePath);
        
        ScanLength = size(SquareFileVals{1},1);
        
        Angles(:,1) = SquareFileVals{1};
        Angles(:,2) = SquareFileVals{2};
        Angles(:,3) = SquareFileVals{3};
        XData = SquareFileVals{4};
        YData = SquareFileVals{5};
        
        %Number of steps in x and y
        Nx = length(unique(XData));
        Ny = length(unique(YData));
        ImageNamesList = GetImageNamesList(Settings.ScanType, ScanLength,[Nx Ny], Settings.FirstImagePath);
end

%Common to all scan types
IQ = SquareFileVals{6};
CI = SquareFileVals{7};
Fit = SquareFileVals{10};
data.cols = Nx;
data.rows = Ny;
Settings.Nx = Nx;
Settings.Ny = Ny;
Settings.ScanLength = ScanLength;

%% Initialize all Settings to be passed in to GetDefGradientTensor.
ImageNamesList = ImageNamesList(:);
%Rearrange ImageNamesList vector to match .ang file order
if strcmp(Settings.ScanType,'Square')
    ImageNamesList=reshape(ImageNamesList,[data.rows data.cols])';
    ImageNamesList=ImageNamesList(:);
end
% end of list reshape

Settings.Angles = Angles;
Settings.XData = XData;
Settings.YData = YData;

Settings.IQ = IQ;
Settings.CI = CI;
Settings.Fit = Fit;
Settings.ImageNamesList = ImageNamesList;

%% Read Grain File
if ~exist(Settings.GrainFilePath,'file')
    errordlg(['Could not read grain file at: ' GrainFilePath ],'Error');
end
GrainFileVals = ReadGrainFile(Settings.GrainFilePath);
Settings.grainID = GrainFileVals{9};

%% Get Reference Image(s) when not Simulated Method
% Get reference images and assign the name to each scan image (or main
% image - image b in the case of an L-grid scan)
if ~strcmp(Settings.HROIMMethod,'Simulated')
    RefImageInd = Settings.RefImageInd;  
    if RefImageInd~=0
        datalength = length(ImageNamesList);
        Settings.RefImageNames = cell(datalength,1);
        Settings.RefImageNames(:)= {ImageNamesList{RefImageInd}};
        Settings.Phi1Ref(1:datalength) = Settings.Angles(RefImageInd,1);
        Settings.PHIRef(1:datalength) = Settings.Angles(RefImageInd,2);
        Settings.Phi2Ref(1:datalength) = Settings.Angles(RefImageInd,3);
        Settings.RefInd(1:datalength)= RefImageInd;
    else
        if strcmp(Settings.GrainRefImageType,'Min Kernel Avg Miso')
            [Settings.RefImageNames Settings.Phi1Ref ...
                Settings.PHIRef Settings.Phi2Ref Settings.RefInd] = GetRefImageNames(ImageNamesList, ...
                GrainFileVals, Settings.KernelAvgMisoPath);
        else
            [Settings.RefImageNames Settings.Phi1Ref ...
                Settings.PHIRef Settings.Phi2Ref Settings.RefInd] = GetRefImageNames(ImageNamesList, ...
                GrainFileVals);
        end
    end  
end

% disp('set pc')
%Settings.XStar(1:length(ImageNamesList)) = ScanParams.xstar;
%Settings.YStar(1:length(ImageNamesList)) = ScanParams.ystar;
%Settings.ZStar(1:length(ImageNamesList)) = ScanParams.zstar;


% setup Settings.Phase
% Settings.Phase=cell(size(GrainFileVals{11},1),1);
% size(GrainFileVals{11})
if strcmp(Settings.Material,'grainfile')
    Settings.Phase=lower(GrainFileVals{11});
else
    for op=1:length(GrainFileVals{11})
        Settings.Phase{op}=Settings.Material;
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
            [Settings.XStar Settings.YStar Settings.ZStar] = FitPCPlaneText(PCData, Settings.XData, Settings.YData);
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
        %         [Settings.XStar,Settings.YStar,Settings.ZStar,fval] = BatchPC(PCPath, Settings.AngFilePath, Settings.GrainFilePath, Settings);
        
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
    Settings.XStar(1:length(ImageNamesList)) = ScanParams.xstar;
    Settings.YStar(1:length(ImageNamesList)) = ScanParams.ystar;
    Settings.ZStar(1:length(ImageNamesList)) = ScanParams.zstar;
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
    pctRunOnAll javaaddpath(cd)
    
    disp('Starting cross-correlation');
    N = length(ImageNamesList);
    ppm = ParforProgMon( 'Multi Core Progress', N );
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
for jj = 1:length(ImageNamesList)
    
    
    
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

% if Settings.DoPCStrainMin
%     save(PCStrainMinSaveFile, 'cuttoff', 'data', 'Settings');
%     return;
% end

%%
%Save deformation gradient, rotation, strain tensors, and SSE.
DotInd = find(Settings.OutputPath == '.');
if length(DotInd) > 1
    DotInd = DotInd(end);
end

Settings.data = data;
LastSlashInd = find(Settings.OutputPath == '\');
OutputPathWithSlash = Settings.OutputPath(1:LastSlashInd(end));
FileName = Settings.OutputPath(LastSlashInd(end)+1:DotInd-1);
SaveFile = [OutputPathWithSlash 'AnalysisParams_' FileName];
Settings.AnalysisParamsPath = SaveFile;
save(SaveFile, 'Settings');

%% Calculate derivatives
if Settings.CalcDerivatives == 1
    MaxMisorientation = Settings.MisoTol;
    IQcutoff = Settings.IQCutoff;
    VaryStepSizeI = Settings.NumSkipPts;
    
    DislocationDensityCalculate(Settings,MaxMisorientation,IQcutoff,VaryStepSizeI) 
end

%% Output Plotting
% save([OutputPathWithSlash 'Data_' FileName],'data');
input{1} = [SaveFile '.mat'];
OutputPlotting(input); %moved here due to error writing ang file for vaudin files ****
%%
WriteHROIMAngFile(Settings.AngFilePath,[OutputPathWithSlash 'Corr_' FileName '.ang'],...
    Settings.NewAngles(:,1),Settings.NewAngles(:,2),Settings.NewAngles(:,3)...
    ,Settings.SSE);

% profile viewer
% profile off

% keyboard
% profsave(profile('info'),'profile_results')
%Call output display GUI for curvature, dislocation density, strain, etc.
%output.

