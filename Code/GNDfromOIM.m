function alpha_data = GNDfromOIM(datain,smooth,skip)
%GNDfromOIM
%alpha_data = GNDfromOIM(datain)
%
%Calculates the nye tensor and total GND for each point in the scan using
%orientations. Options to skip a specific number of points and average the
%orientation using the surrounding points.
%
%By default the Nye tensor is calculated using the misorientation between b
%and c, and b and c.
%
%With smoothing, all of the surround points are used and averaged.
%
%                Square                                     Hexagonal
%
%                m21 m22                                     m21 m22
%                 |   |                                       |   |
%              aC - a - ac                                 aC - a - ac  
%          m11->|   |    |<-m13                        m11-> \   \    \<-m13 
%               C - b - c                                     C - b - c
%          m14->|   |    |<-m16                           m14->\   \    \<-m16
%              AC - A - Ac                                      AC - A - AC
%                 |   |                                            |   |
%                m25 m26                                          m25 m26
%
%Currently fudges it for hexagonal scan - so only accurate for square scan
%
%INPUTS
%Option 1: No input. Will be prompted to select either an OpenXY AnalysisParams file or a .ang file
%Option 2: Settings structure. Will use corrected orientations.
%Option 3: ScanFilePath. Reads in orientations from .ang file. Prompted to
%   enter necessary material information
%
%Partly from Ruggles RDScan.m
%DTF May 3 2016
%Edited by BEJ September 2016

withquat = true; %Use quaternion method
maxmisofilter = true; %Filter using misorientation

%Handle inputs
if nargin < 2
    smooth = 1;
    skip = 0;
end
if nargin > 1
    ismat = isstruct(datain);
    if ismat
        Settings = datain;
        clear datain;
    end
else
    ismat=input('.mat file (1) or .ang file (0)? ');
    if ismat
        [picname, picpath] = uigetfile('*.mat','AnalysisParams(.mat) file');
        temp = load([picpath picname]);
        Settings = temp.Settings;
        clear temp
    end
end

%Read in Scan File
if ~ismat
    [FileName, FilePath] = uigetfile('*.ang','OIM .ang file');
    Settings = GetHROIMDefaultSettings;
    Settings = ImportScanInfo(Settings,FileName,FilePath);
end


% Read Data from Settings
if isfield(Settings,'data')
    Angles = Settings.NewAngles;
else
    Angles = Settings.Angles;
end
if ~isfield(Settings,'Inds')
    Settings.Inds = (1:Settings.ScanLength)';
end
n = Settings.Nx;
m = Settings.Ny;
IQ = Settings.IQ(Settings.Inds);
XData = Settings.XData(Settings.Inds);
YData = Settings.YData(Settings.Inds);
M = ReadMaterial(Settings.Phase{1});
lattype=M.lattice;
bavg=M.Burgers;
maxmiso=Settings.MisoTol;
ScanLength=Settings.ScanLength;
stepsize = (XData(3)-XData(2))*1e-6;    %***** can ystep be different?????

if strcmp(Settings.ScanType,'Hexagonal')
    NColsOdd=n;
    NColsEven=NColsOdd-1;
    NCols = 2*n-1;
    n = NColsEven;
    nphi1 = Hex2Array(Angles(:,1),NColsOdd,NColsEven);
    nPHI = Hex2Array(Angles(:,2),NColsOdd,NColsEven);
    nphi2 = Hex2Array(Angles(:,3),NColsOdd,NColsEven);
    xsq = Hex2Array(XData,NColsOdd,NColsEven);
    ysq = Hex2Array(YData,NColsOdd,NColsEven);
    iqRS = Hex2Array(IQ,NColsOdd,NColsEven);
    [m,n]=size(iqRS);
else
    xsq = reshape(XData,n,m)';
    ysq = reshape(YData,n,m)';
    nphi1 = reshape(Angles(:,1),n,m)';
    nPHI = reshape(Angles(:,2),n,m)';
    nphi2 = reshape(Angles(:,3),n,m)';
    iqRS = reshape(IQ,n,m)';
end

%Get Indices of points above to the right
[RefIndA,RefIndC] = GetAdjacentInds([n,m],1:ScanLength,skip,Settings.ScanType);
if strcmp(Settings.ScanType,'Hexagonal')
    RefIndA = RefIndA(:,1);
    RefIndC = RefIndC(:,1);
