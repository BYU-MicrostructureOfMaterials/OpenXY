function [Phase, Mat] = UpdatePhase(ScanFilePath, Material, ScanParams, Angles, MaxMisorientation, GrainMethod, MinGrainSize, ScanFileData)
% This function is meant to split up GetGrainInfo.  GetGrainID is the other
% function.  UpdatePhase will include the code for multi-phase scans and
% PhaseValidation.  Phase will not be touched after running this code.

%For now, I copied in all of the inputs for GetGrain info.  I will just
%need to clean that up when I am done writing the function.  

%OUTPUTS - Phase = An array that holds a number identifier for each point
%of the scan.  The number corresponds to the Phase.  Mat = Structure that
%holds the output from ReadMaterial for each Phase/Material.
%
%Written by Jordan Christensen 9/19/16

%Multi-Phase .ang files
clean = true;
if nargin < 7
    MinGrainSize = 10;
elseif MinGrainSize == 0
    clean = false;
end
ReadFile = true;
if iscell(ScanFilePath) && all(size(ScanFilePath)==[1,2])
    ReadFile = false;
    ext = '.ang';
else
    [path, name, ext] = fileparts(ScanFilePath);
end

if ~strcmp(ext,'.ctf')
    if strcmp(GrainMethod,'Grain File')
        if ReadFile
            GrainFilePath = fullfile(path,[name '.txt']);
            if ~exist(GrainFilePath,'file')
                button = questdlg('No matching grain file was found. Would you like to manually select a grain file?','Grain file not found');
                if strcmp(button,'Yes')
                    w = pwd;
                    cd(path);
                    [name, path] = uigetfile({'*.txt', 'Grain Files (*.txt)'},'Select a Grain File');
                    GrainFilePath = fullfile(path,name);
                    cd(w);
                else
                    error('No grain matching ground file was found');
                end
            end
            GrainFileVals = ReadGrainFile(GrainFilePath);
            if ~isempty(GrainFileVals{12})
                GrainFileVals{11} = strcat(GrainFileVals{11}, GrainFileVals{12});
                GrainFileVals{12} = [];
            end
            grainID = GrainFileVals{9};
            Phase = ScanFileData{9};
            num = unique(Phase);
            NumPhases = length(num);
            if length(NumPhases) > 1
                [ind,ok] = listdlg('ListString',ScanParams.material,'PromptString',...
                {'More than one phase detected.';'Mutli- and Single phase scans are supported.';'Select all desired phases:'},...
                'SelectionMode','multiple','Name','Select Phase','ListSize',[180 100]);
                    for i = 1:NumPhases
                        PhaseNames(i,:)={lower(ScanParams.material{i})};
                        disp(['Auto Detected Material: ' PhaseNames(i,:)])
                    end
            else 
                for i = 1:NumPhases
                    PhaseNames(i,:) = {lower(ScanParams.material)};
                    disp(['Auto Detected Material: ' PhaseNames(i,:)])
                end
            end
             PhaseNames = ValidatePhase(PhaseNames);
            for i = 1:NumPhases
                Mat(i,:) = ReadMaterial(PhaseNames{i});
            end
            MaterialData = Mat;
        else
            grainID = ScanFilePath{1};
            Phase = ScanFilePath{2};
            clear ScanFilePath
        end 
        if strcmp(Material,'Scan File');
            disp(['Auto Detected Material: ' PhaseNames{1}])
        else
            Phase = cell(length(Phase),1);
            Phase(:) = {Material};
        end
    end
end
for i = 1:NumPhases
    Mat(i,:) = ReadMaterial(PhaseNames{i});
end

%Multi-Phase .ctf files
if strcmp(GrainMethod,'Find Grains')

    
%Validate Material Detection    
function Phase = ValidatePhase(Phase)
    MaterialsList = GetMaterialsList(2);
    l = length(Phase);
    if ~all(ismember(Phase,MaterialsList))
        invalidMats = unique(Phase(~ismember(Phase,MaterialsList)));
        er = errordlg(['Auto material detection failed. "' strjoin(invalidMats,', ') '" not found in list of known materials'],'Material Detection');
        uiwait(er)
        op = questdlg('Select an option:','Material Detection Failed','Select Existing Material','Create a New Material','Cancel','Select Existing Material');
        while true
            switch op
                case 'Select Existing Material'
                    Materials = GetMaterialsList(3);
                    [index, ok] = listdlg('PromptString','Select a Material','ListString',Materials,'SelectionMode','single','Name','Material Selection');
                    if ok
                        p = length(invalidMats);
                        if p == 1
                            for q = 1:l
                                comp = strcmp(Phase{q,:},invalidMats{p});
                                if comp == 1
                                    Phase(q,:) = Materials(index);
                                end
                            end
%                         else % will be needed if the length of
%                         invalidMats is greater than 1.
                                
                        end
%                         Phase(:) = {Materials{index}};    
                        break;
                    else
                        op = 'Cancel';
                    end
                case 'Create a New Material'
                    material = NewMaterialGUI;
                    if material ~= 0
                        Phase(:) = {material};
                        break;
                    else
                        op = 'Cancel';
                    end
                case 'Cancel'
                    er = warndlg('Material selection failed. Select a new Scan File.','Material Selection');
                    uiwait(er)
                    Phase = {};
                    break;
            end
        end
    end
end
end