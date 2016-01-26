
%Get Indices for Si and SiGe points
SecInds = Settings.ScanData.SecInds;
if abs(SecInds(end)-Settings.ScanLength)<5
    SecInds(end) = Settings.ScanLength;
end
Si = []; SiGe = [];
for i = 1:2:length(Settings.ScanData.SecInds)
    if i < length(SecInds)
        Si = [Si,SecInds(i):SecInds(i+1)];
    end
    if i > 1
        SiGe = [SiGe,SecInds(i-1):SecInds(i)];
    end
end

%Find which scan it is
if Settings.ScanLength == 280
    scan = 'S01';
    orientation_si = [345.5897+90, 2.388155, 58.12967];
    orientation_sige = [343.999+90, 2.232049, 59.74352];
else
    scan = 'i02';
    orientation_si = [337.2512+90, 2.508753, 66.73377];
    orientation_sige = [330.0111+90, 2.656822, 71.37617];
    warndlg('No patterns for this yet')
    return;
end

PC = [Settings.XStar(1) ,Settings.YStar(1),Settings.ZStar(1)];
Angles = zeros(Settings.ScanLength,3);
Angles(Si,:) = repmat(orientation_si,length(Si),1);
Angles(SiGe,:) = repmat(orientation_sige,length(SiGe),1);

%Predicted Tetragonality
tet = (1:0.5:3)/100;

%Get Parameters from Settings Structure
xstar = PC(1);
ystar = PC(2);
zstar = PC(3);
Av = Settings.AccelVoltage*1000; %put it in eV from KeV
sampletilt = Settings.SampleTilt;
elevang = Settings.CameraElevation;
pixsize = Settings.PixelSize;
mperpix = Settings.mperpix;

%Set Folder
folder = '/Volumes/Shared/MarkVaudin-Line Scans/S01 Simulated Tet';

%Convert Angles to .ang format
Angles = Angles*pi/180;

for ScanNum = 1:1%length(tet)
    %Create Folder Structure
    ScanName = [scan '_Sim_' num2str(ScanNum)];
    ImageFolder = fullfile(folder,[ScanName '_Images']);
    if ~isdir(ImageFolder)
        mkdir(ImageFolder);
    end
    
    %Silicon Images
    Material = Settings.Phase{1};
    g = euler2gmat(Angles(Si(1),1),Angles(Si(1),2),Angles(Si(1),3));
    RefImage = genEBSDPatternHybrid_fromEMSoft(g,xstar,ystar,zstar,pixsize,mperpix,elevang,Material,Av);
    for i = 1:length(Si)
        %imwrite(RefImage,gray(256),fullfile(ImageFolder,[ScanName '_' sprintf('%03d',Si(i)) '.jpg']),'jpg');
    end
    
    %Silicon Germanium Images
    Material = ['Si_' num2str(ScanNum)];
    g = euler2gmat(Angles(SiGe(1),1),Angles(SiGe(1),2),Angles(SiGe(1),3));
    RefImage = genEBSDPatternHybrid_fromEMSoft(g,xstar,ystar,zstar,pixsize,mperpix,elevang,Material,Av);
    for i = 1:length(SiGe)
        imwrite(RefImage,gray(256),fullfile(ImageFolder,[ScanName '_' sprintf('%03d',SiGe(i)) '.jpg']),'jpg');
    end
    
    %Write .ctf File
    OutputFile = fullfile(folder,[ScanName '.ctf']);
    WriteHROIMCtfFile(Settings.ScanFilePath, OutputFile,...
        Angles(:,1),Angles(:,2),Angles(:,3)...
        ,Settings.SSE);
end

