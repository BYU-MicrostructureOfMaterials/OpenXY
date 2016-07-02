function EMsoftVarSetup()
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
end