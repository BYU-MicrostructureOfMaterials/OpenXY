function PCData = PCCalAlkorta(Settings,PlaneFit,Inds)

if nargin < 3
    %Select Calibration Points
    try
        Inds = SelectCalibrationPoints([Settings.Nx,Settings.Ny],Settings.IQ,Settings.Angles);
    catch ME
        disp('in the catch')
        rethrow(ME)
    end
end

Settings.DoShowPlot = true;

%Perform Strain Minimization PC Calibration
npoints = length(Inds);
CalibrationPointsPC = zeros(npoints,3);

Av = Settings.AccelVoltage*1000; %put it in eV from KeV

sampletilt = Settings.SampleTilt;

elevang = Settings.CameraElevation;

pixsize = Settings.PixelSize;

iterCalcF = 12;



Settings.SampleTilt
Settings.CameraElevation


NumCores = min(Settings.DoParallel, npoints);
try
    ppool = gcp('nocreate');
    if isempty(ppool)
        parpool(NumCores);
    end
catch
    ppool = matlabpool('size');%#ok
    if ~ppool
        matlabpool('local',NumCores);%#ok 
    end
end
M = NumCores;
pctRunOnAll javaaddpath('java')
ppm = ParforProgMon( 'Point Calibration ', npoints,1,400,50 );

if size(Settings.ImageNamesList,1)>1
    ImagePath = Settings.ImageNamesList{1};
    ScanImage = ReadEBSDImage(ImagePath,Settings.ImageFilter);
else
    ScanImage = ReadH5Pattern(Settings.ScanFilePath,Settings.ImageNamesList,Settings.imsize,Settings.ImageFilter,1);
end

[roixc,roiyc]= GetROIs(ScanImage,Settings.NumROIs,pixsize,Settings.ROISize,...
    Settings.ROIStyle);
Settings.roixc = roixc;
Settings.roiyc = roiyc;

%Single Processor Calculation
for i=1:npoints
    
    Ind = Inds(i);
    
    if isfield(Settings,'XStar')
        xstar = Settings.XStar(Ind);
        ystar = Settings.YStar(Ind);
        zstar = Settings.ZStar(Ind);
    else
        if strcmp(Settings.PlaneFit,'Naive')
            xstar = Settings.ScanParams.xstar-Settings.XData(Ind)/Settings.PhosphorSize;
            ystar = Settings.ScanParams.ystar+Settings.YData(Ind)/Settings.PhosphorSize*sin(pi/2 - Settings.SampleTilt + Settings.CameraElevation);
            zstar = Settings.ScanParams.zstar+Settings.YData(Ind)/Settings.PhosphorSize*cos(pi/2 - Settings.SampleTilt+Settings.CameraElevation);
        else
            xstar = Settings.ScanParams.xstar;
            ystar = Settings.ScanParams.ystar;
            zstar = Settings.ScanParams.zstar;
        end
    end

%     xstar = .5;
%     ystar = .5;
%     zstar = .7;
    
    xs = zeros(iterCalcF+1,1);
    ys = xs;
    zs = xs;
    
    xs(1) = xstar;
    ys(1) = ystar;
    zs(1) = zstar;

    Material = ReadMaterial(Settings.Phase{Ind});

    if size(Settings.ImageNamesList,1)>1
        ImagePath = Settings.ImageNamesList{Ind};
        ScanImage = ReadEBSDImage(ImagePath,Settings.ImageFilter);
    else
        ScanImage = ReadH5Pattern(Settings.ScanFilePath,Settings.ImageNamesList,Settings.imsize,Settings.ImageFilter,Ind);
    end


