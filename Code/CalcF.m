function [F, SSE, XX] = CalcF(RefImage,ScanImage,g,Fo,Ind,Settings,curMaterial,RefInd)
%Desc: This function can be used to calculate the deformation tensor F (in the crystal frame) that
%describes the deformation to move the pattern RefImage onto the pattern ScanImage.
% modified 10/28/14 by DTF to correctly change Pattern Center when using
% real reference pattern
%Inputs: RefImage - A 1000x1000 intensity image of a pattern at the reference
%              point
%        ScanImage - A 1000x1000 intensity image of a pattern at the measurement
%        point
%        g  - the 3x3 orientation matrix as per bunge or euler2gmat.m of
%             the reference point (pure rotation)
%        Fo - the deformation tensor of the reference pattern (for
%               wilkinson's method assume that this is the identity.
%        Settings - structure with all microscope, geometry, material, and ROI settings.
%        it needs the following fields:
%        {XStar;YStar;ZStar;PixelSize;ROISize;roixc;roiyc;Av;SampleTilt;CameraElevation;roifilt;Material};, elastic constants different for hcp
%Applies the BC so that Fo*F satisfies BC
%        RefInd is the index of the reference image for Wilkinson type
%        analysis; if it is not input then we must be using simulated
%        pattern method
%
%% handle inputs

Material = ReadMaterial(curMaterial);
g0 = g;

if nargin < 8
    RefInd = 0;
end

RefImage=double(RefImage);
ScanImage=double(ScanImage);

roixc = Settings.roixc;
roiyc = Settings.roiyc;
xstar = Settings.XStar(Ind);
ystar = Settings.YStar(Ind);
zstar = Settings.ZStar(Ind);
standev = Settings.StandardDeviation;

%% set up filter for ROI filtering
if ~any(Settings.ROIFilter)
    custfilt = [];
    windowfunc = custfilt;
else
    lowerrad = Settings.ROIFilter(1);
    upperrad = Settings.ROIFilter(2);
    L = Settings.ROISize + 1;
    xc = round(L/2);
    yc = round(L/2);
    
    custfilt = zeros(L-1,L-1);
    
    i = 1:Settings.ROISize;
    j = 1:Settings.ROISize;
    IJ = meshgrid(i,j);
    dist = sqrt((IJ-ones(size(IJ)).*xc).^2+(IJ'-ones(size(IJ)).*yc).^2);
    custfilt(dist<lowerrad | dist>upperrad) = 1;
    if Settings.ROIFilter(4)==1
        custfilt(dist>upperrad & dist<upperrad+13)=erf((dist(dist>upperrad & dist<upperrad+13)-upperrad)/13*pi);
    end
    if Settings.ROIFilter(3)==1;
        custfilt(dist<lowerrad & dist>lowerrad-13)=erf(-(dist(dist<lowerrad & dist>lowerrad-13)-lowerrad)/13*pi);
    end
    custfilt=1-custfilt;
    custfilt=fftshift((custfilt));
    
    xc=L/2;
    yc=L/2;
    windowfunc = cos((IJ-ones(size(IJ)).*xc)*pi/Settings.ROISize)...
        .* cos((IJ'-ones(size(IJ)).*yc)*pi/Settings.ROISize);
end

%% geometry / coordinate frame transformation
alpha=pi/2-Settings.SampleTilt+Settings.CameraElevation;
% Sample to Crystal
if length(g(:))<9
    phi1=g(1);
    PHI=g(2);
    phi2=g(3);
    Qsc=euler2gmat(phi1,PHI,phi2);
else
    Qsc=g;
end
[g U]=poldec(Qsc);
if sum(sum(U-eye(3)))>1e-10
    error('g must be a pure rotation');
end
Qcs=Qsc';
if sum(sum(Qsc*Qcs-eye(3)))>1e-10
    error('the orientation matrix has issues')
end

Qvp=[-1 0 0; 0 -1 0; 0 0 1];
% Qpv=Qvp';

Dvp=[(xstar)*Settings.PixelSize;(1-ystar)*Settings.PixelSize;0];
% Dpv=-Qpv*Dvp;

% Phospher to sample
Qps=[0 -cos(alpha) -sin(alpha);...
    -1     0            0;...
    0   sin(alpha) -cos(alpha)];
Qsp=Qps';
% Crystal to Phospher Screen
% Qcp=Qsp*Qcs;
% Qpc=Qcp';
% Translation between frames
Dps=Qps*[0;0;-zstar*Settings.PixelSize];%in pixels in sample frame
% Dsp=[0;0;zstar*Settings.PixelSize];
% Dpc=Qpc*[0;0;-zstar*Settings.PixelSize];
% 1) Find the pattern center direction in crystal frame
% rpc=Qpc*[0;0;-1];

%% Preallocate for loop
qs1 = zeros(1,length(roixc));
qs2 = zeros(1,length(roixc));
qs3 = zeros(1,length(roixc));
qc1 = zeros(1,length(roixc));
qc2 = zeros(1,length(roixc));
qc3 = zeros(1,length(roixc));
rs1 = zeros(1,length(roixc));
rs2 = zeros(1,length(roixc));
rs3 = zeros(1,length(roixc));
rsp1 = zeros(1,length(roixc));
rsp2 = zeros(1,length(roixc));
rsp3 = zeros(1,length(roixc));
rc1 = zeros(1,length(roixc));
rc2 = zeros(1,length(roixc));
rc3 = zeros(1,length(roixc));
rcp1 = zeros(1,length(roixc));
rcp2 = zeros(1,length(roixc));
rcp3 = zeros(1,length(roixc));
l = zeros(1,length(roixc));
lp = zeros(1,length(roixc));
Rshift = zeros(1,length(roixc));
Cshift = zeros(1,length(roixc));
dRshift = zeros(1,length(roixc));
dCshift = zeros(1,length(roixc));


%% Go over each ROI
for i=1:length(roixc)
    rc=roiyc(i);
    cc=roixc(i);
    %This is a vector describing a position on the screen in
    %the screen frame before initial deformation
    Xp = Qvp*[cc;rc;0]+Dvp;
    %Direction described in sample frame before initial deformation
    Xs = Qps*Xp+Dps;
    Xsh = Xs;
    Xc = Qsc*Xs;
    Xch = Xc;
    lambdah = norm(Xc);
    %     Xc=Fo*Xc; %Deformed roi center direction in initial crystal frame
    %     Xs=Qsc'*Xc;
    n = Qps*[0,0,-1]';
    %shift from sample origin to phospher origin described in sample frame
    c = Qps*[0;0;-zstar]*Settings.PixelSize;
    
    rrange=round(rc-Settings.ROISize/2):round(rc-Settings.ROISize/2)+Settings.ROISize-1;
    crange=round(cc-Settings.ROISize/2):round(cc-Settings.ROISize/2)+Settings.ROISize-1;
    %
    %     if method == 1% method = 0 was just for testing and as not used here.
    
    if size(RefImage)~=size(ScanImage)
        RefImage=ScanImage;
        disp('No Ref Image')
    end
    
    %Calculate Cross-Correlation Coefficient
    RefROI = RefImage(rrange,crange);
    ScanROI = ScanImage(rrange,crange);
    
    RefROI = RefROI - mean(RefROI(:));
    ScanROI = ScanROI - mean(ScanROI(:));
    XX(i,1) = sum(sum(RefROI.*ScanROI/(std(RefROI(:))*std(ScanROI))))/numel(RefROI);
    
    %Perform Cross-Correlation
    [rimage, dxshift, dyshift] = custfftxc((RefImage(rrange,crange)),...
        (ScanImage(rrange,crange)),0,RefImage,rc,cc,custfilt,windowfunc);%this is the screen shift in the F(i-1) frame
     
    %Calculate Confidence of Shift
    XX(i,2) = (max(rimage(:))-mean(rimage(:)))/std(rimage(:));
    
    %Calculate Mutual Information (Requires Image Processing Toolbox)
    if isfield(Settings,'CalcMI') && Settings.CalcMI
        XX(i,3) = CalcMutualInformation(RefROI,ScanROI);
    else
        XX(i,3) = 0;
    end
    
    if RefInd~=0 % new if statement for when there is a single ref image DTF 7/16/14 this is to adjust PC in Wilkinson method for that single ref case ***need to do it for all wilkinson cases***
         tx=(xstar-Settings.XStar(RefInd))*Settings.PixelSize; % vector on phosphor between PC of ref and PC of measured; uses notation from PCsensitivity paper
         ty=(ystar-Settings.YStar(RefInd))*Settings.PixelSize;
%          tantheta=atan2(sqrt((cc-Settings.YStar(Settings.RefImageInd))^2+(rc-Settings.XStar(Settings.RefImageInd))^2),Settings.ZStar(Settings.RefImageInd));
         spminussx=(zstar-Settings.ZStar(RefInd))*(rc-Settings.XStar(RefInd)*Settings.PixelSize)/Settings.ZStar(RefInd); % difference of vectors from PC to ROI center for ref and scan pattern
         spminussy=(zstar-Settings.ZStar(RefInd))*(cc-Settings.YStar(RefInd)*Settings.PixelSize)/Settings.ZStar(RefInd);
         dxshift=dxshift-tx-spminussx; % corrected ROI shift taking into account PC shift
         dyshift=dyshift-ty-spminussy; %****NOT SURE ABOUT SIGN ON THIS
    end
    [xshift0,yshift0] = Theoretical_Pixel_Shift(Qsc,xstar,ystar,zstar,cc,rc,Fo,Settings.PixelSize,alpha);%this is the screen shift in the g (hough) frame *****not used***
    
    %     else
    %         [ro uo]=poldec(Fo);
    %         [dxshift,dyshift] = Theoretical_Pixel_Shift(ro'*Qsc,xstar,ystar,zstar,cc,rc,F,Settings.PixelSize,alpha);%this is the screen shift in the F(i-1) frame
    %         [xshift0,yshift0] = Theoretical_Pixel_Shift(Qsc,xstar,ystar,zstar,cc,rc,Fo,Settings.PixelSize,alpha); %this is the screen shift in the g (hough) frame
    %     end
    
    % inaddition to r we want to record the deformed r
    Xp=Qvp*[cc+dxshift; (rc+dyshift);0]+Dvp;
    %Direction described in sample frame
    Xsp=Qps*Xp+Dps;
    Xcp=Qsc*Xsp;
    Xcp=Fo*Xcp;
    Xsp=Qsc'*Xcp;
    nXsp=Xsp/norm(Xsp);
%     nXcp=Qsc'*nXsp; % old erroneous code - messed up Colin Crystal
    nXcp=Xcp/norm(Xcp); %new code  gives correct F for deformed simulated pattern to ~0.0005 dtf 8/25/14
    %find intersection of Xsp and phosphor
    lambdap=(n'*c)./(n'*nXsp);
    
    
    qs=lambdap*nXsp-Xsh;
    qs=qs/lambdah;
    qc=Qsc*qs;
    qp=Qsp*qs;
    qv=Qvp*qp;
    
    xshift=qv(1)*lambdah;
    yshift=qv(2)*lambdah;
    
    
    qs1(i)=qs(1);
    qs2(i)=qs(2);
    qs3(i)=qs(3);
    qc1(i)=qc(1);
    qc2(i)=qc(2);
    qc3(i)=qc(3);
    rs1(i)=Xsh(1)/lambdah;
    rs2(i)=Xsh(2)/lambdah;
    rs3(i)=Xsh(3)/lambdah;
    rsp1(i)=nXsp(1);
    rsp2(i)=nXsp(2);
    rsp3(i)=nXsp(3);
    rc1(i)=Xch(1)/lambdah;
    rc2(i)=Xch(2)/lambdah;
    rc3(i)=Xch(3)/lambdah;
    rcp1(i)=nXcp(1);
    rcp2(i)=nXcp(2);
    rcp3(i)=nXcp(3);
    l(i)=lambdah;
    lp(i)=lambdap;
    Rshift(i)=yshift;
    Cshift(i)=xshift;
    dRshift(i)=dyshift;
    dCshift(i)=dxshift;
    
    
end
%remove bad regions
stdevR=std(dRshift);
mR=mean(dRshift);
stdevC=std(dCshift);
mC=mean(dCshift);
if stdevR~=0 && stdevC~=0
    tempind=find(abs(dRshift)<129&abs(dCshift)<129&abs(dRshift-mR)<standev*stdevR&abs(dCshift-mC)<standev*stdevC);
    rs1=(rs1(tempind));
    rs2=(rs2(tempind));
    rs3=(rs3(tempind));
    rsp1=(rsp1(tempind));
    rsp2=(rsp2(tempind));
    rsp3=(rsp3(tempind));
    qs1=(qs1(tempind));
    qs2=(qs2(tempind));
    qs3=(qs3(tempind));
    rc1=(rc1(tempind));
    rc2=(rc2(tempind));
    rc3=(rc3(tempind));
    rcp1=(rcp1(tempind));
    rcp2=(rcp2(tempind));
    rcp3=(rcp3(tempind));
    qc1=(qc1(tempind));
    qc2=(qc2(tempind));
    qc3=(qc3(tempind));
    
    if length(tempind)<4
        F=eye(3);
        SSE=0;
        disp('Too few good ROI''s');
        return
    end
else
    tempind=1:length(rc3);
end
length(tempind);
g=Qsc;
%Create stiffness matrix
if strcmp(Material.lattice,'cubic') || strcmp(Material.lattice,'tetragonal')
    C1111=Material.C11*1e9;
    C2323=Material.C44*1e9;
    C1122=Material.C12*1e9;
    delta=eye(3);
    %Transform to the crystal apply stress normal to surface is zero
    Cc=zeros(3,3,3,3);
    Cs=zeros(3,3,3,3);
    
    g=g';
    for i=1:3
        for j=1:3
            for k=1:3
                for ls=1:3
                    Cc(i,j,k,ls)=C1122*delta(i,j)*delta(k,ls)+C2323*(delta(i,k)*delta(j,ls)+delta(i,ls)*delta(j,k))...
                        +(C1111-C1122-2*C2323)*(delta(1,i)*delta(1,j)*delta(1,k)*delta(1,ls)+delta(2,i)*delta(2,j)*delta(2,k)*delta(2,ls)+delta(3,i)*delta(3,j)*delta(3,k)*delta(3,ls));
                    Cs(i,j,k,ls)=C1122*delta(i,j)*delta(k,ls)+C2323*(delta(i,k)*delta(j,ls)+delta(i,ls)*delta(j,k))...
                        +(C1111-C1122-2*C2323)*(g(i,1)*g(j,1)*g(k,1)*g(ls,1)+g(i,2)*g(j,2)*g(k,2)*g(ls,2)+g(i,3)*g(j,3)*g(k,3)*g(ls,3));
                    
                end
            end
        end
    end
else
    C1111=Material.C11*1e9;
    C3333=Material.C33*1e9;
    C1212=Material.C66*1e9;
    C2323=Material.C44*1e9;
    C1122=Material.C12*1e9;
    C1133=Material.C13*1e9;
    delta=eye(3);
    %Transform to the crystal apply stress normal to surface is zero
    Cc=zeros(3,3,3,3);
    Cs=zeros(3,3,3,3);
    
    g=g';
    
    %for hexagonal lattice in crystal frame, I couldn't think of a more clever
    %way of doing this, but I'm sure that there is one. Not sure if the
    %sample frame is correct
    for i=1:3
        for j=1:3
            for k=1:3
                for ls=1:3
                    Cc(i,j,k,ls)=C1133*delta(i,j)*delta(k,ls)+C2323*(delta(i,k)*delta(j,ls)+delta(i,ls)*delta(j,k))...
                        +(C1111-C1133-2*C2323)*(delta(1,i)*delta(1,j)*delta(1,k)*delta(1,ls)+delta(2,i)*delta(2,j)*delta(2,k)*delta(2,ls)+delta(3,i)*delta(3,j)*delta(3,k)*delta(3,ls));
                end
            end
        end
    end
    Cc(1,2,1,2) = C1212;
    Cc(2,1,1,2) = C1212;
    Cc(1,2,2,1) = C1212;
    Cc(2,1,2,1) = C1212;
    Cc(1,1,2,2) = C1122;
    Cc(2,2,1,1) = C1122;
    Cc(3,3,3,3) = C3333;
    for i = 1:3
        for j = 1:3
            for k = 1:3
                for ls = 1:3
                    for m = 1:3
                        for n = 1:3
                            for o = 1:3
                                for p = 1:3
                                    Cs(i,j,k,ls) = Cs(i,j,k,ls) + g(i,m)*g(j,n)*g(k,o)*g(ls,p)*Cc(m,n,o,p);
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    Cc(1,1,2,2) = C1122;
    Cc(2,2,1,1) = C1122;
    Cc(3,3,3,3) = C3333;
    Cc(1,2,1,2) = C1212;
    Cc(1,2,2,1) = C1212;
    Cc(2,1,2,1) = C1212;
    Cc(2,1,1,2) = C1212;
end
g=g';
Z= zeros(length(tempind),1);


switch Settings.FCalcMethod
    
    
    case 'Real Sample'
        %% Method 1: Straight up real (sample frame)
        r1=rs1';
        r2=rs2';
        r3=rs3';
        q1=qs1';
        q2=qs2';
        q3=qs3';
        %coefficients
        %
        % Wilkinson's equations
        % variables:        a11-a33           a12                 a13             a21             a22-a33             a23             a31                 a32
        A1=[          r1.*r3          r2.*r3              r3.*r3              Z               Z               Z          -r1.*r1          -r1.*r2       ];
        % % variables:        a11-a33           a12                 a13             a21             a22-a33             a23             a31                 a32
        A2=[            Z               Z                       Z           r1.*r3            r2.*r3            r3.*r3          -r1.*r2             -r2.*r2 ];
        %
        %answers
        b1 = r3.*q1-r1.*q3;
        b2 = r3.*q2-r2.*q3;
        b3 = [b1;b2];
        A3 = [A1;A2];
        %solve for variables
        X3=A3\b3;
        %variables
        U12=X3(2);
        U13=X3(3);
        U21=X3(4);
        U23=X3(6);
        U31=X3(7);
        U32=X3(8);
        %note that e12=e21,  (e12+e21)=2*e12  e12=1/2(U12+U21) for small
        %deformations
        %    e11          e22   e33
        C=Cs;
        % boundary condition equations
        % A4=[C(1,3,1,1) C(1,3,2,2) C(1,3,3,3)];
        % A5=[C(2,3,1,1) C(2,3,2,2) C(2,3,3,3)];
        A6=[C(3,3,1,1) C(3,3,2,2) C(3,3,3,3)];
        A7=[1 0 -1];
        A8=[0 1 -1];
        % b4=-C(1,3,1,2)*(U12+U21)-C(1,3,1,3)*(U31+U13)-C(1,3,2,3)*(U23+U32);
        % b5=-C(2,3,1,2)*(U12+U21)-C(2,3,1,3)*(U13+U31)-C(2,3,3,2)*(U23+U32);
        b6=-C(3,3,1,2)*(U12+U21)-C(3,3,1,3)*(U13+U31)-C(3,3,3,2)*(U23+U32);
        b7=X3(1);
        b8=X3(5);
        % this is using all three boundary condition equations
        % X4=[A4;A5;A6;A7;A8]\[b4;b5;b6;b7;b8];
        % this is using only the sigma_33=0 boundary condition
        X4=[A6;A7;A8]\[b6;b7;b8];
        U11=X4(1);
        U22=X4(2);
        U33=X4(3);
        %This U is the one that deforms vectors in the sample frame
        U= [U11 U12 U13;...
            U21 U22 U23;...
            U31 U32 U33];
        F=U+eye(3);
        F=g*F*g'; %Put in crystal frame
        %calculate the sum of the squared errors
        [cx cy]=Theoretical_Pixel_Shift(Qsc,xstar,ystar,zstar,roixc,roiyc,F,Settings.PixelSize,alpha);
        SSE=sqrt(sum((cx(tempind)-Cshift(tempind)).^2+(cy(tempind)-Rshift(tempind)).^2)/length(tempind)) ;
        %         Fs{1}=F;
        %         SSEs(1)=SSE;
        %
        %         n=(g*[0;0;1])'*inv(Fo)/norm((g*[0;0;1])'*inv(Fo));
        %         C=Cc;
        %         % vars:                          a11                                        a12                                                     a13                                      a21                                 a22                                                           a23                                     a31                                                                a32                                 a33
        %         Aa=[ C(1,1,1,1)*n(1)+C(1,2,1,1)*n(2)+C(1,3,1,1)*n(3) C(1,1,1,2)*n(1)+C(1,2,1,2)*n(2)+C(1,3,1,2)*n(3)    C(1,1,1,3)*n(1)+C(1,2,1,3)*n(2)+C(1,3,1,3)*n(3) C(1,1,1,2)*n(1)+C(1,2,1,2)*n(2)+C(1,3,1,2)*n(3) C(1,1,2,2)*n(1)+C(1,2,2,2)*n(2)+C(1,3,2,2)*n(3)  C(1,1,2,3)*n(1)+C(1,2,2,3)*n(2)+C(1,3,2,3)*n(3)  C(1,1,1,3)*n(1)+C(1,2,1,3)*n(2)+C(1,3,1,3)*n(3)      C(1,1,2,3)*n(1)+C(1,2,2,3)*n(2)+C(1,3,2,3)*n(3) C(1,1,3,3)*n(1)+C(1,2,3,3)*n(2)+C(1,3,3,3)*n(3)];
        %         Ab=[ C(2,1,1,1)*n(1)+C(2,2,1,1)*n(2)+C(2,3,1,1)*n(3) C(2,1,1,2)*n(1)+C(2,2,1,2)*n(2)+C(2,3,1,2)*n(3)    C(2,1,1,3)*n(1)+C(2,2,1,3)*n(2)+C(2,3,1,3)*n(3) C(2,1,1,2)*n(1)+C(2,2,1,2)*n(2)+C(2,3,1,2)*n(3) C(2,1,2,2)*n(1)+C(2,2,2,2)*n(2)+C(2,3,2,2)*n(3)  C(2,1,2,3)*n(1)+C(2,2,2,3)*n(2)+C(2,3,2,3)*n(3)  C(2,1,1,3)*n(1)+C(2,2,1,3)*n(2)+C(2,3,1,3)*n(3)      C(2,1,2,3)*n(1)+C(2,2,2,3)*n(2)+C(2,3,2,3)*n(3) C(2,1,3,3)*n(1)+C(2,2,3,3)*n(2)+C(2,3,3,3)*n(3)];
        %         Ac=[ C(3,1,1,1)*n(1)+C(3,2,1,1)*n(2)+C(3,3,1,1)*n(3) C(3,1,1,2)*n(1)+C(3,2,1,2)*n(2)+C(3,3,1,2)*n(3)    C(3,1,1,3)*n(1)+C(3,2,1,3)*n(2)+C(3,3,1,3)*n(3) C(3,1,1,2)*n(1)+C(3,2,1,2)*n(2)+C(3,3,1,2)*n(3) C(3,1,2,2)*n(1)+C(3,2,2,2)*n(2)+C(3,3,2,2)*n(3)  C(3,1,2,3)*n(1)+C(3,2,2,3)*n(2)+C(3,3,2,3)*n(3)  C(3,1,1,3)*n(1)+C(3,2,1,3)*n(2)+C(3,3,1,3)*n(3)      C(3,1,2,3)*n(1)+C(3,2,2,3)*n(2)+C(3,3,2,3)*n(3) C(3,1,3,3)*n(1)+C(3,2,3,3)*n(2)+C(3,3,3,3)*n(3)];
        %         BCerr=[Aa;Ab;Ac]*[F(1,1)-1;F(1,2);F(1,3);F(2,1);F(2,2)-1;F(2,3);F(3,1);F(3,2);F(3,3)-1];
        %         BCerr = sqrt(sum(BCerr.^2));
        %         BCerrs(1)=BCerr;
        
    case 'Real Crystal'
        %% Method 2: wilkinson in crystal frame
        
        r1=rc1';
        r2=rc2';
        r3=rc3';
        q1=qc1';
        q2=qc2';
        q3=qc3';
        %coefficients
        %
        % variables:        a11-a33           a12                 a13             a21             a22-a33             a23             a31                 a32
        A1=[          r1.*r3          r2.*r3              r3.*r3              Z               Z               Z          -r1.*r1          -r1.*r2       ];
        % % variables:        a11-a33           a12                 a13             a21             a22-a33             a23             a31                 a32
        A2=[            Z               Z                       Z           r1.*r3            r2.*r3            r3.*r3          -r1.*r2             -r2.*r2 ];
        %
        %answers
        b1=r3.*q1-r1.*q3;
        b2=r3.*q2-r2.*q3;
        b3 = [b1;b2];
        A3 = [A1;A2];
        
        %solve for variables
        X3=A3\b3;
        %variables
        U12=X3(2);
        U13=X3(3);
        U21=X3(4);
        U23=X3(6);
        U31=X3(7);
        U32=X3(8);
        %note that e12=e21,  (e12+e21)=2*e12  e12=1/2(U12+U21) for small
        %deformations
        %    e11          e22   e33
        C=Cc;
        
        % boundary condition equations
        nr = g*[0;0;1];
        %         A4 = [C(1,1,1,1)*nr(1)+C(1,2,1,1)*nr(2)+C(1,3,1,1)*nr(3) C(1,1,2,2)*nr(1)+C(1,2,2,2)*nr(2)+C(1,3,2,2)*nr(3) C(1,1,3,3)*nr(1)+C(1,2,3,3)*nr(2)+C(1,3,3,3)*nr(3)];
        %         A5 = [C(2,1,1,1)*nr(1)+C(2,2,1,1)*nr(2)+C(2,3,1,1)*nr(3) C(2,1,2,2)*nr(1)+C(2,2,2,2)*nr(2)+C(2,3,2,2)*nr(3) C(2,1,3,3)*nr(1)+C(2,2,3,3)*nr(2)+C(2,3,3,3)*nr(3)];
        A6 = [C(3,1,1,1)*nr(1)+C(3,2,1,1)*nr(2)+C(3,3,1,1)*nr(3) C(3,1,2,2)*nr(1)+C(3,2,2,2)*nr(2)+C(3,3,2,2)*nr(3) C(3,1,3,3)*nr(1)+C(3,2,3,3)*nr(2)+C(3,3,3,3)*nr(3)];
        
        %         b4 = -(C(1,1,1,2)*nr(1)+C(1,2,1,2)*nr(2)+C(1,3,1,2)*nr(3))*(U21+U12)-(C(1,1,1,3)*nr(1)+C(1,2,1,3)*nr(2)+C(1,3,1,3)*nr(3))*(U31+U13)-(C(1,1,3,2)*nr(1)+C(1,2,3,2)*nr(2)+C(1,3,3,2)*nr(3))*(U23+U32);
        %         b5 = -(C(2,1,1,2)*nr(1)+C(2,2,1,2)*nr(2)+C(2,3,1,2)*nr(3))*(U21+U12)-(C(2,1,1,3)*nr(1)+C(2,2,1,3)*nr(2)+C(2,3,1,3)*nr(3))*(U31+U13)-(C(2,1,3,2)*nr(1)+C(2,2,3,2)*nr(2)+C(2,3,3,2)*nr(3))*(U23+U32);
        b6 = -(C(3,1,1,2)*nr(1)+C(3,2,1,2)*nr(2)+C(3,3,1,2)*nr(3))*(U21+U12)-(C(3,1,1,3)*nr(1)+C(3,2,1,3)*nr(2)+C(3,3,1,3)*nr(3))*(U31+U13)-(C(3,1,3,2)*nr(1)+C(3,2,3,2)*nr(2)+C(3,3,3,2)*nr(3))*(U23+U32);
        
        A7 = [1 0 -1];
        A8 = [0 1 -1];
        b7 = X3(1);
        b8 = X3(5);
        % this is applying all 3 boundary condition equations
        % X4=[A4;A5;A6;A7;A8]\[b4;b5;b6;b7;b8];
        % this is applying only the sigma_33=0 boundary condition
        X4=[A6;A7;A8]\[b6;b7;b8];
        U11=X4(1);
        U22=X4(2);
        U33=X4(3);
        %This U is the one that deforms vectors in the crystal frame
        U= [U11 U12 U13;...
            U21 U22 U23;...
            U31 U32 U33];
        F=U+eye(3);
        %calculate the sum of the squared errors
        [cx cy]=Theoretical_Pixel_Shift(Qsc,xstar,ystar,zstar,roixc,roiyc,F,Settings.PixelSize,alpha);
        SSE=sqrt(sum((cx(tempind)-Cshift(tempind)).^2+(cy(tempind)-Rshift(tempind)).^2)/length(tempind)) ;
        %         Fs{2}=F;
        %         SSEs(2)=SSE;
        
        %         n=(g*[0;0;1])'*inv(Fo)/norm((g*[0;0;1])'*inv(Fo));
        %         C=Cc;
        % vars:                          a11                                        a12                                                     a13                                      a21                                 a22                                                           a23                                     a31                                                                a32                                 a33
        %         Aa=[ C(1,1,1,1)*n(1)+C(1,2,1,1)*n(2)+C(1,3,1,1)*n(3) C(1,1,1,2)*n(1)+C(1,2,1,2)*n(2)+C(1,3,1,2)*n(3)    C(1,1,1,3)*n(1)+C(1,2,1,3)*n(2)+C(1,3,1,3)*n(3) C(1,1,1,2)*n(1)+C(1,2,1,2)*n(2)+C(1,3,1,2)*n(3) C(1,1,2,2)*n(1)+C(1,2,2,2)*n(2)+C(1,3,2,2)*n(3)  C(1,1,2,3)*n(1)+C(1,2,2,3)*n(2)+C(1,3,2,3)*n(3)  C(1,1,1,3)*n(1)+C(1,2,1,3)*n(2)+C(1,3,1,3)*n(3)      C(1,1,2,3)*n(1)+C(1,2,2,3)*n(2)+C(1,3,2,3)*n(3) C(1,1,3,3)*n(1)+C(1,2,3,3)*n(2)+C(1,3,3,3)*n(3)];
        %         Ab=[ C(2,1,1,1)*n(1)+C(2,2,1,1)*n(2)+C(2,3,1,1)*n(3) C(2,1,1,2)*n(1)+C(2,2,1,2)*n(2)+C(2,3,1,2)*n(3)    C(2,1,1,3)*n(1)+C(2,2,1,3)*n(2)+C(2,3,1,3)*n(3) C(2,1,1,2)*n(1)+C(2,2,1,2)*n(2)+C(2,3,1,2)*n(3) C(2,1,2,2)*n(1)+C(2,2,2,2)*n(2)+C(2,3,2,2)*n(3)  C(2,1,2,3)*n(1)+C(2,2,2,3)*n(2)+C(2,3,2,3)*n(3)  C(2,1,1,3)*n(1)+C(2,2,1,3)*n(2)+C(2,3,1,3)*n(3)      C(2,1,2,3)*n(1)+C(2,2,2,3)*n(2)+C(2,3,2,3)*n(3) C(2,1,3,3)*n(1)+C(2,2,3,3)*n(2)+C(2,3,3,3)*n(3)];
        %         Ac=[ C(3,1,1,1)*n(1)+C(3,2,1,1)*n(2)+C(3,3,1,1)*n(3) C(3,1,1,2)*n(1)+C(3,2,1,2)*n(2)+C(3,3,1,2)*n(3)    C(3,1,1,3)*n(1)+C(3,2,1,3)*n(2)+C(3,3,1,3)*n(3) C(3,1,1,2)*n(1)+C(3,2,1,2)*n(2)+C(3,3,1,2)*n(3) C(3,1,2,2)*n(1)+C(3,2,2,2)*n(2)+C(3,3,2,2)*n(3)  C(3,1,2,3)*n(1)+C(3,2,2,3)*n(2)+C(3,3,2,3)*n(3)  C(3,1,1,3)*n(1)+C(3,2,1,3)*n(2)+C(3,3,1,3)*n(3)      C(3,1,2,3)*n(1)+C(3,2,2,3)*n(2)+C(3,3,2,3)*n(3) C(3,1,3,3)*n(1)+C(3,2,3,3)*n(2)+C(3,3,3,3)*n(3)];
        %         BCerr=[Aa;Ab;Ac]*[F(1,1)-1;F(1,2);F(1,3);F(2,1);F(2,2)-1;F(2,3);F(3,1);F(3,2);F(3,3)-1];
        %         BCerr=sqrt(sum(BCerr.^2));
        %         BCerrs(2)=BCerr;
        
    case 'Collin Sample'
        %% method 5: Colin's method in sample frame
        r1=rs1';
        r2=rs2';
        r3=rs3';
        rp1=rsp1';
        rp2=rsp2';
        rp3=rsp3';
        
        q1=qs1';
        q2=qs2';
        q3=qs3';
        
        %?
        %         n=g'*((g*[0;0;1])'*inv(Fo)/norm((g*[0;0;1])'*inv(Fo)))';
        n = [0; 0; 1];
        C=Cs;
        
        % equations for boundary conditions
        % vars:                          a11                                        a12                                                     a13                                      a21                                 a22                                                           a23                                     a31                                                                a32                                 a33
        A5=[ C(1,1,1,1)*n(1)+C(1,2,1,1)*n(2)+C(1,3,1,1)*n(3) C(1,1,1,2)*n(1)+C(1,2,1,2)*n(2)+C(1,3,1,2)*n(3)    C(1,1,1,3)*n(1)+C(1,2,1,3)*n(2)+C(1,3,1,3)*n(3) C(1,1,1,2)*n(1)+C(1,2,1,2)*n(2)+C(1,3,1,2)*n(3) C(1,1,2,2)*n(1)+C(1,2,2,2)*n(2)+C(1,3,2,2)*n(3)  C(1,1,2,3)*n(1)+C(1,2,2,3)*n(2)+C(1,3,2,3)*n(3)  C(1,1,1,3)*n(1)+C(1,2,1,3)*n(2)+C(1,3,1,3)*n(3)      C(1,1,2,3)*n(1)+C(1,2,2,3)*n(2)+C(1,3,2,3)*n(3) C(1,1,3,3)*n(1)+C(1,2,3,3)*n(2)+C(1,3,3,3)*n(3)]/1e11;
        A6=[ C(2,1,1,1)*n(1)+C(2,2,1,1)*n(2)+C(2,3,1,1)*n(3) C(2,1,1,2)*n(1)+C(2,2,1,2)*n(2)+C(2,3,1,2)*n(3)    C(2,1,1,3)*n(1)+C(2,2,1,3)*n(2)+C(2,3,1,3)*n(3) C(2,1,1,2)*n(1)+C(2,2,1,2)*n(2)+C(2,3,1,2)*n(3) C(2,1,2,2)*n(1)+C(2,2,2,2)*n(2)+C(2,3,2,2)*n(3)  C(2,1,2,3)*n(1)+C(2,2,2,3)*n(2)+C(2,3,2,3)*n(3)  C(2,1,1,3)*n(1)+C(2,2,1,3)*n(2)+C(2,3,1,3)*n(3)      C(2,1,2,3)*n(1)+C(2,2,2,3)*n(2)+C(2,3,2,3)*n(3) C(2,1,3,3)*n(1)+C(2,2,3,3)*n(2)+C(2,3,3,3)*n(3)]/1e11;
        A7=[ C(3,1,1,1)*n(1)+C(3,2,1,1)*n(2)+C(3,3,1,1)*n(3) C(3,1,1,2)*n(1)+C(3,2,1,2)*n(2)+C(3,3,1,2)*n(3)    C(3,1,1,3)*n(1)+C(3,2,1,3)*n(2)+C(3,3,1,3)*n(3) C(3,1,1,2)*n(1)+C(3,2,1,2)*n(2)+C(3,3,1,2)*n(3) C(3,1,2,2)*n(1)+C(3,2,2,2)*n(2)+C(3,3,2,2)*n(3)  C(3,1,2,3)*n(1)+C(3,2,2,3)*n(2)+C(3,3,2,3)*n(3)  C(3,1,1,3)*n(1)+C(3,2,1,3)*n(2)+C(3,3,1,3)*n(3)      C(3,1,2,3)*n(1)+C(3,2,2,3)*n(2)+C(3,3,2,3)*n(3) C(3,1,3,3)*n(1)+C(3,2,3,3)*n(2)+C(3,3,3,3)*n(3)]/1e11;
        
        % Colin's equations
        % variables:        a11             a12                 a13             a21             a22             a23             a31                 a32                 a33
        A1=[        r1.*rp1.*rp1-r1   r2.*rp1.*rp1-r2   r3.*rp1.*rp1-r3     r1.*rp2.*rp1    r2.*rp2.*rp1     r3.*rp2.*rp1     r1.*rp3.*rp1      r2.*rp3.*rp1        r3.*rp3.*rp1 ];
        % variables:        a11             a12                 a13             a21             a22             a23             a31                  a32                 a33
        A2=[        r1.*rp1.*rp2      r2.*rp1.*rp2      r3.*rp1.*rp2        r1.*rp2.*rp2-r1 r2.*rp2.*rp2-r2  r3.*rp2.*rp2-r3  r1.*rp3.*rp2      r2.*rp3.*rp2        r3.*rp3.*rp2 ];
        % variables:        a11             a12                 a13             a21             a22             a23             a31                  a32                 a33
        A3=[        r1.*rp1.*rp3      r2.*rp1.*rp3      r3.*rp1.*rp3        r1.*rp2.*rp3    r2.*rp2.*rp3     r3.*rp2.*rp3     r1.*rp3.*rp3-r1   r2.*rp3.*rp3-r2     r3.*rp3.*rp3-r3 ];
        
        
        %answers
        b1=-q1-(q1.*rp1+q2.*rp2+q3.*rp3).*rp1;
        b2=-q2-(q1.*rp1+q2.*rp2+q3.*rp3).*rp2;
        b3=-q3-(q1.*rp1+q2.*rp2+q3.*rp3).*rp3;
        b5=0;
        b6=0;
        b7=0;
        b4 = [b1;b2;b3;b5;b6;b7];
        A4 = [A1;A2;A3;A5;A6;A7];
        %          b4 = [b1;b2;b3];
        %          A4 = [A1;A2;A3];
        
        % Using only the final traction free condition: ************
        % doesn't make significant difference  that I could see DTF 8/25/14
        % but see 8/26/ results - show that full BC is maybe 10% better
%         b4 = [b1;b2;b3;b7];
%         A4 = [A1;A2;A3;A7];
%         
        %solve for variables
        X3=A4\b4;
        %variables
        U11=X3(1);
        U12=X3(2);
        U13=X3(3);
        U21=X3(4);
        U22=X3(5);
        U23=X3(6);
        U31=X3(7);
        U32=X3(8);
        U33=X3(9);
        %This U is in the sample frame
        U= [U11 U12 U13;...
            U21 U22 U23;...
            U31 U32 U33];
        A=U+eye(3);
        F=g*A*g';
        
        [cx cy]=Theoretical_Pixel_Shift(Qsc,xstar,ystar,zstar,roixc,roiyc,F,Settings.PixelSize,alpha);
        SSE=sqrt(sum((cx(tempind)-Cshift(tempind)).^2+(cy(tempind)-Rshift(tempind)).^2)/length(tempind)) ;
        %         Fs{5}=F;
        %         SSEs(5)=SSE;
        %         n=(g*[0;0;1])'*inv(Fo)/norm((g*[0;0;1])'*inv(Fo));
        %         C=Cc;
        % vars:                          a11                                        a12                                                     a13                                      a21                                 a22                                                           a23                                     a31                                                                a32                                 a33
        %         Aa=[ C(1,1,1,1)*n(1)+C(1,2,1,1)*n(2)+C(1,3,1,1)*n(3) C(1,1,1,2)*n(1)+C(1,2,1,2)*n(2)+C(1,3,1,2)*n(3)    C(1,1,1,3)*n(1)+C(1,2,1,3)*n(2)+C(1,3,1,3)*n(3) C(1,1,1,2)*n(1)+C(1,2,1,2)*n(2)+C(1,3,1,2)*n(3) C(1,1,2,2)*n(1)+C(1,2,2,2)*n(2)+C(1,3,2,2)*n(3)  C(1,1,2,3)*n(1)+C(1,2,2,3)*n(2)+C(1,3,2,3)*n(3)  C(1,1,1,3)*n(1)+C(1,2,1,3)*n(2)+C(1,3,1,3)*n(3)      C(1,1,2,3)*n(1)+C(1,2,2,3)*n(2)+C(1,3,2,3)*n(3) C(1,1,3,3)*n(1)+C(1,2,3,3)*n(2)+C(1,3,3,3)*n(3)];
        %         Ab=[ C(2,1,1,1)*n(1)+C(2,2,1,1)*n(2)+C(2,3,1,1)*n(3) C(2,1,1,2)*n(1)+C(2,2,1,2)*n(2)+C(2,3,1,2)*n(3)    C(2,1,1,3)*n(1)+C(2,2,1,3)*n(2)+C(2,3,1,3)*n(3) C(2,1,1,2)*n(1)+C(2,2,1,2)*n(2)+C(2,3,1,2)*n(3) C(2,1,2,2)*n(1)+C(2,2,2,2)*n(2)+C(2,3,2,2)*n(3)  C(2,1,2,3)*n(1)+C(2,2,2,3)*n(2)+C(2,3,2,3)*n(3)  C(2,1,1,3)*n(1)+C(2,2,1,3)*n(2)+C(2,3,1,3)*n(3)      C(2,1,2,3)*n(1)+C(2,2,2,3)*n(2)+C(2,3,2,3)*n(3) C(2,1,3,3)*n(1)+C(2,2,3,3)*n(2)+C(2,3,3,3)*n(3)];
        %         Ac=[ C(3,1,1,1)*n(1)+C(3,2,1,1)*n(2)+C(3,3,1,1)*n(3) C(3,1,1,2)*n(1)+C(3,2,1,2)*n(2)+C(3,3,1,2)*n(3)    C(3,1,1,3)*n(1)+C(3,2,1,3)*n(2)+C(3,3,1,3)*n(3) C(3,1,1,2)*n(1)+C(3,2,1,2)*n(2)+C(3,3,1,2)*n(3) C(3,1,2,2)*n(1)+C(3,2,2,2)*n(2)+C(3,3,2,2)*n(3)  C(3,1,2,3)*n(1)+C(3,2,2,3)*n(2)+C(3,3,2,3)*n(3)  C(3,1,1,3)*n(1)+C(3,2,1,3)*n(2)+C(3,3,1,3)*n(3)      C(3,1,2,3)*n(1)+C(3,2,2,3)*n(2)+C(3,3,2,3)*n(3) C(3,1,3,3)*n(1)+C(3,2,3,3)*n(2)+C(3,3,3,3)*n(3)];
        %         BCerr=[Aa;Ab;Ac]*[F(1,1)-1;F(1,2);F(1,3);F(2,1);F(2,2)-1;F(2,3);F(3,1);F(3,2);F(3,3)-1];
        %         BCerr=sqrt(sum(BCerr.^2));
        %         BCerrs(5)=BCerr;
        
    case 'Collin Crystal'
        %% method 6: Colin's method in crystal frame
        
        r1=rc1';
        r2=rc2';
        r3=rc3';
        rp1=rcp1';
        rp2=rcp2';
        rp3=rcp3';
        
        q1=qc1';
        q2=qc2';
        q3=qc3';
        
        % n=(g*[0;0;1])'*inv(Fo)/norm((g*[0;0;1])'*inv(Fo));
        n = g*[0;0;1];
        C=Cc;
        
        % equations for boundary conditions
        % vars:                          a11                                        a12                                                     a13                                      a21                                 a22                                                           a23                                     a31                                                                a32                                 a33
        A5=[ C(1,1,1,1)*n(1)+C(1,2,1,1)*n(2)+C(1,3,1,1)*n(3) C(1,1,1,2)*n(1)+C(1,2,1,2)*n(2)+C(1,3,1,2)*n(3)    C(1,1,1,3)*n(1)+C(1,2,1,3)*n(2)+C(1,3,1,3)*n(3) C(1,1,1,2)*n(1)+C(1,2,1,2)*n(2)+C(1,3,1,2)*n(3) C(1,1,2,2)*n(1)+C(1,2,2,2)*n(2)+C(1,3,2,2)*n(3)  C(1,1,2,3)*n(1)+C(1,2,2,3)*n(2)+C(1,3,2,3)*n(3)  C(1,1,1,3)*n(1)+C(1,2,1,3)*n(2)+C(1,3,1,3)*n(3)      C(1,1,2,3)*n(1)+C(1,2,2,3)*n(2)+C(1,3,2,3)*n(3) C(1,1,3,3)*n(1)+C(1,2,3,3)*n(2)+C(1,3,3,3)*n(3)]/1e11;
        A6=[ C(2,1,1,1)*n(1)+C(2,2,1,1)*n(2)+C(2,3,1,1)*n(3) C(2,1,1,2)*n(1)+C(2,2,1,2)*n(2)+C(2,3,1,2)*n(3)    C(2,1,1,3)*n(1)+C(2,2,1,3)*n(2)+C(2,3,1,3)*n(3) C(2,1,1,2)*n(1)+C(2,2,1,2)*n(2)+C(2,3,1,2)*n(3) C(2,1,2,2)*n(1)+C(2,2,2,2)*n(2)+C(2,3,2,2)*n(3)  C(2,1,2,3)*n(1)+C(2,2,2,3)*n(2)+C(2,3,2,3)*n(3)  C(2,1,1,3)*n(1)+C(2,2,1,3)*n(2)+C(2,3,1,3)*n(3)      C(2,1,2,3)*n(1)+C(2,2,2,3)*n(2)+C(2,3,2,3)*n(3) C(2,1,3,3)*n(1)+C(2,2,3,3)*n(2)+C(2,3,3,3)*n(3)]/1e11;
        A7=[ C(3,1,1,1)*n(1)+C(3,2,1,1)*n(2)+C(3,3,1,1)*n(3) C(3,1,1,2)*n(1)+C(3,2,1,2)*n(2)+C(3,3,1,2)*n(3)    C(3,1,1,3)*n(1)+C(3,2,1,3)*n(2)+C(3,3,1,3)*n(3) C(3,1,1,2)*n(1)+C(3,2,1,2)*n(2)+C(3,3,1,2)*n(3) C(3,1,2,2)*n(1)+C(3,2,2,2)*n(2)+C(3,3,2,2)*n(3)  C(3,1,2,3)*n(1)+C(3,2,2,3)*n(2)+C(3,3,2,3)*n(3)  C(3,1,1,3)*n(1)+C(3,2,1,3)*n(2)+C(3,3,1,3)*n(3)      C(3,1,2,3)*n(1)+C(3,2,2,3)*n(2)+C(3,3,2,3)*n(3) C(3,1,3,3)*n(1)+C(3,2,3,3)*n(2)+C(3,3,3,3)*n(3)]/1e11;
        
        % Colin's equations
        % variables:        a11             a12                 a13             a21             a22             a23             a31                 a32                 a33
        A1=[        r1.*rp1.*rp1-r1   r2.*rp1.*rp1-r2   r3.*rp1.*rp1-r3     r1.*rp2.*rp1    r2.*rp2.*rp1     r3.*rp2.*rp1     r1.*rp3.*rp1      r2.*rp3.*rp1        r3.*rp3.*rp1 ];
        % variables:        a11             a12                 a13             a21             a22             a23             a31                  a32                 a33
        A2=[        r1.*rp1.*rp2      r2.*rp1.*rp2      r3.*rp1.*rp2        r1.*rp2.*rp2-r1 r2.*rp2.*rp2-r2  r3.*rp2.*rp2-r3  r1.*rp3.*rp2      r2.*rp3.*rp2        r3.*rp3.*rp2 ];
        % variables:        a11             a12                 a13             a21             a22             a23             a31                  a32                 a33
        A3=[        r1.*rp1.*rp3      r2.*rp1.*rp3      r3.*rp1.*rp3        r1.*rp2.*rp3    r2.*rp2.*rp3     r3.*rp2.*rp3     r1.*rp3.*rp3-r1   r2.*rp3.*rp3-r2     r3.*rp3.*rp3-r3 ];
        
        
        %answers
        b1=-q1-(q1.*rp1+q2.*rp2+q3.*rp3).*rp1;
        b2=-q2-(q1.*rp1+q2.*rp2+q3.*rp3).*rp2;
        b3=-q3-(q1.*rp1+q2.*rp2+q3.*rp3).*rp3;
        b5=0;
        b6=0;
        b7=0;
        b4 = [b1;b2;b3;b5;b6;b7];
        A4 = [A1;A2;A3;A5;A6;A7];
        
        % Using only the last of the traction free conditions (see
        % Wilkinson methods above): **********************
%         b4 = [b1;b2;b3;b7];
%         A4 = [A1;A2;A3;A7];
        
        %solve for variables
        X3=A4\b4;
        %variables
        U11=X3(1);
        U12=X3(2);
        U13=X3(3);
        U21=X3(4);
        U22=X3(5);
        U23=X3(6);
        U31=X3(7);
        U32=X3(8);
        U33=X3(9);
        %This U is in the crystal frame
        U= [U11 U12 U13;...
            U21 U22 U23;...
            U31 U32 U33];
        F=U+eye(3);
        
        [cx cy]=Theoretical_Pixel_Shift(Qsc,xstar,ystar,zstar,roixc,roiyc,F,Settings.PixelSize,alpha);
        SSE=sqrt(sum((cx(tempind)-Cshift(tempind)).^2+(cy(tempind)-Rshift(tempind)).^2)/length(tempind)) ;
        %         Fs{6}=F;
        %         SSEs(6)=SSE;
        %         n=(g*[0;0;1])'*inv(Fo)/norm((g*[0;0;1])'*inv(Fo));
        %         C=Cc;
        % vars:                          a11                                        a12                                                     a13                                      a21                                 a22                                                           a23                                     a31                                                                a32                                 a33
        %         Aa=[ C(1,1,1,1)*n(1)+C(1,2,1,1)*n(2)+C(1,3,1,1)*n(3) C(1,1,1,2)*n(1)+C(1,2,1,2)*n(2)+C(1,3,1,2)*n(3)    C(1,1,1,3)*n(1)+C(1,2,1,3)*n(2)+C(1,3,1,3)*n(3) C(1,1,1,2)*n(1)+C(1,2,1,2)*n(2)+C(1,3,1,2)*n(3) C(1,1,2,2)*n(1)+C(1,2,2,2)*n(2)+C(1,3,2,2)*n(3)  C(1,1,2,3)*n(1)+C(1,2,2,3)*n(2)+C(1,3,2,3)*n(3)  C(1,1,1,3)*n(1)+C(1,2,1,3)*n(2)+C(1,3,1,3)*n(3)      C(1,1,2,3)*n(1)+C(1,2,2,3)*n(2)+C(1,3,2,3)*n(3) C(1,1,3,3)*n(1)+C(1,2,3,3)*n(2)+C(1,3,3,3)*n(3)];
        %         Ab=[ C(2,1,1,1)*n(1)+C(2,2,1,1)*n(2)+C(2,3,1,1)*n(3) C(2,1,1,2)*n(1)+C(2,2,1,2)*n(2)+C(2,3,1,2)*n(3)    C(2,1,1,3)*n(1)+C(2,2,1,3)*n(2)+C(2,3,1,3)*n(3) C(2,1,1,2)*n(1)+C(2,2,1,2)*n(2)+C(2,3,1,2)*n(3) C(2,1,2,2)*n(1)+C(2,2,2,2)*n(2)+C(2,3,2,2)*n(3)  C(2,1,2,3)*n(1)+C(2,2,2,3)*n(2)+C(2,3,2,3)*n(3)  C(2,1,1,3)*n(1)+C(2,2,1,3)*n(2)+C(2,3,1,3)*n(3)      C(2,1,2,3)*n(1)+C(2,2,2,3)*n(2)+C(2,3,2,3)*n(3) C(2,1,3,3)*n(1)+C(2,2,3,3)*n(2)+C(2,3,3,3)*n(3)];
        %         Ac=[ C(3,1,1,1)*n(1)+C(3,2,1,1)*n(2)+C(3,3,1,1)*n(3) C(3,1,1,2)*n(1)+C(3,2,1,2)*n(2)+C(3,3,1,2)*n(3)    C(3,1,1,3)*n(1)+C(3,2,1,3)*n(2)+C(3,3,1,3)*n(3) C(3,1,1,2)*n(1)+C(3,2,1,2)*n(2)+C(3,3,1,2)*n(3) C(3,1,2,2)*n(1)+C(3,2,2,2)*n(2)+C(3,3,2,2)*n(3)  C(3,1,2,3)*n(1)+C(3,2,2,3)*n(2)+C(3,3,2,3)*n(3)  C(3,1,1,3)*n(1)+C(3,2,1,3)*n(2)+C(3,3,1,3)*n(3)      C(3,1,2,3)*n(1)+C(3,2,2,3)*n(2)+C(3,3,2,3)*n(3) C(3,1,3,3)*n(1)+C(3,2,3,3)*n(2)+C(3,3,3,3)*n(3)];
        %         BCerr=[Aa;Ab;Ac]*[F(1,1)-1;F(1,2);F(1,3);F(2,1);F(2,2)-1;F(2,3);F(3,1);F(3,2);F(3,3)-1];
        %         BCerr=sqrt(sum(BCerr.^2));
        %         BCerrs(6)=BCerr; %end of method 6
        %         F={};
        
        
        
end



%% for visualizing process
if Settings.DoShowPlot
    try
        set(0,'currentfigure',100);
    catch
        figure(100);
    end
    [cx cy]=Theoretical_Pixel_Shift(Qsc,xstar,ystar,zstar,roixc,roiyc,F,Settings.PixelSize,alpha);
    cla
    imagesc(RefImage);
    axis image
    colormap gray
    hold on
    for i=1:length(Cshift)
        if ~isempty(find(tempind==i))
            %Should probably make this factor "*10" a variable...
            plot([roixc(i) roixc(i)+Cshift(i)],[roiyc(i) roiyc(i)+Rshift(i)],'g.-')
        else
            plot([roixc(i) roixc(i)+Cshift(i)],[roiyc(i) roiyc(i)+Rshift(i)],'r.-')
        end
        plot([roixc(i) roixc(i)+cx(i)],[roiyc(i) roiyc(i)+cy(i)],'b.-')
    end
    drawnow
    text = get(gca,'title');
    if ~isempty(text.String)
        [num,iter] = strtok(text.String(6:end));
        num = str2num(num);
        iter = str2num(iter);
        if num == Ind
            iter = iter + 1;
        else
            iter = 1;
        end
    else
        iter = 1;
    end
    title(['Image ' num2str(Ind) ' (' num2str(iter) ')'])
    
    try
        set(0,'currentfigure',101);
    catch
        figure(101);
    end
    [cx cy]=Theoretical_Pixel_Shift(Qsc,xstar,ystar,zstar,roixc,roiyc,F,Settings.PixelSize,alpha);
    cla
    imagesc(ScanImage);
    axis image
    colormap gray
    hold on
    for i=1:length(Cshift)
        if ~isempty(find(tempind==i))
            %Should probably make this factor "*10" a variable...
            plot([roixc(i) roixc(i)+Cshift(i)],[roiyc(i) roiyc(i)+Rshift(i)],'g.-')
        else
            plot([roixc(i) roixc(i)+Cshift(i)],[roiyc(i) roiyc(i)+Rshift(i)],'r.-')
        end
        plot([roixc(i) roixc(i)+cx(i)],[roiyc(i) roiyc(i)+cy(i)],'b.-')
    end
    drawnow
    title(['Image ' num2str(Ind) ' (' num2str(iter) ')'])
    U
    SSE
% keyboard
%     save shifts Rshift Cshift cx cy
    return
    
end

