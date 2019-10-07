function EMsoftVarSetup()
%

% This function is not currently used, but I am refactoring this to make it
% complient with changes to the rest of the program
sysSettings = matfile('SystemSettings.mat', 'Writable', true);

if ~isprop(sysSettings, 'EMsoftPath') || ~exist(sysSettings.EMsoftPath, 'file')
    error('EMsoft path is unknown. Re-select in Advanced Settings');
end

EMdataPath = fullfile(fileparts(sysSettings.EMsoftPath),'EMdata');
if ~exist(EMdataPath,'dir')
    error('EMsoft path is incorrect. Re-select in Advanced Settings');
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
end
