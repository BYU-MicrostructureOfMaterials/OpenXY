function alpha_data = GNDfromOIM(datain)
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

if nargin == 1
    matorang = isstruct(datain);
    if matorang
        Settings = datain;
        clear datain;
    end
else
    matorang=input('.mat file (1) or .ang file (0)? ');
    if matorang
        [picname, picpath] = uigetfile('*.mat','AnalysisParams(.mat) file');
        temp = load([picpath picname]);
        Settings = temp.Settings;
        clear temp
    end
end

if matorang
    if iscell(Settings.data.phi1rn)==1
        nphi1 = real(cell2mat(Settings.data.phi1rn));
        nPHI =  real(cell2mat(Settings.data.PHIrn));
        nphi2 =  real(cell2mat(Settings.data.phi2rn));
        %          nphi1 = Settings.Angles(:,1);
        %         nPHI =  Settings.Angles(:,2);
        %         nphi2 =  Settings.Angles(:,3);
    else
        nphi1 = real((Settings.data.phi1rn));
        nPHI =  real((Settings.data.PHIrn));
        nphi2 =  real((Settings.data.phi2rn));
    end
    n = Settings.data.cols;
    m = Settings.data.rows;
    IQ = cell2mat(Settings.data.IQ);
    XData = Settings.XData;
    YData = Settings.YData;
    CI = Settings.CI;
    Fit = Settings.Fit;
    if isfield(Settings,'Phase')
        M=ReadMaterial(cell2mat(Settings.Phase(1)));
    else
        M=ReadMaterial(Settings.Material);
    end
    lattype=M.lattice;
    bavg=M.Burgers;
    maxmiso=Settings.MisoTol;
    ScanLength=m*n;
    stepsize = (XData(3)-XData(2))*1e-6;    %***** can ystep be different?????
else
    if nargin == 1
        ScanFileData = ReadAngFile(datain);
    else
        ScanFileData = ReadAngFile;
    end
    bavg=input('What is the average Burgers vector length? (SI units): ');
    lt=input('Is lattice hexagonal (1) or cubic (2)?: ');
    if (lt==1)
        lattype = 'hexagonal';
    else
        lattype = 'cubic';
    end
    maxmiso=input('What is the maximum misorientation (degrees) for valid GND calculations (e.g. 5)? ');
    ScanLength = size(ScanFileData{1},1);
    % nphi1 = zeros(ScanLength,1);
    % nPHI=nphi1;
    % nphi2=nphi1;
    % XData = zeros(ScanLength,1);
    % YData = zeros(ScanLength,1);
    % IQ = zeros(ScanLength,1);
    % CI = zeros(ScanLength,1);
    % Fit = zeros(ScanLength,1);
    
    %Read ScanFile Data into Settings
    nphi1 = ScanFileData{1};
    nPHI = ScanFileData{2};
    nphi2 = ScanFileData{3};
    XData = ScanFileData{4};
    YData = ScanFileData{5};
    IQ = ScanFileData{6};
    CI = ScanFileData{7};
    Fit = ScanFileData{10};
    
    n = length(unique(XData));
    m = length(unique(YData));
    stepsize = (XData(3) - XData(2))*1e-6;
end

if n*m>length(IQ) % assume hex scan in this case*******only temporary and not accurate - needs to account for shifted columns
    ncolodd=floor(n/2)+1;
    ncoleven=ncolodd-1;
    nphi1 = Hex2Array(nphi1,ncolodd,ncoleven);
    nPHIrnsq = Hex2Array(nPHI,ncolodd,ncoleven);
    nphi2 = Hex2Array(nphi2,ncolodd,ncoleven);
    xsq = Hex2Array(XData,ncolodd,ncoleven);
    ysq = Hex2Array(YData,ncolodd,ncoleven);
    iqRS = Hex2Array(IQ,ncolodd,ncoleven);
    [m,n]=size(iqRS);
else
    xsq = reshape(XData,n,m)';
    ysq = reshape(YData,n,m)';
    nphi1 = reshape(nphi1,n,m)';
    nPHI = reshape(nPHI,n,m)';
    nphi2 = reshape(nphi2,n,m)';
    iqRS = reshape(IQ,n,m)';
end

smooth = 0;
skip = 0;
aangle = zeros(m-skip-1,n-skip-1);
cangle = aangle;
amiso = zeros(3,3,m-skip-1,n-skip-1);
cmiso = amiso;

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

%              AC - A - Ac
%               |   |   |
%               C - b - c
%               |   |   |
%              aC - a - ac

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
            avg = sum(quat,2)/numpts;
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
            avg = sum(quat,2)/numpts;
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
alpha_total3(:,:)=3.*(abs(alpha(1,3,:,:))+abs(alpha(2,3,:,:))+abs(alpha(3,3,:,:)));
alpha_total5(:,:)=9/5.*(abs(alpha(1,3,:,:))+abs(alpha(2,3,:,:))+abs(alpha(3,3,:,:))+abs(alpha(2,1,:,:))+abs(alpha(1,2,:,:)));
alpha_total9(:,:)=abs(alpha(1,3,:,:))+abs(alpha(2,3,:,:))+abs(alpha(3,3,:,:))+abs(alpha(1,1,:,:))+abs(alpha(2,1,:,:))+abs(alpha(3,1,:,:))+abs(alpha(1,2,:,:))+abs(alpha(2,2,:,:))+abs(alpha(3,2,:,:));

alpha_data.alpha = alpha;
alpha_data.alpha_total3 = alpha_total3;
alpha_data.alpha_total5 = alpha_total5;
alpha_data.alpha_total9 = alpha_total9;

figure
imagesc(log10(alpha_total3))
title('GND density using Alpha3')

