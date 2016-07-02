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

%Find Phases
BaseGroups = {info.Groups.Groups.Groups.Name};
HeaderInd = ~cellfun('isempty',strfind(BaseGroups,'Header'));
HeaderGroups = {info.Groups.Groups.Groups(HeaderInd).Groups.Name};
PhaseInd = ~cellfun('isempty',strfind(HeaderGroups,'Phase'));
Phases = {info.Groups.Groups.Groups(HeaderInd).Groups(PhaseInd).Groups.Name};
NumPhase = length(Phases);

%Import Data
Settings.CI = h5read(filepath, [DataName 'CI']);
Settings.Fit = h5read(filepath, [DataName 'Fit']);
Settings.IQ = h5read(filepath, [DataName 'IQ']);
Settings.Angles(:,1) = h5read(filepath, [DataName 'Phi1']);
Settings.Angles(:,2) = h5read(filepath, [DataName 'Phi']);
Settings.Angles(:,3) = h5read(filepath, [DataName 'Phi2']);
Settings.XData = h5read(filepath, [DataName 'X Position']);
Settings.YData = h5read(filepath, [DataName 'Y Position']);

%Import Scan Info
ScanData.CameraAzimuthal = h5read(filepath, [HeaderName 'Camera Azimuthal Angle'])*pi/180;
ScanData.CameraElevation = h5read(filepath, [HeaderName 'Camera Elevation Angle'])*pi/180;
ScanData.SampleTilt = h5read(filepath, [HeaderName 'Sample Tilt'])*pi/180*(-1);
ScanData.PatternHeight = double(h5read(filepath, [HeaderName 'Pattern Height']));
ScanData.PatternWidth = double(h5read(filepath, [HeaderName 'Pattern Width']));
ScanData.StepX = h5read(filepath, [HeaderName 'Step X']);
ScanData.StepY = h5read(filepath, [HeaderName 'Step Y']);
ScanData.xstar = h5read(filepath, [HeaderName '/Pattern Center Calibration/x-star']);
ScanData.ystar = h5read(filepath, [HeaderName '/Pattern Center Calibration/y-star']);
ScanData.zstar = h5read(filepath, [HeaderName '/Pattern Center Calibration/z-star']);

%Import Critical Scan Data
Grid = h5read(filepath, [HeaderName 'Grid Type']);
if strcmp(Grid,'SqrGrid')
    Settings.ScanType = 'Grid';
elseif strcmp(Grid,'Hex')
    Settings.ScanType = 'Hexagonal';
end
Settings.Nx = h5read(filepath, [HeaderName 'nColumns']);
Settings.Ny = h5read(filepath, [HeaderName 'nRows']);
Settings.ScanLength = size(Settings.CI,1);
Settings.ImageNamesList = DataName; %Store location of Pattern Data
Settings.imsize = [ScanData.PatternWidth ScanData.PatternHeight];
Settings.PixelSize = min(ScanData.PatternHeight,ScanData.PatternWidth);
Settings.ROISize = round((Settings.ROISizePercent * .01)*Settings.PixelSize);
Settings.PhosphorSize = Settings.PixelSize * Settings.mperpix;

%Import Material Data
Mat = struct();
for i = 1:NumPhase
    Mat(i).a1 = h5read(filepath, [Phases{i} '/' 'Lattice Constant a']);
    Mat(i).b1 = h5read(filepath, [Phases{i} '/' 'Lattice Constant b']);
    Mat(i).c1 = h5read(filepath, [Phases{i} '/' 'Lattice Constant c']);
    Mat(i).alpha = h5read(filepath, [Phases{i} '/' 'Lattice Constant alpha']);
    Mat(i).beta = h5read(filepath, [Phases{i} '/' 'Lattice Constant beta']);
    Mat(i).gamma = h5read(filepath, [Phases{i} '/' 'Lattice Constant gamma']);
    Mat(i).MaterialName = deblank(char(h5read(filepath, [Phases{i} '/' 'MaterialName'])));
    Mat(i).Symmetry = h5read(filepath, [Phases{i} '/' 'Symmetry']);
end
    
