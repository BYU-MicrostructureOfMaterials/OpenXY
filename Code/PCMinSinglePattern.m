function PCprime =  PCMinSinglePattern(Settings, ScanParams, Ind)
xstar = ScanParams.xstar-Settings.XData(Ind)/Settings.PhosphorSize;
ystar = ScanParams.ystar+Settings.YData(Ind)/Settings.PhosphorSize*sin(Settings.SampleTilt);
zstar = ScanParams.zstar+Settings.YData(Ind)/Settings.PhosphorSize*cos(Settings.SampleTilt);

PC0(1) = xstar;
PC0(2) = ystar;
PC0(3) = zstar;

Av = Settings.AccelVoltage*1000; %put it in eV from KeV

sampletilt = Settings.SampleTilt;

elevang = Settings.CameraElevation;

pixsize = Settings.PixelSize;

Material = ReadMaterial(Settings.Phase{Ind});

% keyboard
ImagePath = Settings.ImageNamesList{Ind};
ScanImage = ReadEBSDImage(ImagePath,Settings.ImageFilter);

[roixc,roiyc]= GetROIs(ScanImage,Settings.NumROIs,pixsize,Settings.ROISize,...
    Settings.ROIStyle);
Settings.roixc = roixc;
Settings.roiyc = roiyc;

paramspat={xstar;ystar;zstar;pixsize;Av;sampletilt;elevang;Material.Fhkl;Material.dhkl;Material.hkl};

Settings.XStar(1:Settings.ScanLength) = ScanParams.xstar;
Settings.YStar(1:Settings.ScanLength) = ScanParams.ystar;
Settings.ZStar(1:Settings.ScanLength) = ScanParams.zstar;            
            
% g = euler2gmat(Settings.Phi1Ref(Ind),Settings.PHIRef(Ind),Settings.Phi2Ref(Ind));
g = euler2gmat(Settings.Angles(Ind,1),Settings.Angles(Ind,2),Settings.Angles(Ind,3)); % DTF - don't use ref angles for grain as is done on previous line!!
% keyboard
[PCprime,value,flag,iter] = fminsearch(@(PC)CalcNormFMod(PC,ScanImage,paramspat,Material.lattice,Material.a1,Material.b1,Material.c1,Material.axs,g,Settings.ImageFilter,Ind,Settings),PC0);    
%  keyboard

