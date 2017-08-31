function [Settings, ScanData, Mat]= ReadHDF5(Settings,name,path)
if nargin < 3
    filepath = name;
else
    filepath = fullfile(path,name);
end

%Get File Info
Settings.ScanFilePath = filepath;
info = h5info(filepath);
ScanName = info.Groups.Name;
DataName = [ScanName '/EBSD/Data/'];
HeaderName = [ScanName '/EBSD/Header/'];

%Get EBSD data
groupNames = {info.Groups.Groups.Name};
EBSDInd = strcmp(groupNames,[ScanName '/EBSD']);

%Find Phases
BaseGroups = {info.Groups.Groups(EBSDInd).Groups.Name};
HeaderInd = ~cellfun('isempty',strfind(BaseGroups,'Header'));
HeaderGroups = {info.Groups.Groups(EBSDInd).Groups(HeaderInd).Groups.Name};
PhaseInd = ~cellfun('isempty',strfind(HeaderGroups,'Phase'));
Phases = {info.Groups.Groups(EBSDInd).Groups(HeaderInd).Groups(PhaseInd).Groups.Name};
NumPhase = length(Phases);

%Import Data
Settings.CI = double(h5read(filepath, [DataName 'CI']));
Settings.Fit = double(h5read(filepath, [DataName 'Fit']));
Settings.IQ = double(h5read(filepath, [DataName 'IQ']));
Settings.Angles(:,1) = double(h5read(filepath, [DataName 'Phi1']));
Settings.Angles(:,2) = double(h5read(filepath, [DataName 'Phi']));
Settings.Angles(:,3) = double(h5read(filepath, [DataName 'Phi2']));
Settings.XData = double(h5read(filepath, [DataName 'X Position']));
Settings.YData = double(h5read(filepath, [DataName 'Y Position']));
PhaseNum = double(h5read(filepath,[DataName 'Phase']));

%Import Scan Info
ScanData.CameraAzimuthal = double(h5read(filepath, [HeaderName 'Camera Azimuthal Angle']))*pi/180;
ScanData.CameraElevation = double(h5read(filepath, [HeaderName 'Camera Elevation Angle']))*pi/180;
ScanData.SampleTilt = double(h5read(filepath, [HeaderName 'Sample Tilt'])*pi/180*(-1));
ScanData.PatternHeight = double(h5read(filepath, [HeaderName 'Pattern Height']));
ScanData.PatternWidth = double(h5read(filepath, [HeaderName 'Pattern Width']));
ScanData.StepX = double(h5read(filepath, [HeaderName 'Step X']));
ScanData.StepY = double(h5read(filepath, [HeaderName 'Step Y']));
ScanData.xstar = double(h5read(filepath, [HeaderName '/Pattern Center Calibration/x-star']));
ScanData.ystar = double(h5read(filepath, [HeaderName '/Pattern Center Calibration/y-star']));
ScanData.zstar = double(h5read(filepath, [HeaderName '/Pattern Center Calibration/z-star']));

%Import Critical Scan Data
Grid = deblank(h5read(filepath, [HeaderName 'Grid Type']));
if strcmp(Grid,'SqrGrid')
    Settings.ScanType = 'Grid';
    Settings.valid = [];
elseif strcmp(Grid,'HexGrid')
    Settings.ScanType = 'Hexagonal';
    valid = ~logical(h5read(filepath, [DataName 'Valid']));
    Settings.CI = Settings.CI(valid);
    Settings.Fit = Settings.Fit(valid);
    Settings.IQ = Settings.IQ(valid);
    Settings.Angles = Settings.Angles(valid,:);
    Settings.XData = Settings.XData(valid);
    Settings.YData = Settings.YData(valid);
    PhaseNum = PhaseNum(valid);
    Settings.valid = valid;
end
Settings.Nx = double(h5read(filepath, [HeaderName 'nColumns']));
Settings.Ny = double(h5read(filepath, [HeaderName 'nRows']));
Settings.ScanLength = size(Settings.CI,1);
Settings.ImageNamesList = DataName; %Store location of Pattern Data
Settings.imsize = [ScanData.PatternWidth ScanData.PatternHeight];
Settings.PixelSize = min(ScanData.PatternHeight,ScanData.PatternWidth);
Settings.ROISize = round((Settings.ROISizePercent * .01)*Settings.PixelSize);
Settings.PhosphorSize = Settings.PixelSize * Settings.mperpix;

%Import Material Data
Mat = struct();
for i = 1:NumPhase
    Mat(i).a1 = double(h5read(filepath, [Phases{i} '/' 'Lattice Constant a']));
    Mat(i).b1 = double(h5read(filepath, [Phases{i} '/' 'Lattice Constant b']));
    Mat(i).c1 = double(h5read(filepath, [Phases{i} '/' 'Lattice Constant c']));
    Mat(i).alpha = double(h5read(filepath, [Phases{i} '/' 'Lattice Constant alpha']));
    Mat(i).beta = double(h5read(filepath, [Phases{i} '/' 'Lattice Constant beta']));
    Mat(i).gamma = double(h5read(filepath, [Phases{i} '/' 'Lattice Constant gamma']));
    Mat(i).MaterialName = deblank(char(h5read(filepath, [Phases{i} '/' 'MaterialName'])));
    Mat(i).Symmetry = double(h5read(filepath, [Phases{i} '/' 'Symmetry']));
end

% Get Grain Vals
Settings.GrainVals = GetOIMGrainVals(filepath,PhaseNum);
    
