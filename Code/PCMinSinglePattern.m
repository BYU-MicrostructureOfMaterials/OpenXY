function PCprime =  PCMinSinglePattern(Settings, ScanParams, Ind, Algorithm)
if nargin == 3
    Algorithm = 'fminsearch';
end

%Apply Plane Fit
xstar = ScanParams.xstar-Settings.XData(Ind)/Settings.PhosphorSize;
ystar = ScanParams.ystar+Settings.YData(Ind)/Settings.PhosphorSize*sin(Settings.SampleTilt-Settings.CameraElevation);
zstar = ScanParams.zstar+Settings.YData(Ind)/Settings.PhosphorSize*cos(Settings.SampleTilt-Settings.CameraElevation);

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

switch Algorithm
    case 'fminsearch'
        disp('starting fminsearch')
        [PCprime,value,flag,iter] = fminsearch(@(PC)CalcNormFMod(PC,ScanImage,paramspat,Material.lattice,Material.a1,Material.b1,Material.c1,Material.axs,g,Settings.ImageFilter,Ind,Settings),PC0);
    case 'pso'
        disp('starting swarming')
        [PCprime,value,flag,iter] = pso(@(PC)CalcNormFMod(PC,ScanImage,paramspat,Material.lattice,Material.a1,Material.b1,Material.c1,Material.axs,g,Settings.ImageFilter,Ind,Settings),3,[],[],[],[],PC0-0.2,PC0+0.2);
    case 'crosscor'
        disp('starting cross correlation minimization')
        PCprime=PC0;
        for i=1:1 % number of iterations to find best
        xstar=PCprime(1);
        ystar=PCprime(2);
        zstar=PCprime(3);
        pixsize=cell2mat(paramspat(4));
        Av=cell2mat(paramspat(5));
        elevang=cell2mat(paramspat(7));
        mperpix = Settings.mperpix;
        curMaterial=cell2mat(Settings.Phase(Ind)); %****may need updating for material of this point - where is that info?
        for i = 1:3
            I1 = genEBSDPatternHybrid_fromEMSoft(g,xstar,ystar,zstar,pixsize,mperpix,elevang,curMaterial,Av);
            
            clear global rs cs Gs
            %     [F SSE] = CalcF(I1,I0,g,F,ImageInd,Settings,Settings.Material); % old version
            [F SSE] = CalcF(I1,ScanImage,g,eye(3),Ind,Settings,Settings.Phase{Ind}); % new DTF
            [R U] = poldec(F);
            g=R'*g;
        end
        
        [PCprime,value,flag,iter] = fminsearch(@(PC)CalcCross(PC,ScanImage,paramspat,Material.lattice,Material.a1,Material.b1,Material.c1,Material.axs,g,Settings.ImageFilter,Ind,Settings),PC0);
        end
end
%  keyboard

