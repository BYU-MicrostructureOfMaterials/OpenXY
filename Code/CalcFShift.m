function [F, SSE, XX, sigma] = CalcFShift(RefImage,ScanImage,g,Fo,Ind,Settings,curMaterial,RefInd,PC)
%% handle inputs

if size(RefImage)~=size(ScanImage)
    RefImage=ScanImage;
    disp('No Ref Image')
end

Material = ReadMaterial(curMaterial);
% g0 = g;
RefImage=double(RefImage);
ScanImage=double(ScanImage);

roixc = Settings.roixc;
roiyc = Settings.roiyc;
if nargin < 9
    if RefInd~=0
        xstar = Settings.XStar(RefInd);
        ystar = Settings.YStar(RefInd);
        zstar = Settings.ZStar(RefInd);
    else
        xstar = Settings.XStar(Ind);
        ystar = Settings.YStar(Ind);
        zstar = Settings.ZStar(Ind);
    end
else
    xstar=PC(1);
    ystar=PC(2);
    zstar=PC(3);
end
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
    if Settings.ROIFilter(3)==1
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
[~,U]=poldec(Qsc);
if sum(sum(U-eye(3)))>1e-6
    error('g must be a pure rotation');
end
Qcs=Qsc';
if sum(sum(Qsc*Qcs-eye(3)))>1e-6 %Changed by BEJ June 2016 to account for single precision orientations
    error('the orientation matrix has issues')
end

Qvp=[-1 0 0; 0 -1 0; 0 0 1];

% Phospher to sample
Qps = frameTransforms.phosphorToSample(Settings);
Qsp=Qps';


%% Preallocate for loop
q = zeros(3,length(roixc));
r = q;
Rshift = zeros(1,length(roixc));
Cshift = zeros(1,length(roixc));
dRshift = zeros(1,length(roixc));
dCshift = zeros(1,length(roixc));
XX = zeros(length(roixc),3);

% Go over each ROI
for i=1:length(roixc)
%%  Using cross correlations to determine the shifts
    rc=roiyc(i);
    cc=roixc(i);
    
    thisr = Qvp*[cc;rc;0]/Settings.PixelSize + [xstar;1-ystar;-zstar]; 
    
    rrange=round(rc-Settings.ROISize/2):round(rc-Settings.ROISize/2)+Settings.ROISize-1;
    crange=round(cc-Settings.ROISize/2):round(cc-Settings.ROISize/2)+Settings.ROISize-1;
    RefROI = RefImage(rrange,crange);
    
    if RefInd~=0
%         clear global rs cs Gs
%         [~, dxshiftclassic, dyshiftclassic] = custfftxc((RefROI),...
%         (ScanImage(rrange,crange)),0,RefImage,rc,cc,custfilt,windowfunc);
    
        ddratio = Settings.ZStar(RefInd)/Settings.ZStar(Ind);
        tx=(Settings.XStar(Ind)-Settings.XStar(RefInd));
        ty=(Settings.YStar(Ind)-Settings.YStar(RefInd));
        tz=(Settings.ZStar(Ind)-Settings.ZStar(RefInd));
        t = [-tx;ty;tz];
        shiftedx = -[xstar;1-ystar;-zstar] + t + thisr/ddratio;
        shiftedxp = Qvp'*shiftedx*Settings.PixelSize;
%         shiftedxp = Qvp'*[t(1) t(2) 0]'*Settings.PixelSize + [cc;rc;0];
%         shiftedxp = [dxshiftclassic dyshiftclassic 0]' + [cc;rc;0];
        
        qbest = shiftedxp - [cc;rc;0];
        
        srrange=round(shiftedxp(2)-Settings.ROISize/2):round(shiftedxp(2)-Settings.ROISize/2)+Settings.ROISize-1;
        scrange=round(shiftedxp(1)-Settings.ROISize/2):round(shiftedxp(1)-Settings.ROISize/2)+Settings.ROISize-1;
        
%         mean(scrange) - mean(crange)
%         mean(srrange) - mean(rrange)

        try
            ScanROI = ScanImage(srrange,scrange); %Lets you go off the image!
        catch ME
