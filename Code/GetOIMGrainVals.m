function GrainVals = GetOIMGrainVals(FullPath,PhaseNum)
% Get data from Grain File
[path, name] = fileparts(FullPath);
GrainFilePath = fullfile(path,[name '.txt']);
if ~exist(GrainFilePath,'file')
    button = questdlg('No matching grain file was found. Would you like to manually select a grain file?','Grain file not found');
    if strcmp(button,'Yes')
        w = pwd;
        cd(path);
        [name, path] = uigetfile({'*.txt', 'Grain Files (*.txt)'},'Select a Grain File');
        cd(w);
        if name == 0
            throw(MException('OpenXY:MissingGrainFile','Cancel'));
        end
        GrainFilePath = fullfile(path,name);
    else
        throw(MException('OpenXY:MissingGrainFile',button));
    end
end

% Read Grain File
GrainFileVals = ReadGrainFile(GrainFilePath);
% Extract out grain ID and Phase
GrainVals.grainID = GrainFileVals{9};
Phase=strtrim(lower(GrainFileVals{11}));
% Validate Phase
GrainVals.Phase = ValidatePhase(Phase);
% Get PhaseNum
if min(PhaseNum) == 0 && max(PhaseNum) == 0
    PhaseNum = PhaseNum + 1;
end
GrainVals.PhaseNum = PhaseNum;