%     gr = euler2gmat(Settings.Angles(Ind,1),Settings.Angles(Ind,2),Settings.Angles(Ind,3));

    useeuler = 0;

    for j=1:iterCalcF
        gr = euler2gmat(Settings.Angles(Ind,1),Settings.Angles(Ind,2),Settings.Angles(Ind,3));
        paramspat={xstar;ystar;zstar;pixsize;Av;sampletilt;elevang;Material.Fhkl;Material.dhkl;Material.hkl};

        if isfield(Settings,'camphi1')
            useeuler = 1;
            paramspat{11} = Settings.camphi1;
            paramspat{12} = Settings.camPHI;
            paramspat{13} = Settings.camphi2;
        end

        RefImage = genEBSDPatternHybrid(gr,paramspat,eye(3),Material.lattice,Material.a1,Material.b1,Material.c1,Material.axs);
        RefImage = custimfilt(RefImage,Settings.ImageFilter(1), ...
            Settings.PixelSize,Settings.ImageFilter(3),Settings.ImageFilter(4));

        %Initialize
        clear global rs cs Gs
%         Settings.DoShowPlot = false;
        [F1,SSE1,XX] = CalcF(RefImage,ScanImage,gr,eye(3),Ind,Settings,Settings.Phase{Ind},0);

        %%%%New stuff to remove rotation error from strain measurement DTF  7/14/14
        for iq=1:4
            [rr,uu]=poldec(F1); % extract the rotation part of the deformation, rr
            gr=rr'*gr; % correct the rotation component of the deformation so that it doesn't affect strain calc
            RefImage = genEBSDPatternHybrid(gr,paramspat,eye(3),Material.lattice,Material.a1,Material.b1,Material.c1,Material.axs);
            RefImage = custimfilt(RefImage,Settings.ImageFilter(1), ...
                Settings.PixelSize,Settings.ImageFilter(3),Settings.ImageFilter(4));

            clear global rs cs Gs
            [F1,SSE1,XX,sigma] = CalcF(RefImage,ScanImage,gr,eye(3),Ind,Settings,Settings.Phase{Ind},0);
        end
        %%%%%

        %Improved convergence routine should replace this loop:
%         Settings.DoShowPlot = true;
        for ii = 1:Settings.IterationLimit
%             if SSE1 > 25 % need to make this a variable in the AdvancedSettings GUI
%                 if ii == 1
%                     display(['Didn''t make it in to the iteration loop for:' Settings.ImageNamesList{Ind}])
%                 end
%                 g = euler2gmat(Settings.Angles(Ind,1),Settings.Angles(Ind,2),Settings.Angles(Ind,3)); 
%                 F = -eye(3); SSE = 101; U = -eye(3);
%                 return;
%             end
            [r1,u1]=poldec(F1);
            U1=u1;
            R1=r1;
            FTemp=R1*U1; %**** isn't this just F1 - why did we bother doing this????


            NewRefImage = genEBSDPatternHybrid(gr,paramspat,FTemp,Material.lattice,Material.a1,Material.b1,Material.c1,Material.axs);% correct method ******DTF changed to test new profiles             pattern *****

            NewRefImage = custimfilt(NewRefImage, Settings.ImageFilter(1), Settings.PixelSize, ...
                Settings.ImageFilter(3), Settings.ImageFilter(4));
            %         keyboard
            clear global rs cs Gs
            [F1,SSE1,XX,sigma] = CalcF(NewRefImage,ScanImage,gr,FTemp,Ind,Settings,Settings.Phase{Ind},0);

        end
        [r u]=poldec(F1);
        

        if ~useeuler
            alpha = pi/2 - sampletilt + elevang;
            % Phospher to sample
            Qps=[0 -cos(alpha) -sin(alpha);...
                -1     0            0;...
                0   sin(alpha) -cos(alpha)];
        else
            Qmp = euler2gmat(camphi1,camPHI,camphi2);
            Qmi = [0 -1 0;1 0 0;0 0 1];
            Qio = [cos(sampletilt) 0 -sin(sampletilt);0 1 0;sin(sampletilt) 0 cos(sampletilt)];
            Qpo = Qio*Qmi*Qmp'*[-1 0 0;0 1 0;0 0 -1];
        end

        beta = ((Qps'*gr'*F1*gr*Qps) - eye(3));
        
%         xstar = xstar - beta(1,3)*zstar;
%         ystar = ystar - beta(2,3)*zstar;
%         zstar = zstar - 2*beta(3,3)*zstar/3;
        zstarnew = zstar*(1 - beta(3,3)/2)/(1 + beta(3,3));
        xstarnew = xstar + beta(1,3)*(zstarnew + 2*zstar)/3;
        ystarnew = ystar - beta(2,3)*(zstarnew + 2*zstar)/3;
        
        xstar = xstarnew;
        ystar = ystarnew;
        zstar = zstarnew;
