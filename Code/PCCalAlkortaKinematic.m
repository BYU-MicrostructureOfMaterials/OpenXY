function PCData = PCCalAlkortaKinematic(Settings,PlaneFit,Inds)

%% Boring initiation stuff

%Perform Strain Minimization PC Calibration
npoints = length(Inds);
CalibrationPointsPC = zeros(npoints,3);

Av = Settings.AccelVoltage*1000; %put it in eV from KeV

sampletilt = Settings.SampleTilt;

elevang = Settings.CameraElevation;

pixsize = Settings.PixelSize;

iterCalcF = 6;

doShowPlot = false;


%I commented out the parallel code because it's a pain to get plots when
%you run in parallel.

% NumCores = min(Settings.DoParallel, npoints);
% try
%     ppool = gcp('nocreate');
%     if isempty(ppool)
%         parpool(NumCores);
%     end
% catch
%     ppool = matlabpool('size');
%     if ~ppool
%         matlabpool('local',NumCores); 
%     end
% end
% M = NumCores;
% pctRunOnAll javaaddpath('java')
% ppm = ParforProgMon( 'Point Calibration ', npoints,1,400,50 );

ScanImage = Settings.patterns.getPattern(1);

[roixc,roiyc]= GetROIs(ScanImage,Settings.NumROIs,pixsize,Settings.ROISize,...
    Settings.ROIStyle);
Settings.roixc = roixc;
Settings.roiyc = roiyc;

ScanParams = Settings.ScanParams;

% Material = ReadMaterial(Settings.Phase{1});
% paramspat={.5;.5;.7;pixsize;Av;sampletilt;elevang;Material.Fhkl;Material.dhkl;Material.hkl};


if Settings.DoParallel == 1
    %% Single Processor Calculation
    javaaddpath('java')
