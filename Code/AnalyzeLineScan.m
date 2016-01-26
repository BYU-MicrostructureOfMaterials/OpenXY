function Results = AnalyzeLineScan(Settings)
saved = 1;
addpath('Line Scan Analysis');
a = LineScanAnalysis;
if ~exist([Settings.AnalysisParamsPath '.mat'],'file')
    uiwait(msgbox('Analysis Params file not found'));
    [file, folder] = uigetfile;
    [~,file] = fileparts(file);
    Settings.AnalysisParamsPath = fullfile(folder,file);
end
a.addScan('Scan',[Settings.AnalysisParamsPath '.mat']);
a.SetBaseline('Scan');
if ~isfield(Settings,'ScanData') || ~isfield(Settings.ScanData,'SecInds')
    uiwait(msgbox('Select the baseline scan'))
    a.addScan('Baseline');
    a.SetBaseline('Baseline');
    SecInds = a.SectionInds;
    Settings.ScanData.SecInds = SecInds;
    a.RemoveScan('Baseline');
    a.SetBaseline('Scan');
    saved = false;
end
a.SectionInds = Settings.ScanData.SecInds;
if ~isfield(Settings,'ScanData') || ~isfield(Settings.ScanData,'ExpTet')
    a.SetTet;
    Settings.ScanData.ExpTet = a.ExpTet;
    Settings.ScanData.ExpTetTol = a.ExpTetTol;
else
    a.ExpTet = Settings.ScanData.ExpTet;
    a.ExpTetTol = Settings.ScanData.ExpTetTol;
end
Comparison = a.CompareScans;
figure;

%a.Scans('Scan').plotXX;
Results = Comparison(:,{'StrainStdDev','TetStdDev','SSE'});
Results = [varfun(@(x) x(1),Results);varfun(@(x) x(2),Results)];
Results.Properties.RowNames = {'Si','SiGe'};
Results.Properties.VariableNames = {'StrainStdDev','TetStdDev','SSE'};
Results.TetDiff = [0; Comparison.TetDiff];
assignin('base','Results',Results);
disp(Results)
if ~saved
    button = questdlg('Save Scan Data to AnalysisParams file?','Analyze Line Scan','Yes','No','Yes');
    if strcmp(button,'Yes')
        save([Settings.AnalysisParamsPath '.mat'],'Settings');
    end
end
