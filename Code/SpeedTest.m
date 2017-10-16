
if ~exist('Settings','var')
    warndlg('No Settings structure found')
    return;
end
ImageInd = 4;
curMaterial = Settings.Phase{ImageInd};

%Read Image
ImagePath = Settings.ImageNamesList{ImageInd};
if strcmp(Settings.ImageFilterType,'standard')
    ScanImage = ReadEBSDImage(ImagePath,Settings.ImageFilter);
else
    ScanImage = localthresh(ImagePath);
end
g = euler2gmat(Settings.Angles(ImageInd,1) ...
    ,Settings.Angles(ImageInd,2),Settings.Angles(ImageInd,3));
if isempty(ScanImage)
    F = -eye(3); SSE = 101; U = -eye(3);
    return;
end

%Set up params array
xstar = Settings.XStar(ImageInd);
ystar = Settings.YStar(ImageInd);
zstar = Settings.ZStar(ImageInd);
Av = Settings.AccelVoltage*1000; %put it in eV from KeV
sampletilt = Settings.SampleTilt;
elevang = Settings.CameraElevation;
pixsize = Settings.PixelSize;
Material = ReadMaterial(curMaterial);  % this should depend on the crystal structure maybe not here
mperpix = Settings.mperpix;
paramspat={xstar;ystar;zstar;pixsize;Av;sampletilt;elevang;Material.Fhkl;Material.dhkl;Material.hkl};
gr=g;

%Get ROIs
if strcmp(Settings.ROIStyle,'Intensity')
    I1 = genEBSDPatternHybrid(g,paramspat,eye(3),Material.lattice,Material.a1,Material.b1,Material.c1,Material.axs); %use high intensity points in simulated image rather than real image to pick ROI points
    [roixc,roiyc]= GetROIs(I1,Settings.NumROIs,pixsize,Settings.ROISize,...
        Settings.ROIStyle);
    Settings.roixc = roixc;
    Settings.roiyc = roiyc;
    
else
    [roixc,roiyc]= GetROIs(ScanImage,Settings.NumROIs,pixsize,Settings.ROISize,...
        Settings.ROIStyle);
    Settings.roixc = roixc;
    Settings.roiyc = roiyc;
end

NumRep = 10;

%Kinematic Patterns
tic
for i = 1:NumRep
    RefImage = genEBSDPatternHybrid(gr,paramspat,eye(3),Material.lattice,Material.a1,Material.b1,Material.c1,Material.axs);
    RefImage = custimfilt(RefImage,Settings.ImageFilter(1), ...
            Settings.PixelSize,Settings.ImageFilter(3),Settings.ImageFilter(4));
end
toc

%Dynamic Patterns
load SystemSettings
if ~exist('EMsoftPath','var') || isempty(EMsoftPath)
    warndlg('EMsoft not set up');
    return;
end
tic
for i = 1:NumRep
    RefImage = genEBSDPatternHybrid_fromEMSoft(gr,xstar,ystar,zstar,pixsize,mperpix,elevang,sampletilt,curMaterial,Av);
end
toc