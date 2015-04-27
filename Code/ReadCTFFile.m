function [CtfFileVals, ScanParams] = ReadCTFFile(FilePath,FileName)
%CtfFileVals: Cell array containing all data from .ctf file.
%   Phase	X	Y	Bands	Error	Euler1	Euler2	Euler3	MAD	BC	BS
%ScanParams: Struct containing information gathered from header
%Written by Brian Jackson 4/27/2015

if nargin == 1
    fid = fopen(FilePath);
    data = GetFileData(FilePath,'#');
elseif nargin == 2
    fid = fopen([FilePath FileName]);
    data = GetFileData([FilePath FileName],'#');
else
    [FileName FilePath] = uigetfile('*.ctf','HKL .ctf file');
    fid = fopen([FilePath FileName]);
    data = GetFileData([FilePath FileName],'#');
end

disp('Reading in the .ctf file . . . ')

function ScanParamsData(FileStr, VarName)
    loc = strfind(tline, FileStr);
    if ~isempty(loc)
        val = strtok(tline(loc(end)+length(FileStr):end));
        if ~isempty(str2num(val))
            ScanParams.(VarName) = str2double(strtok(tline(loc(end)+length(FileStr):end)));
        else
            ScanParams.(VarName) = val;
        end
    end
end

ScanParams = struct();
while ~feof(fid)
    tline = fgetl(fid);
    if isempty(str2num(tline))
        ScanParamsData('XCells','NumColsEven');
        ScanParamsData('XCells','NumColsOdd');
        ScanParamsData('YCells','NumRows');
        ScanParamsData('XStep','xstep');
        ScanParamsData('YStep','ystep');
        ScanParamsData('KV','AccelVoltage');
        ScanParamsData('TiltAngle','SampleTilt');
    else
        fseek(fid,-length(tline)-2,'cof');
        CtfFileVals = textscan(fid,data.format);
    end
end
fclose(fid);
end
