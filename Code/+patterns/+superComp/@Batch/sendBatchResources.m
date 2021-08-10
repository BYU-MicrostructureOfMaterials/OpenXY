function sendBatchResources(obj)
% SENDBATCHRESOURCES Send resources needed for every job.
%   SENDBATCHRESOURCES Sends the Settings struct, scan file (.ang or .ctf),
%   the material file and the job script to the supercomputer. This step is
%   not optional, as this information is unique to every scan run.

%   See also BATCH.SENDIMAGES, BATCH.SENDSOURCE

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
Settings.FirstImagePath = strrep(firstImagePath, '\', '/');


obj.connection = scp_put(obj.connection, '+superComp/jobScript.sh',...
    '~/compute/OpenXY/');

obj.connection = scp_put(obj.connection, '+superComp/OpenXY.sh',...
    '~/compute/OpenXY/');

obj.connection = scp_put(obj.connection, '+superComp/compileOutput.m',...
    '~/compute/OpenXY/');

obj.connection = scp_put(obj.connection, '+superComp/compile.sh',...
    '~/compute/OpenXY/');

clean = onCleanup(@() cleanUp() );

sendMaterialFile(obj)
sendScanFile(obj)

Settings = splitScan(Settings, obj.options.numJobs);
obj.maxJobLength = max(cellfun(@length, Settings.indVectors));
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

function sendMaterialFile(obj)
Settings = obj.Settings;
if strcmpi(Settings.Material, 'Scan File')
    phases = unique(Settings.Phase(:)');
else
    phases = {Settings.Material};
end
material_files = cell(size(phases));
ind = 1;
for material = phases
    [~, material_files{ind}] = ReadMaterial(material{1});
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
end


function cleanUp
if exist('temp/Settings.mat','file')
    delete temp/Settings.mat
end
end