%         fprintf(2,'Pattern %d did not converge!\n',i)
        
        xs(j+1) = xstar;
        ys(j+1) = ystar;
        zs(j+1) = zstar;
        
        
%         gr = r'*gr;
    end
    
    
%     xactual = .5-Settings.XData(Ind)/Settings.PhosphorSize;
%     yactual = .5+Settings.YData(Ind)/Settings.PhosphorSize*sin(pi/2 - Settings.SampleTilt + Settings.CameraElevation);
%     zactual = .7+Settings.YData(Ind)/Settings.PhosphorSize*cos(pi/2 - Settings.SampleTilt+Settings.CameraElevation);
%     figure; plot(xs)
%     hold on; plot(xactual*ones(size(xs)),'r')
%     figure; plot(ys)
%     hold on; plot(yactual*ones(size(xs)),'r')
%     figure; plot(zs)
%     hold on; plot(zactual*ones(size(xs)),'r')
    
    drawnow
    
%     Ind
%     [Settings.XData(Ind) Settings.YData(Ind)]
%     [xactual yactual zactual]
    if SSE1 < 1
        PCref = [xstar ystar zstar]
        disp(['Point: ' num2str(i)])
    else
        PCref = [nan nan nan]
        fprintf(2,'Point %d did not converge!\n',i)
    end
    CalibrationPointsPC(i,:) = PCref';

    ppm.increment();
end
keyboard
ppm.delete();

keyboard

%Filter outliers
meanPC = mean(CalibrationPointsPC);
stdDevPC = std(CalibrationPointsPC);
badPCPoints = any(CalibrationPointsPC > meanPC + stdDevPC |...
    CalibrationPointsPC < meanPC - stdDevPC,2);
npoints = npoints - sum(badPCPoints);
CalibrationPointsPC = CalibrationPointsPC(~badPCPoints,:);
Inds = Inds(~badPCPoints);

%Calculate Mean Pattern Center
if strcmp(PlaneFit,'Naive')
    PCData.MeanXStar = mean(CalibrationPointsPC(:,1)+(Settings.XData(Inds))/Settings.PhosphorSize);
    PCData.MeanYStar = mean(CalibrationPointsPC(:,2)-(Settings.YData(Inds))/Settings.PhosphorSize*sin(Settings.SampleTilt-Settings.CameraElevation));
    PCData.MeanZStar = mean(CalibrationPointsPC(:,3)-(Settings.YData(Inds))/Settings.PhosphorSize*cos(Settings.SampleTilt-Settings.CameraElevation));
else
    PCData.MeanXStar = mean(CalibrationPointsPC(:,1));
    PCData.MeanYStar = mean(CalibrationPointsPC(:,2));
    PCData.MeanZStar = mean(CalibrationPointsPC(:,3));
end
PCData.CalibrationPointsPC = CalibrationPointsPC;
PCData.CalibrationIndices = Inds;

A=zeros(3*npoints,9);
PC=zeros(3*npoints,1);

for i=1:npoints
    x=Settings.XData(Inds(i));
    y=Settings.YData(Inds(i));
    for k=1:3
        A(k+(i-1)*3,(1+3*(k-1)))=x;
        A(k+(i-1)*3,(2+3*(k-1)))=y;
        A(k+(i-1)*3,(3+3*(k-1)))=1;
        PC((i-1)*3+k)=CalibrationPointsPC(i,k);
    end
end

coeffs=pinv(A)*PC;

PCData.XStar = coeffs(1)*Settings.XData+coeffs(2)*Settings.YData+coeffs(3);
PCData.YStar = coeffs(4)*Settings.XData+coeffs(5)*Settings.YData+coeffs(6);
PCData.ZStar = coeffs(7)*Settings.XData+coeffs(8)*Settings.YData+coeffs(9);



% CalibrationPointsPC
% Inds
