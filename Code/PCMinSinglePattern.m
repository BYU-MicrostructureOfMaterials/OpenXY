function PCprime =  PCMinSinglePattern(Settings, ScanParams, Ind, Algorithm)
if nargin == 3
    Algorithm = 'fminsearch';
end

%Apply Plane Fit
if isfield(Settings,'XStar')
    xstar = Settings.XStar(Ind);
    ystar = Settings.YStar(Ind);
    zstar = Settings.ZStar(Ind);
else
    if strcmp(Settings.PlaneFit,'Naive')
        xstar = ScanParams.xstar-Settings.XData(Ind)/Settings.PhosphorSize;
        ystar = ScanParams.ystar+Settings.YData(Ind)/Settings.PhosphorSize*sin(Settings.SampleTilt-Settings.CameraElevation);
        zstar = ScanParams.zstar+Settings.YData(Ind)/Settings.PhosphorSize*cos(Settings.SampleTilt-Settings.CameraElevation);
    else
        xstar = ScanParams.xstar;
        ystar = ScanParams.ystar;
        zstar = ScanParams.zstar;
    end
end

PC0(1) = xstar;
PC0(2) = ystar;
PC0(3) = zstar;

Av = Settings.AccelVoltage*1000; %put it in eV from KeV

sampletilt = Settings.SampleTilt;

elevang = Settings.CameraElevation;

pixsize = Settings.PixelSize;

Material = ReadMaterial(Settings.Phase{Ind});

% keyboard
if size(Settings.ImageNamesList,1)>1
    ImagePath = Settings.ImageNamesList{Ind};
    ScanImage = ReadEBSDImage(ImagePath,Settings.ImageFilter);
else
    ScanImage = ReadH5Pattern(Settings.ScanFilePath,Settings.ImageNamesList,Settings.imsize,Settings.ImageFilter,Ind);
end

[roixc,roiyc]= GetROIs(ScanImage,Settings.NumROIs,pixsize,Settings.ROISize,...
    Settings.ROIStyle);
Settings.roixc = roixc;
Settings.roiyc = roiyc;
standev = Settings.StandardDeviation;
ROISize = Settings.ROISize;

paramspat={xstar;ystar;zstar;pixsize;Av;sampletilt;elevang;Material.Fhkl;Material.dhkl;Material.hkl};

% Settings.XStar(1:Settings.ScanLength) = ScanParams.xstar; % commented out by DTF 3/10/16 - we should not be resetting all XStars here?!?!?!?
% Settings.YStar(1:Settings.ScanLength) = ScanParams.ystar;
% Settings.ZStar(1:Settings.ScanLength) = ScanParams.zstar;

% g = euler2gmat(Settings.Phi1Ref(Ind),Settings.PHIRef(Ind),Settings.Phi2Ref(Ind));
g = euler2gmat(Settings.Angles(Ind,1),Settings.Angles(Ind,2),Settings.Angles(Ind,3)); % DTF - don't use ref angles for grain as is done on previous line!!
% keyboard

