function sendBatchResources(obj)
% SENDBATCHRESOURCES Send resources needed for every job.
%   SENDBATCHRESOURCES Sends the Settings struct, scan file (.ang or .ctf),
%   the material file and the job script to the supercomputer. This step is
%   not optional, as this information is unique to every scan run.

%   See also BATCH.SENDIMAGES, BATCH.SENDSOURCE
fid = fopen('temp/OpenXY.sh','w');

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

fprintf(fid,'#!/bin/tcsh\n');
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

sendMaterial(obj)
sendScanFile(obj)

Settings = splitScan(Settings, obj.options.numJobs);
save('temp/Settings.mat','Settings');

obj.connection = scp_put(obj.connection, 'temp/Settings.mat',...
    '~/compute/OpenXY');

obj.connection = scp_put(obj.connection, '+superComp/EBSDBatch.m',...
    '~/compute/OpenXY');
end


function Settings = splitScan(Settings, numJobs)
% SPLITSCAN divides a scan into a given number of jobs.
% Creates a field in Settings called indVectors that has the point indicies
% for each of the numJobs jobs

jobInds = discretize(1:Settings.ScanLength, numJobs);
indVectors = cell(1, jobInds(end));

for ii = 1:Settings.ScanLength
    temp = indVectors{jobInds(ii)};
    temp(end+1) = ii;
    indVectors{jobInds(ii)} = temp;
end

Settings.indVectors = indVectors;
end

function sendMaterial(obj)
Settings = obj.Settings;
if strcmpi(Settings.Material, 'Scan File')
    phases = unique(Settings.Phase(:)');
else
    phases = {Settings.Material};
end
material_files = cell(size(phases));
ind = 1;
for material = phases
    [~, material_files{ind}] = ReadMaterial(material);
    ind = ind + 1;
end
material_files = cellfun(@(x) strrep(x,pwd,''), material_files, 'UniformOutput', false);

obj.connection = ssh2_command(obj.connection,...
    'mkdir ~/compute/OpenXY/Materials');

obj.connection = scp_put(obj.connection, material_files,...
    '~/compute/OpenXY/Materials/');
end


function sendScanFile(obj)
[scan_path, scan_file, scan_ext] = fileparts(obj.Settings.ScanFilePath);

obj.connection = ssh2_command(obj.connection, 'mkdir ~/compute/OpenXY');
obj.connection = scp_put(obj.connection, [scan_file scan_ext],...
    '~/compute/OpenXY/', scan_path);
obj.connection = scp_put(obj.connection, 'temp/OpenXY.sh',...
    '~/compute/OpenXY/');

end


function cleanUp
fclose('all');
if exist('temp/OpenXY.sh','file')
    delete temp/OpenXY.sh
end
if exist('temp/Settings.mat','file')
    delete temp/Settings.mat
end
end