%             keyboard
            continue
        end
    else
        ScanROI = ScanImage(rrange,crange);  %Also lets you go off the image...not our fault
    end    
    
    %Perform Cross-Correlation
%     clear global rs cs Gs
    [rimage, dxshift, dyshift] = custfftxc((RefROI),...
        (ScanROI),rc,cc,custfilt,windowfunc);%this is the screen shift in the F(i-1) frame
    
    
    RefROI = RefROI - mean(RefROI(:));
    ScanROI = ScanROI - mean(ScanROI(:));
    
    if RefInd~=0
        dxshift = dxshift + mean(scrange) - mean(crange);
        dyshift = dyshift + mean(srrange) - mean(rrange);
        
%         dxs(i) = dxshift;
%         dys(i) = dyshift;
%         dxid(i) = qbest(1);
%         dyid(i) = qbest(2);
%         dxcs(i) = dxshiftclassic;
%         dycs(i) = dyshiftclassic;
    end
    
    if nargout >= 3
        %Calculate Cross-Correlation Coefficient
        XX(i,1) = CalcCrossCorrelationCoef(RefROI,ScanROI);
        
        
        %Calculate Confidence of Shift
        XX(i,2) = (max(rimage(:))-mean(rimage(:)))/std(rimage(:));
        
        %Calculate Mutual Information (Requires Image Processing Toolbox)
        if isfield(Settings,'CalcMI') && Settings.CalcMI
            XX(i,3) = CalcMutualInformation(RefROI,ScanROI);
        else
            XX(i,3) = 0;
        end
    end
    
    thisq = Qvp*[dxshift; dyshift;0]/Settings.PixelSize; 
    
    if RefInd~=0
        thisq = (thisq - t)*ddratio - thisr*(1-ddratio);        
        dxshift = -thisq(1)*Settings.PixelSize;
        dyshift = -thisq(2)*Settings.PixelSize;
    end
   
    
    q(:,i) = thisq/norm(thisr);
    r(:,i) = thisr/norm(thisr);
    Rshift(i)=dyshift;
    Cshift(i)=dxshift;
    dRshift(i)=dyshift;
    dCshift(i)=dxshift;
    
    
end


%% Remove bad regions
stdevR=std(dRshift);
mR=mean(dRshift);
stdevC=std(dCshift);
mC=mean(dCshift);
if stdevR~=0 && stdevC~=0
    tempind=find(abs(dRshift)<129&abs(dCshift)<129&abs(dRshift-mR)<standev*stdevR&abs(dCshift-mC)<standev*stdevC);
    
    q=(q(:,tempind));
    r=(r(:,tempind));
    
    if length(tempind)<4
        F=eye(3);
        SSE=0;
        disp('Too few good ROI''s');
        return
    end
else
    tempind=1:length(dRshift);
end

%% Create stiffness matrix


if strcmp(Material.lattice,'cubic') || strcmp(Material.lattice,'tetragonal')
    C1111=Material.C11*1e9;
    C2323=Material.C44*1e9;
    C1122=Material.C12*1e9;
    delta=eye(3);
    %Transform to the crystal apply stress normal to surface is zero
    Cs=zeros(3,3,3,3);
    Cc=zeros(3,3,3,3);

    g=Qsp*Qcs;
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


sigma = zeros(3,3);

        
%% Calc F
        
r1=r(1,:)';
r2=r(2,:)';
r3=r(3,:)';

q1=q(1,:)';
q2=q(2,:)';

zerovec = zeros(size(r1));

A1 = [r1.*r3 r2.*r3 r3.*r3 zerovec zerovec zerovec -(r1.*r1 + q1.*r1) -(r1.*r2 + q1.*r2) -(r1.*r3 + q1.*r3)];
A2 = [zerovec zerovec zerovec r1.*r3 r2.*r3 r3.*r3 -(r2.*r1 + q2.*r1) -(r2.*r2 + q2.*r2) -(r2.*r3 + q2.*r3)];

