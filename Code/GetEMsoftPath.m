function EMsoftPath = GetEMsoftPath
%Check for EMsoft
EMsoftPath = '';
if exist('SystemSettings.mat','file')
    load SystemSettings
else
    OpenXYPath = fileparts(which('MainGUI'));
end
if ~exist('EMsoftPath','var') || isempty(EMsoftPath)
    sel = questdlg({'EMsoft required, but no path has been specified';'Is EMsoft installed on the local computer?'},'EMsoft not found','Yes','No','Yes');
    if strcmp(sel,'Yes')
        EMsoftPath = uigetdir(OpenXYPath,'Select EMsoft root directory');
    else
        warndlgpause('Cannot use dyamically simulated patterns. Resetting to kinematic simulation.','EMsoft not found');
        return;
    end
end
%Check if EMEBSD command exists
if ~exist(fullfile(EMsoftPath,'bin','EMEBSD'),'file')
    warndlgpause({['EMEBSD command not found in ' fullfile(EMsoftPath,'bin') ','],'Resetting to kinematic simulation.'},'EMsoft not found');
    EMsoftPath = '';
end
save('SystemSettings.mat','OpenXYPath','EMsoftPath');
    
function warndlgpause(msg,title)
h = warndlg(msg,title);
uiwait(h,7);
if isvalid(h); close(h); end;

