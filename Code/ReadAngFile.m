
function [AngFileVals ScanParams FileName FilePath ] = ReadAngFile(FilePath,FileName)
%READANGFILE
%[AngFileVals ScanParams FileName FilePath ] = ReadAngFile(FilePath,FileName)
%Fast reading .ang files of any size. 
%AngFileVals are cells containing the exact data in each row of the .ang
%file
%ScanParams include scan data, such as pattern center, material name, step
%sizes and scan dimensions.
%Jay Basinger July 10,2009
%Either leave the input blank, and a text dialog box will appear, or
%if the file and pathname are known, pass those in.

if nargin == 1
    fid = fopen(FilePath);
    data = GetFileData(FilePath,'#');
elseif nargin == 2
    fid = fopen([FilePath FileName]);
    data = GetFileData([FilePath FileName],'#');
else
    [FileName FilePath] = uigetfile('*.ang','OIM .ang file');
    fid = fopen([FilePath FileName]);
    data = GetFileData([FilePath FileName],'#');
end

disp('Reading in the .ang file . . . ')

tline = '#';

function ScanParamsData(FileStr,VarName)
    [first,last] = regexp(tline,FileStr);
    val = tline(last+1:end);
    if (first)  
        if ~isempty(str2num(val))
            ScanParams.(VarName) = str2double(tline(last+1:end));
        else
            ScanParams.(VarName) = tline(last+1:end);
        end
    end
end

while ~feof(fid)
    if strcmp(tline(1),'#')
        tline = fgetl(fid);
        
        ScanParamsData('x-star','xstar');
        ScanParamsData('y-star','ystar');
        ScanParamsData('z-star','zstar');
        ScanParamsData('MaterialName','material');
        ScanParamsData('XSTEP','xstep');
        ScanParamsData('YSTEP','ystep');
        ScanParamsData('GRID','GridType');
        ScanParamsData('NCOLS_ODD','NumColsOdd');
        ScanParamsData('NCOLS_EVEN','NumColsEven');
        ScanParamsData('NROWS','NumRows');
        
    else
        %Backs up one line in order to read in first line of data
        fseek(fid, -length(tline)-2, 'cof');
        
        %Reads in correct number of columns
        AngFileVals = textscan(fid, data.format);
    end
end

fclose(fid);
% keyboard
% phi1 = AngFileVals{1,1};
% Phi = AngFileVals{1,2};
% phi2 = AngFileVals{1,3};
% xpos = AngFileVals{1,4};
% ypos = AngFileVals{1,5};
end