b1 = q1.*r3;
b2 = q2.*r3;


% if RefInd==0
%     n = Qps'*[0;0;1];
%     C=Cs;
%     A5=[ C(1,1,1,1)*n(1)+C(1,2,1,1)*n(2)+C(1,3,1,1)*n(3) C(1,1,1,2)*n(1)+C(1,2,1,2)*n(2)+C(1,3,1,2)*n(3)    C(1,1,1,3)*n(1)+C(1,2,1,3)*n(2)+C(1,3,1,3)*n(3) C(1,1,1,2)*n(1)+C(1,2,1,2)*n(2)+C(1,3,1,2)*n(3) C(1,1,2,2)*n(1)+C(1,2,2,2)*n(2)+C(1,3,2,2)*n(3)  C(1,1,2,3)*n(1)+C(1,2,2,3)*n(2)+C(1,3,2,3)*n(3)  C(1,1,1,3)*n(1)+C(1,2,1,3)*n(2)+C(1,3,1,3)*n(3)      C(1,1,2,3)*n(1)+C(1,2,2,3)*n(2)+C(1,3,2,3)*n(3) C(1,1,3,3)*n(1)+C(1,2,3,3)*n(2)+C(1,3,3,3)*n(3)]/1e11;
%     A6=[ C(2,1,1,1)*n(1)+C(2,2,1,1)*n(2)+C(2,3,1,1)*n(3) C(2,1,1,2)*n(1)+C(2,2,1,2)*n(2)+C(2,3,1,2)*n(3)    C(2,1,1,3)*n(1)+C(2,2,1,3)*n(2)+C(2,3,1,3)*n(3) C(2,1,1,2)*n(1)+C(2,2,1,2)*n(2)+C(2,3,1,2)*n(3) C(2,1,2,2)*n(1)+C(2,2,2,2)*n(2)+C(2,3,2,2)*n(3)  C(2,1,2,3)*n(1)+C(2,2,2,3)*n(2)+C(2,3,2,3)*n(3)  C(2,1,1,3)*n(1)+C(2,2,1,3)*n(2)+C(2,3,1,3)*n(3)      C(2,1,2,3)*n(1)+C(2,2,2,3)*n(2)+C(2,3,2,3)*n(3) C(2,1,3,3)*n(1)+C(2,2,3,3)*n(2)+C(2,3,3,3)*n(3)]/1e11;
%     A7=[ C(3,1,1,1)*n(1)+C(3,2,1,1)*n(2)+C(3,3,1,1)*n(3) C(3,1,1,2)*n(1)+C(3,2,1,2)*n(2)+C(3,3,1,2)*n(3)    C(3,1,1,3)*n(1)+C(3,2,1,3)*n(2)+C(3,3,1,3)*n(3) C(3,1,1,2)*n(1)+C(3,2,1,2)*n(2)+C(3,3,1,2)*n(3) C(3,1,2,2)*n(1)+C(3,2,2,2)*n(2)+C(3,3,2,2)*n(3)  C(3,1,2,3)*n(1)+C(3,2,2,3)*n(2)+C(3,3,2,3)*n(3)  C(3,1,1,3)*n(1)+C(3,2,1,3)*n(2)+C(3,3,1,3)*n(3)      C(3,1,2,3)*n(1)+C(3,2,2,3)*n(2)+C(3,3,2,3)*n(3) C(3,1,3,3)*n(1)+C(3,2,3,3)*n(2)+C(3,3,3,3)*n(3)]/1e11;
% 
%     b5=0;
%     b6=0;
%     b7=0;
%     b4 = [b1;b2;b5;b6;b7];
%     A4 = [A1;A2;A5;A6;A7];
% else
    b7 = 0;
    A7=[1 0 0 0 1 0 0 0 1];
    b4 = [b1;b2;b7];
    A4 = [A1;A2;A7];
%     
% end


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

Qpc = Qsc*Qps;

F = Qpc*F*Qpc';

