%Takes in the Settings structure and does HROIM runs
%based on these settings ( See GetHROIMDefaultSettings).
%calls output display functionns on completion
%Jay Basinger 3/11/2011
%

function Settings = HREBSDMain(Settings)
% tic
if Settings.EnableProfiler; profile on; end;
%if Settings.DisplayGUI; disp('Dont forget to change PC if the image is cropped by ReadEBSDImage.m'); end;

%Sets default color scheme for all figures and axes
set(0,'DefaultFigureColormap',jet);

Settings = HREBSDPrep(Settings);
Inds = Settings.Inds;

%% Run Analysis
%Use a parfor loop if allowed multiple processors.
if ~isfield(Settings,'DoStrain')
    Settings.DoStrain = 1;
end

%Initialize Variables
% F = repmat({zeros(3)},1,Settings.ScanLength);
F = zeros(3,3,Settings.ScanLength);
g = zeros(3,3,Settings.ScanLength);
% U = repmat({zeros(3)},1,Settings.ScanLength);
U = zeros(3,3,Settings.ScanLength);
% SSE = repmat({0},1,Settings.ScanLength);
SSE = zeros(1,Settings.ScanLength);
% XX = repmat({zeros(Settings.NumROIs,3)},1,Settings.ScanLength);
 XX = zeros(Settings.NumROIs,3,Settings.ScanLength);
sigma = zeros(3,3,Settings.ScanLength);
if Settings.DoStrain
outerTimer = tic;
if Settings.DoParallel > 1
    disp('Setting up parallel processing...')
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
    
    disp('Running strain cross-correlation...')
    parfor(ImageInd = 1:N,NumberOfCores)
%         disp(ImageInd)
        %Returns F as either a cell array of deformation gradient tensors
        %or a structure F.a F.b F.c of deformation gradient tensors for
        %each point in the L grid
        
        [F(:,:,ImageInd), g(:,:,ImageInd), U(:,:,ImageInd), SSE(ImageInd), XX(:,:,ImageInd), sigma(:,:,ImageInd)] = ...
            GetDefGradientTensor(Inds(ImageInd),Settings,Settings.Phase{ImageInd});
        
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
    if Settings.DisplayGUI
        progString = sprintf('Single Processor Progress\nTime Remaining:');
        h = waitbar(0,progString);
        innerTimer = tic;
    end
    
    disp('Running strain cross-correlation...')
    for ImageInd = 1:Settings.ScanLength
        %         tic
%         disp(ImageInd)
        
        [F(:,:,ImageInd), g(:,:,ImageInd), U(:,:,ImageInd), SSE(ImageInd), XX(:,:,ImageInd), sigma(:,:,ImageInd)] = ...
GetDefGradientTensor(Inds(ImageInd),Settings,Settings.Phase{ImageInd});
        
        % commented out this (outputs strain matrix - I think - DTF 5/15/14)
%         if strcmp(Settings.ScanType,'L')
%             U{ImageInd}.b - eye(3)
%         else
%             U{ImageInd} - eye(3)
%         end
        
        if Settings.DisplayGUI
            time = toc(innerTimer);
            avgTime = time / ImageInd;
            remainingTime = (avgTime * (Settings.ScanLength - ImageInd)) / 60;% In Minutes
            remainingMins = mod(remainingTime,60);
            remainingHours = (remainingTime - remainingMins) / 60; % In hours
            progString = sprintf('Single Processor Progress\nTime Remaining: %u Hours %u minutes',remainingHours,round(remainingMins));
            try
                waitbar(ImageInd/Settings.ScanLength,h,progString)
            catch ME
                if strcmp(ME.identifier, 'MATLAB:waitbar:InvalidSecondInput')
                    h = waitbar(ImageInd/Settings.ScanLength,progString);

                else
                    ME.rethrow;
                end
            end
        end
        %         IterTime(ImageInd) = toc
