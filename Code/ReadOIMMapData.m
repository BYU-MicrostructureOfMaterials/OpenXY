%Fast reading of OIM Map data files of any length. Reads the 4th column,
%the color selection when creating a Map from data in OIM Analysis.
%Jay Basinger March 31,2011
 
function [OIMMapVals FileName FilePath ] = ReadOIMMapData(FilePath,FileName)
%Used for OIM .txt Grain files of the first type (based on OIM Analysis 6
%and earlier)

%Either leave the input blank, and a text dialog box will appear, or
%if the file and pathname are known, pass those in.

if nargin == 1
    fid = fopen(FilePath);
elseif nargin == 2
    fid = fopen([FilePath FileName]);
else
    [FileName FilePath] = uigetfile('*.txt','OIM Map file');
    fid = fopen([FilePath FileName]);
end

disp('Reading in the OIM map data file . . . ')


tline = '#';
while ~feof(fid)
    if strcmp(tline(1),'#') == 1
        
        tline = fgetl(fid);       
        
    else
        
        position = ftell(fid);
        status = fseek(fid, -length(tline)-2, 'cof');
        OIMMapVals = textscan(fid, '%f %f %f %f');
        
    end
end

fclose(fid);