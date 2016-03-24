% code to map out xstar, ystar, zstar for a load of points in the scan.
%keyboard PCMinSinglePattern and then run this
% maybe throw out, or weight less, points more than x-SDs from minimum point?
% Or based upon IQ of scan image? (I filter out values above a certain
% cutoff and then take median of the remaining points, and that works well
% on Area 1 steel)
tic
numpats=30;  % number of points to take from scan
numpc=10;    % number of PC points to take in each dimension (about 2 points per hour for a grid of 10x10x10 PCs)
deltapc=0.03/numpc;   %step size for PC grid search
ScanParams.xstar=0.527; %local minima for Area1 steel
ScanParams.ystar=0.713;
ScanParams.zstar=0.536;
for qq=1:numpats
    qq
    Ind=round(Settings.ScanLength/numpats*qq);
    Indsave(qq)=Ind;
    %Apply Plane Fit
    xstar = ScanParams.xstar-Settings.XData(Ind)/Settings.PhosphorSize;
    ystar = ScanParams.ystar+Settings.YData(Ind)/Settings.PhosphorSize*sin(Settings.SampleTilt-Settings.CameraElevation);
    zstar = ScanParams.zstar+Settings.YData(Ind)/Settings.PhosphorSize*cos(Settings.SampleTilt-Settings.CameraElevation);
    
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
    g = euler2gmat(Settings.Angles(Ind,1),Settings.Angles(Ind,2),Settings.Angles(Ind,3)); % DTF - don't use ref angles for grain as is done on previous line!!
    
    for xx=1:numpc
        for yy=1:numpc
            for zz=1:numpc
                
                PC0(1) = xstar+(xx-1-(numpc-1)/2)*deltapc;
                PC0(2) = ystar+(yy-1-(numpc-1)/2)*deltapc;
                PC0(3) = zstar +(zz-1-(numpc-1)/2)*deltapc;
                paramspat={xstar;ystar;zstar;pixsize;Av;sampletilt;elevang;Material.Fhkl;Material.dhkl;Material.hkl};
                PCxvals(xx)=PC0(1);
                PCyvals(yy)=PC0(2);
                PCzvals(zz)=PC0(3);
                pctest(qq,xx,yy,zz)=CalcNormFMod(PC0,ScanImage,paramspat,Material.lattice,Material.a1,Material.b1,Material.c1,Material.axs,g,Settings.ImageFilter,Ind,Settings);
            end
        end
    end
end
toc
figure;hold on ;
for i=1:numpats; plot(PCxvals,squeeze(pctest(i,:,10,3)),'*');end
for i=1:numpc; pctemp=squeeze(pctest(:,i,10,3)); thismean(i)=mean(pctemp(pctemp<2e-3))    ;end
for i=1:numpc; pctemp=squeeze(pctest(:,i,10,3)); thismean(i)=median(pctemp(pctemp<3e-3))    ;end
plot(PCxvals,thismean);
pp=polyfit(PCxvals,thismean,2);
PCxopt=-pp(2)/2/pp(1) % find minimum for optimal PCx (note that this is for Given PCy and PCz, so may not be the optimal for all 3)

figure;hold on ;
for i=1:numpats; plot(PCyvals,squeeze(pctest(i,7,:,3)),'*');end
for i=1:numpc; pctemp=squeeze(pctest(:,7,i,3)); thismean(i)=mean(pctemp(pctemp<2e-3))    ;end
for i=1:numpc; pctemp=squeeze(pctest(:,7,i,3)); thismean(i)=median(pctemp(pctemp<3e-3))    ;end
plot(PCyvals,thismean);
pp=polyfit(PCyvals,thismean,2);
PCyopt=-pp(2)/2/pp(1)

figure;hold on ;
for i=1:numpats; plot(PCzvals,squeeze(pctest(i,7,10,:)),'*');end
for i=1:numpc; pctemp=squeeze(pctest(:,7,10,i)); thismean(i)=mean(pctemp(pctemp<2e-3))    ;end
for i=1:numpc; pctemp=squeeze(pctest(:,7,10,i)); thismean(i)=median(pctemp(pctemp<3e-3))    ;end
plot(PCzvals,thismean);
pp=polyfit(PCzvals,thismean,2);
PCzopt=-pp(2)/2/pp(1)

% For area 1 steel:
% PCxopt =   0.521642746394567
% PCyopt =   0.729096609966661
% PCzopt =   0.528060416859464

% to plot surface of median values
for i=1:numpc 
    for j=1:numpc
    pctemp=squeeze(pctest(:,i,j,3)); 
    surfmed(i,j)=median(pctemp(pctemp<2e-3))    ;
    end
end
figure
surf(surfmed)


% now run Fminsearch at all the points and see if the average results
% agrees with the minimum of the CalcNormFMod surface:

PCarray=zeros(numpats,3);
for qq=1:numpats
    qq
    Ind=round(Settings.ScanLength/numpats*qq);
    Indsave(qq)=Ind;
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
    g = euler2gmat(Settings.Angles(Ind,1),Settings.Angles(Ind,2),Settings.Angles(Ind,3)); % DTF - don't use ref angles for grain as is done on previous line!!
    options = optimset('TolX',1e-6,'TolFun',1e-6);
    [PCprime,value,flag,iter] = fminsearch(@(PC)CalcNormFMod(PC,ScanImage,paramspat,Material.lattice,Material.a1,Material.b1,Material.c1,Material.axs,g,Settings.ImageFilter,Ind,Settings),PC0,options);
    PCarray(qq,:)=PCprime(:);
end

figure
plot(PCarray(:,1),PCarray(:,2),'*')
hold on
plot(mean(PCarray(:,1)),mean(PCarray(:,2)),'r*')
% area 1 PCx and y values: 0.523429726772288, 0.726952852711562