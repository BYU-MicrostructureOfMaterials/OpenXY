function EMsoftPath = GetEMsoftPath
%Check for EMsoft
EMsoftPath = '';
sysSettings = matfile('SystemSettings.mat', 'Writable', true);
if isprop(sysSettings, 'OpenXYPath')
    OpenXYPath = sysSettings.OpenXYPath;
else
    OpenXYPath = fileparts(which('MainGUI'));
end
if ~isprop(sysSettings,'EMsoftPath') || isempty(sysSettings.EMsoftPath)
    sel = questdlg({'EMsoft required, but no path has been specified';'Is EMsoft installed on the local computer?'},'EMsoft not found','Yes','No','Yes');
    if strcmp(sel,'Yes')
        sysSettings.EMsoftPath = uigetdir(OpenXYPath,'Select EMsoft root directory');
    else
        warndlgpause('Cannot use dyamically simulated patterns. Resetting to kinematic simulation.','EMsoft not found');
        return;
    end
else
    EMsoftPath = sysSettings.EMsoftPath;
end
%Check if EMEBSD command exists
commandName = fullfile(EMsoftPath,'bin','EMEBSD');
if ispc
    commandName = [commandName '.exe'];
end
if ~exist(commandName,'file')
    warndlgpause({['EMEBSD command not found in ' fullfile(EMsoftPath,'bin') ','],'Resetting to kinematic simulation.'},'EMsoft not found');
    EMsoftPath = '';
end
    
function warndlgpause(msg,title)
h = warndlg(msg,title);
uiwait(h,7);
if isvalid(h); close(h); end;