%         if ImageInd>50
%             keyboard
%         end
    end
    if Settings.DisplayGUI; close(h); end;
end
Time = toc(outerTimer)/60;
if Settings.DisplayGUI; disp(['Time to finish: ' num2str(Time) ' minutes']); end;
else
   g = euler2gmat(Settings.Angles);
end

%% Save output and write to .ang file
if ~isfield(Settings,'data') || Settings.DoStrain
    
    %Common to all scan types
    data.cols = Settings.Nx;
    data.rows = Settings.Ny;
    
    Settings.NewAngles = Settings.Angles;
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
            
            [phi1 PHI phi2] = gmat2euler(g(:,:,jj));
            Settings.SSE(jj) = SSE(jj);
            data.SSE(jj) = SSE(jj);
            data.F(:,:,jj) = F(:,:,jj);
            data.phi1rn(jj) = phi1;
            data.PHIrn(jj) = PHI;
            data.phi2rn(jj) = phi2;
            
            
        end
        
        
        data.g{jj} = [phi1 PHI phi2];
        Settings.NewAngles(jj,1:3) = [phi1 PHI phi2];
        
    end
    Settings.XX = XX;
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
    
    data.sigma = sigma;
    data.U = U;
    Settings.AverageSSE = mean([Settings.SSE(:)]);
    Settings.data = data;
else
    Settings.SSE = Settings.data.SSE;
end


%% Save Analysis
%Save deformation gradient, rotation, strain tensors, and SSE.
[OutputPath, FileName, ~] = fileparts(Settings.OutputPath);
SaveFile = fullfile(OutputPath,['AnalysisParams_' FileName '.mat']);
Settings.AnalysisParamsPath = SaveFile;
save(SaveFile, 'Settings');

%% Calculate derivatives
if Settings.CalcDerivatives
    MaxMisorientation = Settings.MisoTol;
    IQcutoff = Settings.IQCutoff;
    VaryStepSizeI = Settings.NumSkipPts;
    
    if Settings.DisplayGUI; disp('Starting Dislocation Density Calculation'); end;
    if strcmp(Settings.GNDMethod,'Orientation')
        alpha_data = GNDfromOIM(Settings,1,Settings.NumSkipPts);
        save(SaveFile ,'alpha_data','-append'); 
    else
        DislocationDensityCalculate(Settings,MaxMisorientation,IQcutoff,VaryStepSizeI);
    end
    
    % Split Dislocation Density (Code by Tim Ruggles, added 3/5/2015)
    if Settings.DoDDS
        disp('Starting split dislocation density...')
        temp = load(Settings.AnalysisParamsPath);
        alpha_data = temp.alpha_data;
        clear temp
        [rhos, DDSettings] = SplitDD(Settings, alpha_data, Settings.DDSMethod);
        if ~isempty(rhos) || ~isempty(DDSettings)
            save(Settings.AnalysisParamsPath,'rhos','-append');
            save(Settings.AnalysisParamsPath,'DDSettings','-append')
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
        Settings.NewAngles(Inds,1),Settings.NewAngles(Inds,2),Settings.NewAngles(Inds,3)...
        ,Settings.SSE);
elseif strcmp(ext,'.ctf')
    WriteHROIMCtfFile(Settings.ScanFilePath,fullfile(OutputPath, ['Corr_' FileName '.ctf']),...
        Settings.NewAngles(Inds,1),Settings.NewAngles(Inds,2),Settings.NewAngles(Inds,3)...
        ,Settings.SSE);
end

% keyboard
% profsave(profile('info'),'profile_results')
%Call output display GUI for curvature, dislocation density, strain, etc.
%output.

%% Output Plotting
% save([OutputPathWithSlash 'Data_' FileName],'data');
if isfield(Settings, 'multiSim') && ~Settings.multiSim
    input{1} = SaveFile;
    OutputPlotting(input); %moved here due to error writing ang file for vaudin files ****
end
