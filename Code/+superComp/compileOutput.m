function compileOutput(dirName)

disp(dirName)
currentDir = cd(dirName);

cleanup = onCleanup(@() cd(currentDir));

files = dir;
% Remove navigation files
files(strcmp({files.name}, '.') | strcmp({files.name}, '..')) = [];
fileNames = {files.name};
jobName = regexp(fileNames{1}, 'AnalysisParams_(.+)_\d+.mat', 'tokens');
while iscell(jobName)
    jobName = jobName{1};
end

searchString = ['AnalysisParams_' jobName '_(\d+).mat'];
nums = regexp(fileNames, searchString, 'tokens');
nums(cellfun(@isempty, nums)) = [];
nums = cellfun(@(x) str2double(x{:}), nums);

Settings = [];

for job = nums
    currentFile = ['AnalysisParams_' jobName '_' num2str(job) '.mat'];
    f = load(currentFile);
    if isempty(Settings)
        Settings = f.Settings;
        
    else
        jobInds = Settings.indVectors{job};
        
        Settings.data.SSE(jobInds) = f.Settings.data.SSE(jobInds);
        Settings.data.F(:,:,jobInds) = f.Settings.data.F(:,:,jobInds);
        Settings.data.phi1rn(jobInds) = f.Settings.data.phi1rn(jobInds);
        Settings.data.PHIrn(jobInds) = f.Settings.data.PHIrn(jobInds);
        Settings.data.phi2rn(jobInds) = f.Settings.data.phi2rn(jobInds);
        Settings.data.g(jobInds) = f.Settings.data.g(jobInds);
        Settings.data.sigma(:,:,jobInds) = f.Settings.data.sigma(:,:,jobInds);
        Settings.data.U(:,:,jobInds) = f.Settings.data.U(:,:,jobInds);
        Settings.XX(:,:,jobInds) = f.Settings.XX(:,:,jobInds);
    end
    delete(currentFile)
end
Settings.SSE = Settings.data.SSE;
Settings.AverageSSE = mean(Settings.SSE);
save(['AnalysisParams_' jobName '.mat'],'Settings')