%     ppm =... % error in parformon.. hence comment out line 57, 58, 216, 241 and 245 in PCCalAlkortaKinematic.m
%         ParforProgMon('Point Calibration ',npoints*(1+iterCalcF),1,450,50);
    for i=1:npoints
        
        Ind = Inds(i);
        
        if isfield(Settings,'XStar')
            xstar = Settings.XStar(Ind);
            ystar = Settings.YStar(Ind);
            zstar = Settings.ZStar(Ind);
        else
            if strcmp(Settings.PlaneFit,'Naive')
                xstar = ScanParams.xstar-Settings.XData(Ind)/Settings.PhosphorSize;
                ystar = ScanParams.ystar+Settings.YData(Ind)/Settings.PhosphorSize*cos(pi/2 - Settings.SampleTilt + Settings.CameraElevation);
                zstar = ScanParams.zstar+Settings.YData(Ind)/Settings.PhosphorSize*sin(pi/2 - Settings.SampleTilt + Settings.CameraElevation);
            else
                xstar = ScanParams.xstar;
                ystar = ScanParams.ystar;
                zstar = ScanParams.zstar;
            end
        end
        
        %     xstar = .5;
        %     ystar = .5;
        %     zstar = .7;
        %     xstar = ScanParams.xstar-Settings.XData(Ind)/Settings.PhosphorSize;
        %     ystar = ScanParams.ystar+Settings.YData(Ind)/Settings.PhosphorSize*cos(pi/2 - Settings.SampleTilt + Settings.CameraElevation);
        %     zstar = ScanParams.zstar+Settings.YData(Ind)/Settings.PhosphorSize*sin(pi/2 - Settings.SampleTilt + Settings.CameraElevation);
        
        xs = zeros(iterCalcF+1,1);
        ys = xs;
        zs = xs;
        bbb = zeros(3,3,iterCalcF);
        bn = zeros(iterCalcF,1);
        
        xs(1) = xstar;
        ys(1) = ystar;
        zs(1) = zstar;
        
        Material = ReadMaterial(Settings.Phase{Ind});
        
        ScanImage = Settings.patterns.getPattern(Ind);
        
        gr = euler2gmat(Settings.Angles(Ind,1),Settings.Angles(Ind,2),Settings.Angles(Ind,3));
        
        xactual = .5-Settings.XData(Ind)/Settings.PhosphorSize;
        yactual = .5+Settings.YData(Ind)/Settings.PhosphorSize*cos(pi/2 - Settings.SampleTilt + Settings.CameraElevation);
        zactual = .7+Settings.YData(Ind)/Settings.PhosphorSize*sin(pi/2 - Settings.SampleTilt + Settings.CameraElevation);
        
        for j=1:iterCalcF
            %         gr = euler2gmat(Settings.Angles(Ind,1),Settings.Angles(Ind,2),Settings.Angles(Ind,3));
            paramspat={xstar;ystar;zstar;pixsize;Av;sampletilt;elevang;Material.Fhkl;Material.dhkl;Material.hkl};
            %         paramspat{1} = xstar;
            %         paramspat{2} = ystar;
            %         paramspat{3} = zstar;
            %         paramspat{8} = Material.Fhkl;
            %         paramspat{9} = Material.dhkl;
            %         paramspat{10} = Material.hkl;
            
            useeuler = 0;
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
            F1 = CalcF(RefImage,ScanImage,gr,eye(3),Ind,Settings,Settings.Phase{Ind},0);
            
            %%%%New stuff to remove rotation error from strain measurement DTF  7/14/14
            for iq=1:4
                [rr,uu]=poldec(F1); % extract the rotation part of the deformation, rr
                gr=rr'*gr; % correct the rotation component of the deformation so that it doesn't affect strain calc
                RefImage = genEBSDPatternHybrid(gr,paramspat,eye(3),Material.lattice,Material.a1,Material.b1,Material.c1,Material.axs);
                RefImage = custimfilt(RefImage,Settings.ImageFilter(1), ...
                    Settings.PixelSize,Settings.ImageFilter(3),Settings.ImageFilter(4));
                
                clear global rs cs Gs
                F1 = CalcF(RefImage,ScanImage,gr,eye(3),Ind,Settings,Settings.Phase{Ind},0);
            end
            %%%%
            
            %%%%% Improved convergence routine should replace this loop:
            
            for ii = 1:Settings.IterationLimit
                [r1,u1]=poldec(F1);
                U1=u1;
                R1=r1;
                FTemp=R1*U1; %**** isn't this just F1 - why did we bother doing this????
                
                
                NewRefImage = genEBSDPatternHybrid(gr,paramspat,FTemp,Material.lattice,Material.a1,Material.b1,Material.c1,Material.axs);% correct method ******DTF changed to test new profiles             pattern *****
                
                NewRefImage = custimfilt(NewRefImage, Settings.ImageFilter(1), Settings.PixelSize, ...
                    Settings.ImageFilter(3), Settings.ImageFilter(4));
                %         keyboard
                clear global rs cs Gs
                F1 = CalcF(NewRefImage,ScanImage,gr,FTemp,Ind,Settings,Settings.Phase{Ind},0);
                
            end
            [r,u]=poldec(F1);
            
            misg = r - eye(3);
            
            
            if ~useeuler
                alpha = pi/2 - sampletilt + elevang;
                % Phospher to sample
                Qps=[0 -cos(alpha) -sin(alpha);...
                    -1     0            0;...
                    0   sin(alpha) -cos(alpha)];
            else
                Qmp = euler2gmat(Settings.camphi1,Settings.camPHI,Settings.camphi2);
                Qmi = [0 -1 0;1 0 0;0 0 1];
                Qio = [cos(sampletilt) 0 -sin(sampletilt);0 1 0;sin(sampletilt) 0 cos(sampletilt)];
                Qpo = Qio*Qmi*Qmp'*[-1 0 0;0 1 0;0 0 -1];
                Qps = Qpo;
            end
            
            beta = ((Qps'*gr'*F1*gr*Qps) - eye(3));
            
            d1 = xstar - xactual;
            d2 = -(ystar - yactual);
            d3 = -(zstar - zactual);
            betatheoretical = [d3/3 0 -d1;0 d3/3 -d2;0 0 -2*d3/3]./(zstar + 2*d3/3);
            
            
            %% This block of code for Alkorta
            
            %         xstar = xstar + beta(1,3)*zstar;
            %         ystar = ystar - beta(2,3)*zstar;
            %         zstar = zstar - 3*beta(3,3)*zstar/2;
            
            %% This block of code for mine
            
            zstarnew = zstar*(1 - beta(3,3)/2)/(1 + beta(3,3));
            xstarnew = xstar + beta(1,3)*(2*zstarnew + zstar)/3;
            ystarnew = ystar - beta(2,3)*(2*zstarnew + zstar)/3;
            
            xstar = xstarnew;
            ystar = ystarnew;
            zstar = zstarnew;
            
            %% End
            
            xs(j+1) = xstar;
            ys(j+1) = ystar;
            zs(j+1) = zstar;
            
            bbb(:,:,j) = beta;
            bn(j) = norm(beta);
            
            %         gr = r'*gr;