end

if withquat
    
    %Convert angles to quaternions
    q = euler2quat(Angles);
    
    %Get Quaternion symmetry operators
    if strcmp(lattype,'hexagonal')
        q_symops = rmat2quat(permute(gensymopsHex,[3 2 1]));
    else
        q_symops = rmat2quat(permute(gensymops,[3 2 1]));
    end
    
    %Calculate Misorientations
    [anglea,~,~,deltaa] = quatMisoSym(q,q(RefIndA,:),q_symops,'element');
    [anglec,~,~,deltac] = quatMisoSym(q,q(RefIndC,:),q_symops,'element');
    misoa = quatconj(quatmult(quatconj(q),quatmult(deltaa,q,'element'),'element'));
    misoc = quatconj(quatmult(quatconj(q),quatmult(deltac,q,'element'),'element'));
    
    %Filter out misorientations greater than the tolerance
    misanga = true(ScanLength,1);
    misangc = misanga;
    if maxmisofilter
        misanga(real(anglea)>maxmiso*pi/180) = false;
        misangc(real(anglec)>maxmiso*pi/180) = false;
    end
    
    
    
    if smooth
        switch Settings.ScanType
            case 'Square'
                
                %Set up ID vectors for scan edges
                Ind = (1:ScanLength)';
                toprow = Ind<=n*(skip+1);
                botrow = Ind>ScanLength-n*(skip+1);
                rightside = mod(Ind,n)==0 | (n-mod(Ind,n))<=skip;
                leftside = mod(Ind,n)<=skip+1 & mod(Ind,n)>0;
                corners = Ind == 1 | Ind == n | Ind == ScanLength-n+1 | Ind == ScanLength;
                
                %X-Direction
                m11 = zeros(ScanLength,4);
                m12 = m11; m13 = m11; m14 = m11; m15 = m11; m16 = m11;
                m11(~toprow & ~leftside,:) = misoa(Ind(~toprow & ~leftside)-(1+skip),:);
                m12(~toprow,:) = misoa(Ind(~toprow),:);
                m13(~toprow & ~rightside,:) = misoa(Ind(~toprow & ~rightside)+(1+skip),:);
                m14(~botrow & ~leftside,:) = misoa(Ind(~botrow & ~leftside)-(1+skip)+n*(1+skip),:);
                m15(~botrow,:) = misoa(Ind(~botrow)+n*(1+skip),:);
                m16(~botrow & ~rightside,:) = misoa(Ind(~botrow & ~rightside)+(1+skip)+n*(1+skip),:);
                %Matrix with number of points to average
                numpts = ones(Settings.ScanLength,1)*6;
                numpts((toprow | botrow) & ~corners) = 3;
                numpts((leftside | rightside) & ~corners) = 4;
                numpts(corners) = 2;
                %Calculate average misorietation
                avgmisoa = (m11+m12+m13+m14+m15+m16)./repmat(numpts,1,4).*repmat(misanga,1,4);
                avgmisoa = quatnorm(avgmisoa);
                
                %Y-Direction
                m21 = zeros(ScanLength,4);
                m22 = m21; m23 = m21; m24 = m21; m25 = m21; m26 = m21;
                m21(~toprow & ~leftside,:) = misoc(Ind(~toprow & ~leftside)-n*(1+skip)-(1+skip),:);
                m22(~toprow & ~rightside,:) = misoc(Ind(~toprow & ~rightside)-n*(1+skip),:);
                m23(~leftside,:) = misoc(Ind(~leftside)-(1+skip),:);
                m24(~rightside,:) = misoc(Ind(~rightside),:);
                m25(~botrow & ~leftside,:) = misoc(Ind(~botrow & ~leftside)+n*(1+skip)-(1+skip),:);
                m26(~botrow & ~rightside,:) = misoc(Ind(~botrow & ~rightside)+n*(1+skip),:);
                %Matrix with number of points to average
                numpts = ones(Settings.ScanLength,1)*6;
                numpts((toprow | botrow) & ~corners) = 4;
                numpts((leftside | rightside) & ~corners) = 3;
                numpts(corners) = 2;
                %Calculate average misorietation
                avgmisoc = (m21+m22+m23+m24+m25+m26)./repmat(numpts,1,4).*repmat(misangc,1,4);
                avgmisoc = quatnorm(avgmisoc);
                
            case 'Hexagonal'
                if skip > 1
                    skip = 1;
                    w = warndlg('Skips greater than 1 not yet implemented for Hexagonal Scans');
                    uiwait(w,3)
                end
                
                %Set up ID vectors for scan edges
                Ind = (1:ScanLength)';
                IndM = mod(Ind,NColsOdd+NColsEven);
                IndsM = Hex2Array(IndM,NColsOdd,true);
                Inds = Hex2Array(Ind,NColsOdd,true);
                if mod(m,2)
                    botcol = NColsOdd;
                else
                    botcol = NColsEven;
                end
                toprow = Ind<=NColsOdd*(skip+1)-floor((skip+1)/2);
                botrow = ScanLength+1-Ind<=NColsOdd*(skip+1)-floor((skip+1)/2);
                oddleft = IndM<=1+skip & IndM>0;
                oddright = IndM<=NColsOdd & IndM>=NColsOdd-skip;
                oddleft2 = IndM<=2+skip & IndM>0;
                oddright2 = IndM<=NColsOdd & IndM>=NColsOdd-skip-1;
                evenleft = IndM>NColsOdd & IndM<=NColsOdd+skip+1;
                evenright = IndM==0 | IndM>=(NCols-skip);
                
                %X-Direction
                m11 = zeros(ScanLength,4);
                m12 = m11; m13 = m11; m14 = m11; m15 = m11; m16 = m11;
                m11(~toprow & ~oddleft2 & ~evenleft,:) = misoa(Ind(~toprow & ~oddleft2 & ~evenleft)-(1+skip),:);
                m12(~toprow & ~oddleft,:) = misoa(Ind(~toprow & ~oddleft),:);
                m13(~toprow & ~oddright & ~evenright,:) = misoa(Ind(~toprow & ~oddright & ~evenright)+(1+skip),:);
                m14(~botrow & ~oddleft & ~evenleft,:) = misoa(Ind(~botrow & ~oddleft & ~evenleft)+NColsOdd*(1+skip)-(1+skip),:);
                m15(~botrow & ~oddright,:) = misoa(Ind(~botrow & ~oddright)+NColsOdd*(1+skip),:);
                m16(~botrow & ~oddright2 & ~evenright,:) = misoa(Ind(~botrow & ~oddright2 & ~evenright)+NColsOdd*(1+skip)+(1+skip),:);
                numpts = (sum(m11,2)>0)+(sum(m12,2)>0)+(sum(m13,2)>0)+...
                    (sum(m14,2)>0)+(sum(m15,2)>0)+(sum(m16,2)>0);
                I = true(ScanLength,1);
                I = ~botrow & ~oddleft & ~evenleft;
                %Calculate average misorietation
                avgmisoa = (m11+m12+m13+m14+m15+m16)./repmat(numpts,1,4).*repmat(misanga,1,4);
                avgmisoa = quatnorm(avgmisoa);
                
                %Y-Direction
                m21 = zeros(ScanLength,4);
                m22 = m21; m23 = m21; m24 = m21; m25 = m21; m26 = m21;
                m21(~toprow & ~oddleft2 & ~evenleft,:) = misoc(Ind(~toprow & ~oddleft2 & ~evenleft)-NColsOdd-(1+skip),:);
                m22(~toprow & ~oddleft & ~oddright,:) = misoc(Ind(~toprow & ~oddleft & ~oddright)-NColsOdd,:);
                m23(~oddleft & ~evenleft,:) = misoc(Ind(~oddleft & ~evenleft)-(1+skip),:);
                m24(~oddright & ~evenright,:) = misoc(Ind(~oddright & ~evenright),:);
                m25(~botrow & ~oddleft & ~oddright,:) = misoc(Ind(~botrow & ~oddleft & ~oddright)+NColsOdd-(1+skip),:);
                m26(~botrow & ~oddright2 & ~evenright,:) = misoc(Ind(~botrow & ~oddright2 & ~evenright)+NColsOdd,:);
                numpts = (sum(m21,2)>0)+(sum(m22,2)>0)+(sum(m23,2)>0)+...
                    (sum(m24,2)>0)+(sum(m25,2)>0)+(sum(m26,2)>0);
                %Calculate average misorietation
                avgmisoc = (m21+m22+m23+m24+m25+m26)./repmat(numpts,1,4).*repmat(misangc,1,4);
                avgmisoc = quatnorm(avgmisoc);
                
        end
    else
        avgmisoa = misoa;
        avgmisoc = misoc;
    end
    
    %Calculate Beta derivatives
    avgmisoc_R = quat2rmat(avgmisoc);
    bd1 = (avgmisoc_R - repmat(eye(3),1,1,ScanLength)) / (stepsize*(skip+1));
    avgmisoa_R = quat2rmat(avgmisoa);
    bd2 = (avgmisoa_R - repmat(eye(3),1,1,ScanLength)) / (-stepsize*(skip+1));
    
    if strcmp(Settings.ScanType,'Square')
        bd1 = permute(reshape(permute(bd1,[3 1 2]),Settings.Nx,Settings.Ny,3,3),[4 3 2 1]);
        bd2 = permute(reshape(permute(bd2,[3 1 2]),Settings.Nx,Settings.Ny,3,3),[4 3 2 1]);
    else
        bd1 = permute(bd1,[3 1 2]);
        bd1 = cat(4,Hex2Array(bd1(:,:,1),NColsOdd),...
            Hex2Array(bd1(:,:,2),NColsOdd),...
            Hex2Array(bd1(:,:,3),NColsOdd));
        bd1 = permute(bd1,[4 3 1 2]);
        bd2 = permute(bd2,[3 1 2]);
        bd2 = cat(4,Hex2Array(bd2(:,:,1),NColsOdd),...
            Hex2Array(bd2(:,:,2),NColsOdd),...
            Hex2Array(bd2(:,:,3),NColsOdd));
        bd2 = permute(bd2,[4 3 1 2]);
    end
    betaderiv2 = bd2;
    betaderiv1 = bd1;
    
