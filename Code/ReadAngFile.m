
function [AngFileVals, ScanParams, GrainVals, FileName, FilePath ] = ReadAngFile(FilePath,Settings,FileName)
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
if nargin == 2
    FullPath = FilePath;
elseif nargin == 3
    FullPath = fullfile(FilePath,FileName);
else
    [FileName, FilePath] = uigetfile('*.ang','OIM .ang file');
    FullPath = fullfile(FilePath,FileName);
end
fid = fopen(FullPath);
data = GetFileData(FullPath,'#');

disp('Reading in the .ang file . . . ')

tline = '#';

function ScanParamsData(FileStr,VarName)
    loc = strfind(tline, FileStr);
    if ~isempty(loc)
        val = strtok(tline(loc(end)+length(FileStr):end));
        if ~isempty(str2num(val))
            ScanParams.(VarName) = str2double(val);
        else
            ScanParams.(VarName) = val;
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
        ScanParamsData('XSTEP:','xstep');
        ScanParamsData('YSTEP:','ystep');
        ScanParamsData('GRID:','GridType');
        ScanParamsData('NCOLS_ODD:','NumColsOdd');
        ScanParamsData('NCOLS_EVEN:','NumColsEven');
        ScanParamsData('NROWS:','NumRows');
        
    else
        %Backs up one line in order to read in first line of data
        fseek(fid, -length(tline)-2, 'cof');
        
        %Reads in correct number of columns
        AngFileVals = textscan(fid, data.format);
    end
end
Settings.Angles(:,1) = AngFileVals{1};
Settings.Angles(:,2) = AngFileVals{2};
Settings.Angles(:,3) = AngFileVals{3};
Settings.XData=AngFileVals{4};
Settings.YData=AngFileVals{5};
X=unique(Settings.XData);
Y=unique(Settings.YData);
%ScanParams.NumColsOdd=length(X);
%ScanParams.NumRows=length(Y);
Settings.Nx = ScanParams.NumColsOdd;
Settings.Ny = ScanParams.NumRows;
fclose(fid);
Settings.mater = ScanParams.material;
% Get Grain Vals
PhaseNum = AngFileVals{8};
GrainVals = GetOIMGrainVals(FullPath,PhaseNum,Settings);

% phi1 = AngFileVals{1,1};
% Phi = AngFileVals{1,2};
% phi2 = AngFileVals{1,3};
% xpos = AngFileVals{1,4};
% ypos = AngFileVals{1,5};
end
