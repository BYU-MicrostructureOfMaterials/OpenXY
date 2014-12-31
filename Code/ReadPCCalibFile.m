%Reads Patter Center Calibration File
%Jay Basinger April 6,2011
 
function [PCData FileName FilePath ] = ReadPCCalibFile(FilePath,FileName)
%Used for OIM .txt Grain files of the first type (based on OIM Analysis 6
%and earlier)

%Either leave the input blank, and a text dialog box will appear, or
%if the file and pathname are known, pass those in.

if nargin == 1
    fid = fopen(FilePath,'rt');
elseif nargin == 2
    fid = fopen([FilePath FileName],'rt');
else
    [FileName FilePath] = uigetfile('*.txt','PC calibration file');
    fid = fopen([FilePath FileName],'rt');
end

disp('Reading in the pattern center data file . . . ')


tline = '#';
while ~feof(fid)
    if strcmp(tline(1),'#') == 1
        
        tline = fgetl(fid);       
        
    else
        
        position = ftell(fid);
        status = fseek(fid, -length(tline)-2, 'cof');
        PCData = textscan(fid, '%u %f %f %f %f %f %f');
        
    end
end

fclose(fid);