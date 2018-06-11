function sendBatchResources(obj)

fid = fopen('Temp/OpenXY.sh','w');

Settings = obj.Settings;
[~, jobName, ~] = fileparts(Settings.OutputPath);

if isempty(jobName)
    error('OpenXY:sendBatchResources:NoOutputName',...
        'No output path specified!')
end

[path, imName, imExt] = fileparts(Settings.FirstImagePath);
pathComponents = strsplit(path,filesep);
folderName = pathComponents{end};

firstImagePath = fullfile(folderName, [imName, imExt]);

if ~isempty(obj.options.email)
    sendStart = obj.options.sendStart;
    sendEnd = obj.options.sendEnd;
    sendFail = obj.options.sendFail;
else
    sendStart = false;
    sendEnd = false;
    sendFail = false;
end

fprintf(fid,'#!/bin/bash\n');
%TODO Adjust the time to match the scan size
fprintf(fid,'#SBATCH --time=00:10:00\n');
fprintf(fid,'#SBATCH --ntasks=1\n');
fprintf(fid,'#SBATCH --nodes=1\n');
fprintf(fid,'#SBATCH --mem-per-cpu=1024M\n');
fprintf(fid,'#SBATCH -J "%s"\n',jobName);
fprintf(fid,'#SBATCH --mail-user=%s\n\n',obj.options.email);
if sendStart
    fprintf(fid,'#SBATCH --mail-type=BEGIN\n');
end
if sendEnd
    fprintf(fid,'#SBATCH --mail-type=END\n');
end
if sendFail
    fprintf(fid,'#SBATCH --mail-type=FAIL\n');
end
fprintf(fid,'module add matlab/r2017b\n');
fprintf(fid,...
    'matlab -nodisplay -nojvm -r "EBSDBatch(''./Settings.mat'', ''%s'')"\n',...
    firstImagePath);

fclose(fid);

clean = onCleanup(@() cleanUp() );

obj.connection = ssh2_command(obj.connection, 'mkdir ~/compute/OpenXY');
obj.connection = scp_put(obj.connection, 'Temp/OpenXY.sh',...
    '~/compute/OpenXY/');

save('Temp/Settings.mat','Settings');

obj.connection = scp_put(obj.connection, 'Temp/Settings.mat',...
    '~/compute/OpenXY');

obj.connection = scp_put(obj.connection, '+superComp/EBSDBatch.m',...
    '~/compute/OpenXY');
end


function cleanUp
fclose('all');
if exist('Temp/OpenXY.sh','file')
    delete Temp/OpenXY.sh
end
if exist('Temp/Settings.mat','file')
    delete temp/Settings.mat
end
end