switch Algorithm
    case 'fminsearch'
        disp('starting fminsearch')
        options = optimset('TolX',1e-6,'TolFun',1e-6);
        [PCprime,value,flag,iter] = fminsearch(@(PC)CalcNormFMod(PC,ScanImage,paramspat,Material.lattice,Material.a1,Material.b1,Material.c1,Material.axs,g,Settings.ImageFilter,Ind,Settings),PC0,options);
    case 'pso'
        disp('starting swarming')
        [PCprime,value,flag,iter] = pso(@(PC)CalcNormFMod(PC,ScanImage,paramspat,Material.lattice,Material.a1,Material.b1,Material.c1,Material.axs,g,Settings.ImageFilter,Ind,Settings),3,[],[],[],[],PC0-0.2,PC0+0.2);
    case 'crosscor'
        disp('starting cross correlation minimization')
        PCprime=PC0;
        for ii=1:1 % number of iterations to find best
            if strcmp(Settings.HROIMMethod,'Dynamic Simulated')
                xstar=PCprime(1);
                ystar=PCprime(2);
                zstar=PCprime(3);
                pixsize=cell2mat(paramspat(4));
                Av=cell2mat(paramspat(5));
                elevang=cell2mat(paramspat(7));
                mperpix = Settings.mperpix;
                curMaterial=cell2mat(Settings.Phase(Ind)); %****may need updating for material of this point - where is that info?
                for i = 1:3
                    I1 = genEBSDPatternHybrid_fromEMSoft(g,xstar,ystar,zstar,pixsize,mperpix,elevang,curMaterial,Av,Ind);
                    
                    clear global rs cs Gs
                    %     [F SSE] = CalcF(I1,I0,g,F,ImageInd,Settings,Settings.Material); % old version
                    [F SSE] = CalcF(I1,ScanImage,g,eye(3),Ind,Settings,...
                        Settings.Phase{Ind},0,PC0,roixc,roiyc,...
                        Settings.ROIFilter,ROISize,standev); % new DTF
                    [R U] = poldec(F);
                    g=R'*g;
                end
            else
                % Remove rotational error first DTF 7/15/14
                X = Settings.ImageFilter;
                for i = 1:3
                    I1 = genEBSDPatternHybrid(g,paramspat,eye(3),Material.lattice,Material.a1,Material.b1,Material.c1,Material.axs);
                    I1 = custimfilt(I1,X(1),Settings.PixelSize,X(3),X(4));
                    clear global rs cs Gs
                    %     [F SSE] = CalcF(I1,I0,g,F,ImageInd,Settings,Settings.Material); % old version
                    [F SSE] = CalcF(I1,ScanImage,g,eye(3),Ind,Settings,...
                        Settings.Phase{Ind},0,PC0,roixc,roiyc,...
                        Settings.ROIFilter,ROISize,standev); % new DTF
                    [R U] = poldec(F);
                    g=R'*g;
                end
                F=eye(3);
                for i = 1:Settings.IterationLimit
                    %for i = 1:3
                    I1 = genEBSDPatternHybrid(g,paramspat,F,Material.lattice,Material.a1,Material.b1,Material.c1,Material.axs);
                    I1 = custimfilt(I1,X(1),Settings.PixelSize,X(3),X(4));
                    
                    %Optical Distortion Only
                    %  crpl=206; crpu=824;
                    %  I1 = I1(crpl:crpu,crpl:crpu);
                    clear global rs cs Gs
                    %     [F SSE] = calcFnew(I1,I0,g,F,paramsF,standev,6);
                    %     [F SSE] = CalcF(I1,I0,g,F,ImageInd,Settings,Settings.Material);% ** same change as above DTF 7/21/14
                    [F SSE] = CalcF(I1,ScanImage,g,F,Ind,Settings,...
                        Settings.Phase{Ind},0,PC0,roixc,roiyc,...
                        Settings.ROIFilter,ROISize,standev);
                end
            end
            
            [PCprime,value,flag,iter] = fminsearch(@(PC)CalcCross(PC,ScanImage,paramspat,Material.lattice,Material.a1,Material.b1,Material.c1,Material.axs,g,F,Settings.ImageFilter,Ind,Settings),PC0);
        end
    case 'findmperpix' % attempt to find phosphor size at sime time as PC; does not work well; but I don't think I modified scan image correctly in CalcNormFMod2. DTF Feb 10 2016
        xmax=0;
        ymax=0;
        xymax=0;
        for i=1:Settings.ScanLength % find points at limits of scan
            if Settings.XData(i)>xmax
                xmax=Settings.XData(i);
                xind=i;
            end
            if Settings.YData(i)>ymax
                ymax=Settings.YData(i);
                yind=i;
            end
            if Settings.XData(i)*Settings.YData(i)>xymax
                xymax=Settings.XData(i)*Settings.YData(i);
                xyind=i;
            end
        end
        Ind=[Ind xind yind xyind];
        options = optimset('TolX',1e-6,'TolFun',1e-6);
        [PCprime,value,flag,iter] = fminsearch(@(PC)CalcNormFMod2(PC,ScanImage,paramspat,Material.lattice,Material.a1,Material.b1,Material.c1,Material.axs,g,Settings.ImageFilter,Ind,Settings),[PC0 Settings.mperpix],options);
        keyboard
end