else
    
    %     for i=1:m-skip-1    % work out all misorientations between points and right (cmiso) and down (amiso) neighbors
    %         for j=1:n-skip-1
    %             thisg = euler2gmat(nphi1(i,j),nPHI(i,j),nphi2(i,j));
    %             thisa = euler2gmat(nphi1(i+1+skip,j),nPHI(i+1+skip,j),nphi2(i+1+skip,j)); % -y goes with i
    %             [angle,Axis,deltaG(:,:,i,j)]=GeneralMisoCalcSym(thisg,thisa,lattype);
    %             aangle(i,j) = angle;
    %             amiso(:,:,i,j) = (thisg'*(deltaG(:,:,i,j))*thisg)'; % transpose since it should be active rather than passive rotation
    %             thisc = euler2gmat(nphi1(i,j+1+skip),nPHI(i,j+1+skip),nphi2(i,j+1+skip));
    %             [angle,Axis,deltaG(:,:,i,j)]=GeneralMisoCalcSym(thisg,thisc,lattype);
    %             cmiso(:,:,i,j) = (thisg'*(deltaG(:,:,i,j))*thisg)';
    %             cangle(i,j) = angle;
    %         end
    %     end
    
    %Convert Euler Angles to Orientation Matrices
    g = euler2gmat(Angles);
    
    amiso = zeros(3,3,ScanLength);
    cmiso = amiso;
    for i = 1:ScanLength
        thisg = g(:,:,i);
        thisa = g(:,:,RefIndA(i));
        
        [aangle(i),~,deltaG(:,:,i)]=GeneralMisoCalcSym(thisg,thisa,lattype);
        amiso(:,:,i) = (thisg'*(deltaG(:,:,i))*thisg)'; % transpose since it should be active rather than passive rotation
        
        thisc = g(:,:,RefIndC(i));
        [cangle(i),~,deltaG(:,:,i)]=GeneralMisoCalcSym(thisg,thisc,lattype);
        cmiso(:,:,i) = (thisg'*(deltaG(:,:,i))*thisg)';
    end
    amiso = permute(reshape(permute(amiso,[3 1 2]),Settings.Nx,Settings.Ny,3,3),[3 4 2 1]);
    cmiso = permute(reshape(permute(cmiso,[3 1 2]),Settings.Nx,Settings.Ny,3,3),[3 4 2 1]);
    
    aangle = vec2map(aangle',Settings.Nx,Settings.ScanType);
    cangle = vec2map(cangle',Settings.Nx,Settings.ScanType);
    
    if ~maxmisofilter
        maxmiso = 360;
    end
    betaderiv1 = zeros(3,3,m,n);
    betaderiv2 = betaderiv1;
    for i = 1:m-skip
        for j = 1:n-skip
            % check for suitable misorientations between neighboring points in the
            % 1-direction - 6 misorientations between the 9 neighbors
            numpts=0;
            if i<m-skip % from here on, pick out the gradients in this direction for the 9 neighboring points (6 gradients)
                % I need to check that the points are within
                % maxmiso of the central point - not just of each
                % other *****
                if j<n-skip %b-a
                    if aangle(i,j)<maxmiso
                        numpts=numpts+1;
                        misoave(numpts,:,:)=amiso(:,:,i,j);
                        pts(:,:,numpts) = [i+1,j];
                    end
                end
                if smooth
                    if j<n-skip-1 %c-ac
                        if aangle(i,j+1)<maxmiso
                            numpts=numpts+1;
                            misoave(numpts,:,:)=amiso(:,:,i,j+1);
                            pts(:,:,numpts) = [i+1,j];
                        end
                    end
                    if j>1 %C-aC
                        if aangle(i,j-1)<maxmiso
                            numpts=numpts+1;
                            misoave(numpts,:,:)=amiso(:,:,i,j-1);
                            pts(:,:,numpts) = [i+1,j];
                        end
                    end
                end
            end
            if smooth
                if i>1 %A-b
                    if j<n-skip
                        if aangle(i-1,j)<maxmiso
                            numpts=numpts+1;
                            misoave(numpts,:,:)=amiso(:,:,i-1,j);
                            pts(:,:,numpts) = [i+1,j];
                        end
                    end
                    if j<n-skip-1 %Ac-c
                        if aangle(i-1,j+1)<maxmiso
                            numpts=numpts+1;
                            misoave(numpts,:,:)=amiso(:,:,i-1,j+1);
                            pts(:,:,numpts) = [i+1,j];
                        end
                    end
                    if j>1 %AC-C
                        if aangle(i-1,j-1)<maxmiso
                            numpts=numpts+1;
                            misoave(numpts,:,:)=amiso(:,:,i-1,j-1);
                            pts(:,:,numpts) = [i+1,j];
                        end
                    end
                end
            end
            % average the derivatives over those points that have small
            % misorientations
            np2(i,j) = numpts;
            if numpts>0
                quat=[];
                for k=1:numpts
                    quat=[quat; rmat2quat(squeeze(misoave(k,:,:)))];% put misorientation matrix into quaternion space to average
                end
                avg = sum(quat,1)/numpts;
                avg = avg/norm(avg);
                R=quat2rmat(avg)'; % transpose because for some reason sending to quaternion space and pack transposes it
                R2(:,:,i,j) = R;
                
                betaderiv2(:,:,i,j) = (R - eye(3))/(-stepsize*(1+skip));% this is the elastic distortion derivative in the 2-direction
            else
                betaderiv2(:,:,i,j) = zeros(3);
            end
            
            
            % check for suitable misorientations between neighboring points in the
            % 1-direction
            numpts=0;
            if j<n-skip
                if i<m-skip
                    if cangle(i,j)<maxmiso %b-c
                        numpts=numpts+1;
                        misoave(numpts,:,:)=cmiso(:,:,i,j);
                    end
                end
                if smooth
                    if i<m-skip-1 %A-Ac
                        if cangle(i+1,j)<maxmiso
                            numpts=numpts+1;
                            misoave(numpts,:,:)=cmiso(:,:,i+1,j);
                        end
                    end
                    if i>1%AC-A
                        if cangle(i-1,j)<maxmiso
                            numpts=numpts+1;
                            misoave(numpts,:,:)=cmiso(:,:,i-1,j);
                        end
                    end
                end
            end
            if smooth
                if j>1
                    if i<m-skip %C-b
                        if cangle(i,j-1)<maxmiso
                            numpts=numpts+1;
                            misoave(numpts,:,:)=cmiso(:,:,i,j-1);
                        end
                    end
                    if i<m-skip-1 %aC-a
                        if cangle(i+1,j-1)<maxmiso
                            numpts=numpts+1;
                            misoave(numpts,:,:)=cmiso(:,:,i+1,j-1);
                        end
                    end
                    if i>1 %AC-A
                        if cangle(i-1,j-1)<maxmiso
                            numpts=numpts+1;
                            misoave(numpts,:,:)=cmiso(:,:,i-1,j-1);
                        end
                    end
                end
            end
            % average the derivatives over those points that have small
            % misorientations
            np1(i,j) = numpts;
            if numpts>0
                quat=[];
                for k=1:numpts
                    quat=[quat; rmat2quat(squeeze(misoave(k,:,:)))]; % put misorientation matrix into quaternion space to average
                end
                avg = sum(quat,1)/numpts;
                avg = avg/norm(avg);
                R=quat2rmat(avg)';
                
                betaderiv1(:,:,i,j) = (R - eye(3))/(stepsize*(1+skip)); % this is the elastic distortion derivative in the 1-direction
            else
                betaderiv1(:,:,i,j) = zeros(3);
            end
            
        end
    end
end

% Caculate the Nye Tensor
alpha=zeros(3,3,m,n);
clear alpha alpha_total3
alpha(1,3,:,:)=(betaderiv2(1,1,:,:) - betaderiv1(1,2,:,:))/bavg; % alpha(1,3)
alpha(2,3,:,:)=(betaderiv2(2,1,:,:) - betaderiv1(2,2,:,:))/bavg; % alpha(2,3)
alpha(3,3,:,:)=(betaderiv2(3,1,:,:) - betaderiv1(3,2,:,:))/bavg; % alpha(3,3)
alpha(1,2,:,:)=betaderiv1(1,3,:,:)/bavg; % alpha(1,2)
alpha(2,2,:,:)=betaderiv1(2,3,:,:)/bavg; % alpha(2,2)
alpha(3,2,:,:)=betaderiv1(3,3,:,:)/bavg; % alpha(3,2)
alpha(1,1,:,:)=-1*betaderiv2(1,3,:,:)/bavg; % alpha(1,1)
alpha(2,1,:,:)=-1*betaderiv2(2,3,:,:)/bavg; % alpha(2,1)
alpha(3,1,:,:)=-1*betaderiv2(3,3,:,:)/bavg; % alpha(3,1)

% Calculate 3 possible L1 norms of Nye tensor for total disloction density
alpha_total3(:,:)=30/10.*(abs(alpha(1,3,:,:))+abs(alpha(2,3,:,:))+abs(alpha(3,3,:,:)));
alpha_total5(:,:)=30/14.*(abs(alpha(1,3,:,:))+abs(alpha(2,3,:,:))+abs(alpha(3,3,:,:))+abs(alpha(2,1,:,:))+abs(alpha(1,2,:,:)));
alpha_total9(:,:)=30/20.*abs(alpha(1,3,:,:))+abs(alpha(2,3,:,:))+abs(alpha(3,3,:,:))+abs(alpha(1,1,:,:))+abs(alpha(2,1,:,:))+abs(alpha(3,1,:,:))+abs(alpha(1,2,:,:))+abs(alpha(2,2,:,:))+abs(alpha(3,2,:,:));

alpha_data.alpha = alpha;
alpha_data.alpha_total3 = alpha_total3;
alpha_data.alpha_total5 = alpha_total5;
alpha_data.alpha_total9 = alpha_total9;

% alphalist = reshape(alpha,3,3,ScanLength);
% GNDAvg = mean(alphalist(1,3,alphalist(1,3,:)>0));
% GNDStd = std(alphalist(1,3,alphalist(1,3,:)>0));
% fprintf('Alpha(1,3) Avg: %g\n',GNDAvg);
% fprintf('Alpha(1,3) Std: %g\n',GNDStd);
%
% figure
% imagesc(real(squeeze(log10(alpha(1,3,:,:)))))

GNDAvg = mean(alpha_total3(alpha_total3>0));
GNDStd = std(alpha_total3(alpha_total3>0));
fprintf('Alpha(1,3) Avg: %g\n',GNDAvg);
fprintf('Alpha(1,3) Std: %g\n',GNDStd);

figure
imagesc(log10(real(alpha_total3)))
title('GND density using Alpha3')
caxis([11 15])
colormap(gca,jet);
colorbar
c = colorbar; % Change colorbar title
c.Label.String = 'GND (10^x^x^.^x m^-^2)';


