function [CtfFileVals, ScanParams] = ReadCTFFile(FileName,FilePath)
%CtfFileVals: Cell array containing all data from .ctf file.
%   Phase	X	Y	Bands	Error	Euler1	Euler2	Euler3	MAD	BC	BS
%ScanParams: Struct containing information gathered from header
%Written by Brian Jackson 4/27/2015

if nargin == 1
    [FilePath,FileName,ext] = fileparts(FileName);
    FileName = [FileName,ext];
elseif nargin == 3
    [FileName, FilePath] = uigetfile('*.ctf','HKL .ctf file');
end
ctf = fopen(fullfile(FilePath, FileName));
data = GetFileData(fullfile(FilePath, FileName),'#');
disp('Reading in the .ctf file . . . ')

function ScanParamsData(FileStr, VarName)
%Function to check for a string in file and read in the following data
%   FileStr: String to look for in file
%   VarName: Name of variable to store in ScanParams

    loc = strfind(tline, FileStr);
    if ~isempty(loc)
        if strcmp(VarName,'material')
            a = 1;
        end
        val = strtok(tline(loc(end)+length(FileStr):end));
        ind = 1;
        if isfield(ScanParams,VarName)
            ind = length(ScanParams.(VarName))+1;
        end
        if ~isempty(str2num(val))
            ScanParams.(VarName)(ind) = str2double(val);
        else
            ScanParams.(VarName){ind} = val;
        end
    end
end

ScanParams = struct();
while ~feof(ctf)
    tline = fgetl(ctf);
    if isempty(str2num(tline))
        %Get Header Info
        ScanParamsData('XCells','NumColsEven');
        ScanParamsData('XCells','NumColsOdd');
        ScanParamsData('YCells','NumRows');
        ScanParamsData('XStep','xstep');
        ScanParamsData('YStep','ystep');
        ScanParamsData('KV','AccelVoltage');
        ScanParamsData('TiltAngle','SampleTilt');
    else
        %Read in data table
        fseek(ctf,-length(tline)-2,'cof');
        CtfFileVals = textscan(ctf,data.format);
    end
end
fclose(ctf);

%Open .cpr file
%   Assumes same file name as .ctf file
[~,name] = fileparts(FileName);
CprFilePath = fullfile(FilePath,[name '.cpr']);
if ~exist(CprFilePath,'file')
    yn = questdlg('No .cpr file found. Select one from file?','Missing CPR File','Yes','No','Yes');
    if strcmp(yn,'Yes')
        w = cd;
        cd(FilePath);
        [ctfName, ctfPath] = uigetfile('.cpr','Select a .cpr file');
        cd(w);
        if ctfName == 0
            error('No .cpr file found');
            return;
        end
        CprFilePath = fullfile(ctfPath,ctfName);
    else
        error('No .cpr file found');
        return;
    end
end
cpr = fopen(CprFilePath);
while ~feof(cpr)
   tline = fgetl(cpr);
   ScanParamsData('VHRatio=','VHRatio');
   ScanParamsData('PCX=','PCX');
   ScanParamsData('PCY=','PCY');
   ScanParamsData('DD=','DD');
   ScanParamsData('StructureName=','material');
end
fclose(cpr);

%Calculate Pattern Center
%   Assumes square cropping
%   Formula by DTF
if ~isfield(ScanParams,'PCX') || ~isfield(ScanParams,'PCY') || ~isfield(ScanParams,'VHRatio') || ~isfield(ScanParams,'DD')
    w = warndlg({'No Pattern Center data found. PC vals set to zero.';'Run PC Calibration'},'Missing Info in .CPR file');
    uiwait(w)
    ScanParams.xstar = 0.1;
    ScanParams.ystar = 0.1;
    ScanParams.zstar = 0.1;
else
    ScanParams.xstar = (ScanParams.PCX-(1-ScanParams.VHRatio)/2)/ScanParams.VHRatio;
    ScanParams.ystar = ScanParams.PCY;
    ScanParams.zstar = ScanParams.DD/ScanParams.VHRatio;
end

end