[cx,cy]=Theoretical_Pixel_Shift(Qsc,xstar,ystar,zstar,roixc,roiyc,F,Settings.PixelSize,alpha);
SSE=sqrt(sum((cx(tempind)-Cshift(tempind)).^2+(cy(tempind)-Rshift(tempind)).^2)/length(tempind)) ;

%Calculate Stress - BEJ Jan 2017
if nargout == 4
    [~,Ustrain] = poldec(F);
    Ustrain = Ustrain-eye(3);
    for m = 1:3
        for n = 1:3
            for o = 1:3
                for p = 1:3
                    sigma(m,n) = sigma(m,n)+Cc(m,n,o,p)*Ustrain(o,p);
                end
            end
        end
    end
else
    Ustrain = 0;
end
assignin('base','Cc_CalcF',Cc)
assignin('base','Ustrain',Ustrain)



%% for visualizing process
if Settings.DoShowPlot
    sf = 1;
    DoPlotROIs = 0;
    try
        set(0,'currentfigure',100);
    catch
        figure(100);
    end
    [cx,cy]=Theoretical_Pixel_Shift(Qsc,xstar,ystar,zstar,roixc,roiyc,F,Settings.PixelSize,alpha);
    cla
    imagesc(RefImage);
    axis image
    colormap gray
    hold on
    if DoPlotROIs
        set(0,'currentfigure',100);
        PlotROIs(Settings,RefImage);
    end
    for i=1:length(Cshift)
        if ~isempty(find(tempind==i, 1))
            %Should probably make this factor "*10" a variable...
            plot([roixc(i) roixc(i)+sf*Cshift(i)],[roiyc(i) roiyc(i)+sf*Rshift(i)],'g.-')
        else
            plot([roixc(i) roixc(i)+sf*Cshift(i)],[roiyc(i) roiyc(i)+sf*Rshift(i)],'r.-')
        end
%         plot([roixc(i) roixc(i)+sf*cx(i)],[roiyc(i) roiyc(i)+sf*cy(i)],'b.-')
        plot(roixc(i),roiyc(i),'y.')
    end
    drawnow
    try
        set(0,'currentfigure',101);
    catch
        figure(101);
    end
    text = get(gca,'title');
    if ~isempty(text.String)
        [num,iter] = strtok(text.String{2}(6:end));
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
    set(0,'currentfigure',100);
    if RefInd~=0
        title({'Reference Image';['Image ' num2str(RefInd) ' (' num2str(iter) ')']})
    else
        title({'Simulated Reference Image';[' (' num2str(iter) ')']})
    end
    
    set(0,'currentfigure',101);
    [cx,cy]=Theoretical_Pixel_Shift(Qsc,xstar,ystar,zstar,roixc,roiyc,F,Settings.PixelSize,alpha);
    cla
    imagesc(ScanImage);
    axis image
    colormap gray
    hold on
    if DoPlotROIs
        set(0,'currentfigure',101);
        PlotROIs(Settings,RefImage);
    end
    for i=1:length(Cshift)
        if ~isempty(find(tempind==i, 1))
            %Should probably make this factor "*10" a variable...
            plot([roixc(i) roixc(i)+sf*Cshift(i)],[roiyc(i) roiyc(i)+sf*Rshift(i)],'g.-')
        else
            plot([roixc(i) roixc(i)+sf*Cshift(i)],[roiyc(i) roiyc(i)+sf*Rshift(i)],'r.-')
        end
        plot([roixc(i) roixc(i)+sf*cx(i)],[roiyc(i) roiyc(i)+sf*cy(i)],'b.-')
    end
    drawnow
    title({'Experimental Image';['Image ' num2str(Ind) ' (' num2str(iter) ')']})
    U
    SSE
    
    
    
%     figure
%     plot3(dxid,dyid,dxs-dxid,'.')
%     figure
%     plot3(dxid,dyid,dys-dyid,'.')
%     figure
%     plot3(dxid,dyid,dxcs-dxid,'.')
%     figure
%     plot3(dxid,dyid,dycs-dyid,'.')
% keyboard
%     save shifts Rshift Cshift cx cy
    return
    
end
