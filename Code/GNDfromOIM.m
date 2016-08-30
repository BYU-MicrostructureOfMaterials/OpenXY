function alpha_data = GNDfromOIM(datain,bavg,lattice,maxmiso)
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
%              AC - A - Ac
%               |   |   |
%               C - b - c
%               |   |   |
%              aC - a - ac
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
%Edited by BEJ July 2016

% 8/3/2016 58 seconds


%Handle inputs
if nargin == 1
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
n = Settings.Nx;
m = Settings.Ny;
IQ = Settings.IQ;
    XData = Settings.XData;
    YData = Settings.YData;
M = ReadMaterial(Settings.Phase{1});
    lattype=M.lattice;
    bavg=M.Burgers;
    maxmiso=Settings.MisoTol;
    ScanLength=m*n;
    stepsize = (XData(3)-XData(2))*1e-6;    %***** can ystep be different?????
    
AngMap = vec2map(Angles,n,Settings.ScanType);
XMap = vec2map(Angles,n,Settings.ScanType);
YMap = vec2map(Angles,n,Settings.ScanType);
IQMap = vec2map(IQ,n,Settings.ScanType);
    
if strcmp(Settings.ScanType,'Hexagonal')
    ncolodd=floor(n/2)+1;
    ncoleven=ncolodd-1;
    nphi1 = Hex2Array(Angles(:,1),ncolodd,ncoleven);
    nPHI = Hex2Array(Angles(:,2),ncolodd,ncoleven);
    nphi2 = Hex2Array(Angles(:,3),ncolodd,ncoleven);
    xsq = Hex2Array(XData,ncolodd,ncoleven);
    ysq = Hex2Array(YData,ncolodd,ncoleven);
    iqRS = Hex2Array(IQ,ncolodd,ncoleven);
    [m,n]=size(iqRS);
else   
    xsq = reshape(XData,n,m)';
    ysq = reshape(YData,n,m)';
    nphi1 = reshape(Angles(:,1),n,m)';
    nPHI = reshape(Angles(:,2),n,m)';
    nphi2 = reshape(Angles(:,3),n,m)';
    iqRS = reshape(IQ,n,m)';
end

smooth = 0;
skip = 0;

aangle = zeros(m-skip-1,n-skip-1);
cangle = aangle;
amiso = zeros(3,3,m-skip-1,n-skip-1);
cmiso = amiso;


[RefIndA,RefIndC] = GetAdjacentInds([n,m],1:ScanLength,skip,Settings.ScanType);
q = euler2quat(Angles);
q_symops = rmat2quat(permute(gensymopsHex,[3 2 1]));
[misoa,~,~,deltaa] = quatMisoSym(q,q(RefIndA,:),q_symops,'element');
[misob,~,~,deltab] = quatMisoSym(q,q(RefIndA,:),q_symops,'element');


for i=1:m-skip-1    % work out all misorientations between points and right (cmiso) and down (amiso) neighbors
    for j=1:n-skip-1
        thisg = euler2gmat(nphi1(i,j),nPHI(i,j),nphi2(i,j));
        thisa = euler2gmat(nphi1(i+1+skip,j),nPHI(i+1+skip,j),nphi2(i+1+skip,j)); % -y goes with i
        [angle,Axis,deltaG]=GeneralMisoCalcSym(thisg,thisa,lattype);
        aangle(i,j) = angle;
        amiso(:,:,i,j) = (thisg'*(deltaG)*thisg)'; % transpose since it should be active rather than passive rotation
        thisc = euler2gmat(nphi1(i,j+1+skip),nPHI(i,j+1+skip),nphi2(i,j+1+skip));
        [angle,Axis,deltaG]=GeneralMisoCalcSym(thisg,thisc,lattype);
        cmiso(:,:,i,j) = (thisg'*(deltaG)*thisg)';
        cangle(i,j) = angle;
    end
end


%
%              aC - a - ac
%               |   |   |
%               C - b - c
%               |   |   |
%              AC - A - Ac

Ind = (1:ScanLength)';
Ind = vec2map(Ind,n,Settings.ScanType);

toprow = Ind<=n*(skippts+1);
botrow = Ind<ScanLength-n*(skippts+1);
rightside = mod(Ind,n)==0 | (n-mod(Ind,n))<=skippts;
leftside = mod(Ind,n)<=skippts+1;



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
                end
            end
            if smooth
                if j<n-skip-1 %c-ac
                    if aangle(i,j+1)<maxmiso
                        numpts=numpts+1;
                        misoave(numpts,:,:)=amiso(:,:,i,j+1);
                    end
                end
                if j>1 %C-aC
                    if aangle(i,j-1)<maxmiso
                        numpts=numpts+1;
                        misoave(numpts,:,:)=amiso(:,:,i,j-1);
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
                    end
                end
                if j<n-skip-1 %Ac-c
                    if aangle(i-1,j+1)<maxmiso
                        numpts=numpts+1;
                        misoave(numpts,:,:)=amiso(:,:,i-1,j+1);
                    end
                end
                if j>1 %AC-C
                    if aangle(i-1,j-1)<maxmiso
                        numpts=numpts+1;
                        misoave(numpts,:,:)=amiso(:,:,i-1,j-1);
                    end
                end
            end
        end
        % average the derivatives over those points that have small
        % misorientations
        if numpts>0
            quat=[];
            for k=1:numpts
                quat=[quat rmat2quat(squeeze(misoave(k,:,:)))];% put misorientation matrix into quaternion space to average
            end
            avg = sum(quat,1)/numpts;
            avg = avg/norm(avg);
            R=quat2rmat(avg)'; % transpose because for some reason sending to quaternion space and pack transposes it
            
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
        if numpts>0
            quat=[];
            for k=1:numpts
                quat=[quat rmat2quat(squeeze(misoave(k,:,:)))]; % put misorientation matrix into quaternion space to average
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

% Caculate the Nye Tensor
alpha=zeros(3,3,m,n);
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

figure
imagesc(log10(alpha_total3))
title('GND density using Alpha3')