%             ppm.increment();
        end
        
        
        if doShowPlot
            figure(3*i-2); plot(xs)
            hold on; plot(xactual*ones(size(xs)),'r')
            figure(3*i-1); plot(ys)
            hold on; plot(yactual*ones(size(xs)),'r')
            figure(3*i); plot(zs)
            hold on; plot(zactual*ones(size(xs)),'r')
            figure(4)
            plot(bn)
            
            
            drawnow
        end
        Ind
        [Settings.XData(Ind) Settings.YData(Ind)]
        [xactual yactual zactual]
        
        PCref = [xstar ystar zstar]
        disp(['Point: ' num2str(i)])
        CalibrationPointsPC(i,:) = PCref';
        
%         ppm.increment();
        
    end
%     pause(1);
%     ppm.delete();
%     pause(1);
    % Pausese are there to prevent bug in parforprogmon when using single
    % processor.
else
    %% Multi Processor Calculation
    NumCores = min(Settings.DoParallel, npoints);
    try
        ppool = gcp('nocreate');
        if isempty(ppool)
            parpool(NumCores);
        end
    catch
        ppool = matlabpool('size');%#ok<DPOOL>
        if ~ppool
            matlabpool('local',NumCores);%#ok<DPOOL>
        end
    end
    pctRunOnAll javaaddpath('java')
    ppm =...
        ParforProgMon('Point Calibration ',npoints*(1+iterCalcF),1,400,50);
    
    parfor(i=1:npoints,NumCores)
        
        Ind = Inds(i);
        
        if isfield(Settings,'XStar')
            xstar = Settings.XStar(Ind);
            ystar = Settings.YStar(Ind);
            zstar = Settings.ZStar(Ind);
        else
            if strcmp(Settings.PlaneFit,'Naive')
                xstar = ScanParams.xstar-Settings.XData(Ind)/Settings.PhosphorSize;
                ystar = ScanParams.ystar+Settings.YData(Ind)/Settings.PhosphorSize*cos(pi/2 - Settings.SampleTilt + Settings.CameraElevation);
                zstar = ScanParams.zstar+Settings.YData(Ind)/Settings.PhosphorSize*sin(pi/2 - Settings.SampleTilt + Settings.CameraElevation);
            else
                xstar = ScanParams.xstar;
                ystar = ScanParams.ystar;
                zstar = ScanParams.zstar;
            end
        end
        
        %     xstar = .5;
        %     ystar = .5;
        %     zstar = .7;
        %     xstar = ScanParams.xstar-Settings.XData(Ind)/Settings.PhosphorSize;
        %     ystar = ScanParams.ystar+Settings.YData(Ind)/Settings.PhosphorSize*cos(pi/2 - Settings.SampleTilt + Settings.CameraElevation);
        %     zstar = ScanParams.zstar+Settings.YData(Ind)/Settings.PhosphorSize*sin(pi/2 - Settings.SampleTilt + Settings.CameraElevation);
        
        xs = zeros(iterCalcF+1,1);
        ys = xs;
        zs = xs;
        bbb = zeros(3,3,iterCalcF);
        bn = zeros(iterCalcF,1);
        
        xs(1) = xstar;
        ys(1) = ystar;
        zs(1) = zstar;
        
        Material = ReadMaterial(Settings.Phase{Ind});
        
        ScanImage = Settings.patterns.getPattern(Ind);
        
        gr = euler2gmat(Settings.Angles(Ind,1),Settings.Angles(Ind,2),Settings.Angles(Ind,3));
        
        xactual = .5-Settings.XData(Ind)/Settings.PhosphorSize;
        yactual = .5+Settings.YData(Ind)/Settings.PhosphorSize*cos(pi/2 - Settings.SampleTilt + Settings.CameraElevation);
        zactual = .7+Settings.YData(Ind)/Settings.PhosphorSize*sin(pi/2 - Settings.SampleTilt + Settings.CameraElevation);
        
        for j=1:iterCalcF
            %         gr = euler2gmat(Settings.Angles(Ind,1),Settings.Angles(Ind,2),Settings.Angles(Ind,3));
            paramspat={xstar;ystar;zstar;pixsize;Av;sampletilt;elevang;Material.Fhkl;Material.dhkl;Material.hkl};
            %         paramspat{1} = xstar;
            %         paramspat{2} = ystar;
            %         paramspat{3} = zstar;
            %         paramspat{8} = Material.Fhkl;
            %         paramspat{9} = Material.dhkl;
            %         paramspat{10} = Material.hkl;
            
            useeuler = 0;
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
            clearGlobal
            F1 = CalcF(RefImage,ScanImage,gr,eye(3),Ind,Settings,Settings.Phase{Ind},0);
            
            %%%%New stuff to remove rotation error from strain measurement DTF  7/14/14
            for iq=1:4
                [rr,uu]=poldec(F1); % extract the rotation part of the deformation, rr
                gr=rr'*gr; % correct the rotation component of the deformation so that it doesn't affect strain calc
                RefImage = genEBSDPatternHybrid(gr,paramspat,eye(3),Material.lattice,Material.a1,Material.b1,Material.c1,Material.axs);
                RefImage = custimfilt(RefImage,Settings.ImageFilter(1), ...
                    Settings.PixelSize,Settings.ImageFilter(3),Settings.ImageFilter(4));
                
                clearGlobal
                F1 = CalcF(RefImage,ScanImage,gr,eye(3),Ind,Settings,Settings.Phase{Ind},0);
            end
            %%%%
            
            %%%%% Improved convergence routine should replace this loop:
            
            for ii = 1:Settings.IterationLimit
                [r1,u1]=poldec(F1);
                U1=u1;
                R1=r1;
                FTemp=R1*U1; %**** isn't this just F1 - why did we bother doing this????
                
                
                NewRefImage = genEBSDPatternHybrid(gr,paramspat,FTemp,Material.lattice,Material.a1,Material.b1,Material.c1,Material.axs);% correct method ******DTF changed to test new profiles             pattern *****
                
                NewRefImage = custimfilt(NewRefImage, Settings.ImageFilter(1), Settings.PixelSize, ...
                    Settings.ImageFilter(3), Settings.ImageFilter(4));
                %         keyboard
                clearGlobal
                F1 = CalcF(NewRefImage,ScanImage,gr,FTemp,Ind,Settings,Settings.Phase{Ind},0);
                
            end
            [r,u]=poldec(F1);
            
            misg = r - eye(3);
            
            
            if ~useeuler
                alpha = pi/2 - sampletilt + elevang;
                % Phospher to sample
                Qps=[0 -cos(alpha) -sin(alpha);...
                    -1     0            0;...
                    0   sin(alpha) -cos(alpha)];
            else
                Qmp = euler2gmat(Settings.camphi1,Settings.camPHI,Settings.camphi2);
                Qmi = [0 -1 0;1 0 0;0 0 1];
                Qio = [cos(sampletilt) 0 -sin(sampletilt);0 1 0;sin(sampletilt) 0 cos(sampletilt)];
                Qpo = Qio*Qmi*Qmp'*[-1 0 0;0 1 0;0 0 -1];
                Qps = Qpo;
            end
            
            beta = ((Qps'*gr'*F1*gr*Qps) - eye(3));
            
            d1 = xstar - xactual;
            d2 = -(ystar - yactual);
            d3 = -(zstar - zactual);
            betatheoretical = [d3/3 0 -d1;0 d3/3 -d2;0 0 -2*d3/3]./(zstar + 2*d3/3);
            
            
            %% This block of code for Alkorta
            
            %         xstar = xstar + beta(1,3)*zstar;
            %         ystar = ystar - beta(2,3)*zstar;
            %         zstar = zstar - 3*beta(3,3)*zstar/2;
            
            %% This block of code for mine
            
            zstarnew = zstar*(1 - beta(3,3)/2)/(1 + beta(3,3));
            xstarnew = xstar + beta(1,3)*(2*zstarnew + zstar)/3;
            ystarnew = ystar - beta(2,3)*(2*zstarnew + zstar)/3;
            
            xstar = xstarnew;
            ystar = ystarnew;
            zstar = zstarnew;
            
            %% End
            
            xs(j+1) = xstar;
            ys(j+1) = ystar;
            zs(j+1) = zstar;
            
            bbb(:,:,j) = beta;
            bn(j) = norm(beta);
            
            %         gr = r'*gr;
            ppm.increment();
        end
        
        
        Ind
        [Settings.XData(Ind) Settings.YData(Ind)]
        [xactual yactual zactual]
        
        PCref = [xstar ystar zstar]
        disp(['Point: ' num2str(i)])
        CalibrationPointsPC(i,:) = PCref';
        
        ppm.increment();
        
    end
    pause(1)
    ppm.delete();
    pause(1)
