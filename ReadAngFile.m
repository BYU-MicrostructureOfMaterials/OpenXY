
 
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

%or comment out the above and manually enter filename
% fid = fopen('58recrystal.ang');
tline = '#';
cnt=0;
while ~feof(fid)
    if strcmp(tline(1),'#') == 1
        tline = fgetl(fid);
        
        [first,last] = regexp(tline,'x-star');
        if (first)
            ScanParams.xstar = str2double(tline(last+1:end));
        end
        [first,last] = regexp(tline,'y-star');
        if (first)
            ScanParams.ystar = str2double(tline(last+1:end));
        end
        [first,last] = regexp(tline,'z-star');
        if (first)
            ScanParams.zstar = str2double(tline(last+1:end));
        end
        [first,last] = regexp(tline,'MaterialName');
        if (first)
            ScanParams.material = lower(strtrim((tline(last+1:end))));
        end
        [first,last] = regexp(tline,'XSTEP:');
        if (first)   
            ScanParams.xstep =str2double(tline(last+1:end));
        end
        [first,last] = regexp(tline,'YSTEP:');
        if (first)
            ScanParams.ystep = str2double(tline(last+1:end));
        end
        [first,last] = regexp(tline,'GRID:');
        if (first)
            ScanParams.GridType = strtrim((tline(last+1:end)));
        end
        [first,last] = regexp(tline,'NCOLS_ODD:');
        if (first)
            ScanParams.NumColsEven = str2double(strtrim((tline(last+1:end))));
        end
        [first,last] = regexp(tline,'NCOLS_EVEN:');
        if (first)
            ScanParams.NumColsOdd = str2double(strtrim((tline(last+1:end))));
        end
        [first,last] = regexp(tline,'NROWS:');
        if (first)
            ScanParams.NumRows = str2double(strtrim((tline(last+1:end))));
        end
        
    else
        cnt=cnt+1;
        %Backs up one line in order to read in first line of data
        position = ftell(fid);
        status = fseek(fid, -length(tline)-2, 'cof');
        
        %Reads in correct number of columns
        AngFileVals = textscan(fid, data.format);
        
        %disp(cnt)
    end
end

fclose(fid);
% keyboard
% phi1 = AngFileVals{1,1};
% Phi = AngFileVals{1,2};
% phi2 = AngFileVals{1,3};
% xpos = AngFileVals{1,4};
% ypos = AngFileVals{1,5};
