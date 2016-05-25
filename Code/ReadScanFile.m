
function [ScanFileData, ScanParams] = ReadScanFile(ScanFilePath)
% Reads .ang and .ctf Scan files into arrays. Converts .ctf angles to .ang
%   orientation
% ScanFileData columns:
%   1-3: Euler Angles
%   4-5: Position data
%   6: Image Quality
%   7: Confidence Index
%   10: Fit

[~, ~, ext] = fileparts(ScanFilePath);
if strcmp(ext, '.ang')
    [ScanFileData, ScanParams] = ReadAngFile(ScanFilePath); 
elseif strcmp(ext,'.ctf')
    [ScanFileData, ScanParams] = ReadCTFFile(ScanFilePath);
    %Reorder columns to the same format as .ang file
    ScanFileData(:,[1,2,3,4,5,6,7,8,9,10])=ScanFileData(:,[6,7,8,2,3,10,11,5,1,9]);
    ScanFileData = ScanFileData(:,1:end-1);
    %Convert angles to radians
    ScanFileData{1} = (ScanFileData{1}+90)*(pi/180);
    ScanFileData{2} = ScanFileData{2}*(pi/180);
    ScanFileData{3} = ScanFileData{3}*(pi/180);
else
    ScanFileData = {}; ScanParams = struct([]);
end
end