end

%Filter outliers from the data
xOutliers = isoutlier(CalibrationPointsPC(:,1));
yOutliers = isoutlier(CalibrationPointsPC(:,2));
zOutliers = isoutlier(CalibrationPointsPC(:,3));
outliers = xOutliers|yOutliers|zOutliers;

CalibrationPointsPC(outliers,:) = [];
Inds(outliers) = [];
npoints = npoints - sum(outliers);

%Calculate Mean Pattern Center
if strcmp(PlaneFit,'Naive')
    PCData.MeanXStar = mean(CalibrationPointsPC(:,1)+(Settings.XData(Inds))/Settings.PhosphorSize);
    PCData.MeanYStar = mean(CalibrationPointsPC(:,2)-(Settings.YData(Inds))/Settings.PhosphorSize*cos(pi/2 - Settings.SampleTilt + Settings.CameraElevation));
    PCData.MeanZStar = mean(CalibrationPointsPC(:,3)-(Settings.YData(Inds))/Settings.PhosphorSize*sin(pi/2 - Settings.SampleTilt + Settings.CameraElevation));
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



C = [coeffs(1) coeffs(2);coeffs(4) coeffs(5);coeffs(7) coeffs(8)];
S = C*Settings.mperpix*Settings.PixelSize;
xmapphos = S*[1;0];PCData.xmapphos = xmapphos;
ymapphos = S*[0;1];PCData.ymapphos = ymapphos;
PCData.normalvecphos = cross(xmapphos/norm(xmapphos),ymapphos/norm(ymapphos));
% CalibrationPointsPC
% Inds
function clearGlobal
clear global rs cs Gs
