function PlotBurgersVector(Settings, alpha_data)
% Copyright 2021 National Technology & Engineering Solutions of Sandia, LLC (NTESS).
% Under the terms of Contract DE-NA0003525 with NTESS, the U.S. Government retains certain rights in this software.
% Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files
% (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge,
% publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do
% so, subject to the following conditions:
% The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
% OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
% LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
% IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

% See Ruggles TJ, Deitz JI, Allerman AA, Carter CB, Michael JR (2021)
% Identification of Star Defects in Gallium Nitride with HREBSD and ECCI. Microsc
% Microanal 27, 257–265. doi:10.1017/S143192762100009X

% clc
% clear
% close all


IQ = reshape(Settings.IQ(Settings.Inds),Settings.Nx,Settings.Ny)';
CI = reshape(Settings.CI(Settings.Inds),Settings.Nx,Settings.Ny)';
gid = reshape(Settings.grainID(Settings.Inds),Settings.Nx,Settings.Ny)';
a3=reshape(alpha_data.alpha_total3,Settings.Nx,Settings.Ny)';

% burg = 287 * 1e-12;
% burg=3.3026e-10; % Tantalum
burg=reshape(alpha_data.b(Settings.Inds),Settings.Nx,Settings.Ny)';
grains=reshape(Settings.grainID,Settings.Nx,Settings.Ny)';
[nx,ny]=size(grains);
BOUND=zeros(nx,ny);
temp1=abs(circshift(grains,[-1,0])-circshift(grains,[1,0])); % look for any points within 2 steps of GB
temp1(1,:)=0;
temp1(end,:)=0;
temp2=abs(circshift(grains,[0,-1])-circshift(grains,[0,1]));
temp2(:,1)=0;
temp2(:,end)=0;
BOUND(temp1+temp2>0.01)=1;

for i=1:3
    for j=1:3
        elabels{i,j} = ['\epsilon_{' num2str(i) num2str(j) '}'];
    end
end

for i=1:3
    for j=1:3
        wlabels{i,j} = ['\omega_{' num2str(i) num2str(j) '}'];
    end
end

for i=1:3
    for j=1:3
        blabels{i,j} = ['\beta_{' num2str(i) num2str(j) '}'];
    end
end

for i=1:3
    for j=1:3
        slabels{i,j} = ['\sigma_{' num2str(i) num2str(j) '}'];
    end
end

for i=1:3
    for j=1:3
        alabels{i,j} = ['\alpha_{' num2str(i) num2str(j) '}'];
    end
end

if isfield(Settings,'camphi1')
    Qmp = euler2gmat(Settings.camphi1,Settings.camPHI,Settings.camphi2);
    Qmi = [0 -1 0;1 0 0;0 0 1];
    sampletilt = Settings.SampleTilt;
    Qio = [
        cos(sampletilt) 0 -sin(sampletilt)
        0 1 0;sin(sampletilt) 0 cos(sampletilt)
        ];
    Qpo = Qio*Qmi*Qmp'*[-1 0 0;0 1 0;0 0 -1];
    
    Qps = Qpo;
else
    alphaRotation=pi/2-Settings.SampleTilt+Settings.CameraElevation;
    Qps=[0 -cos(alphaRotation) -sin(alphaRotation);...
        -1     0            0;...
        0   sin(alphaRotation) -cos(alphaRotation)];
end

B = tensorvector2map(Settings.data.F, Settings.Ny, Settings.Nx) - eyefield(3,Settings.Ny, Settings.Nx);
sigma = tensorvector2map(Settings.data.sigma, Settings.Ny, Settings.Nx);
g = tensorvector2map(euler2gmat(Settings.NewAngles), Settings.Ny, Settings.Nx);
g_ctos = permute(g,[2,1,3,4]);

E = (B + permute(B,[2,1,3,4]))/2;
W = (B - permute(B,[2,1,3,4]))/2;

B_s = rotatetensorfield(B,g_ctos);
B_p = rotatetensorfield(B_s, Qps');

mpsettings.labels = blabels;
mpsettings.clims = [-.005 .005];
mpsettings.cmap = 'jet';

esettings.labels = elabels;
esettings.clims = 1e6*[-.005 .005];
esettings.cmap = 'jet';
E_s = .5*(B_s + permute(B_s,[2,1,3,4]));
E_p = .5*(B_p + permute(B_p,[2,1,3,4]));


if exist('alpha_data') && isfield(alpha_data, 'Fa')
    Ba = tensorvector2map(alpha_data.Fa, Settings.Ny, Settings.Nx);
    Bc = tensorvector2map(alpha_data.Fc, Settings.Ny, Settings.Nx);

    Ba = Ba - eyefield(3,Settings.Ny, Settings.Nx);
    Bc = -(Bc - eyefield(3,Settings.Ny, Settings.Nx));

    Ba_p = rotatetensorfield(Ba, Qps');
    Bc_p = rotatetensorfield(Bc, Qps');

else
    disp('No derivatives found, calculating instead...')
    [Ba, Bc] = calcBderivs(B_s);

    Ba_p = rotatetensorfield(Ba, Qps');
    Bc_p = rotatetensorfield(Bc, Qps');


end


Ba_p_fix  = Ba_p;
Ba_p_fix(3,1,:,:) = -Ba_p_fix(1,3,:,:);
Ba_p_fix(3,2,:,:) = -Ba_p_fix(2,3,:,:);

Bc_p_fix  = Bc_p;
Bc_p_fix(3,1,:,:) = -Bc_p_fix(1,3,:,:);
Bc_p_fix(3,2,:,:) = -Bc_p_fix(2,3,:,:);

Ba_fix = rotatetensorfield(Ba_p_fix,Qps);
Bc_fix = rotatetensorfield(Bc_p_fix,Qps);

Ba_fix_r = (Ba_fix - permute(Ba_fix,[2,1,3,4]))/2;
Bc_fix_r = (Bc_fix - permute(Bc_fix,[2,1,3,4]))/2;

kernel = fspecial('gaussian',5,.8);

Ba_fix_smooth = smearmat(Ba_fix,kernel);
Bc_fix_smooth = smearmat(Bc_fix,kernel);

% alpha = partialcurl(Ba_fix_smooth/(Settings.XData(2)*1e-6),Bc_fix_smooth/(Settings.XData(2)*1e-6)); % *** smoothed ***
alpha = partialcurl(Ba_fix/(Settings.XData(2)*1e-6),Bc_fix_smooth/(Settings.XData(2)*1e-6)); % *** unsmoothed ***

% delete boundary points
alpha(:,BOUND==1)=0;

% triplemask = zeros(Settings.data.rows,Settings.data.cols);
% thresh = 40;
% for i=2:Settings.data.rows-1
%     for j=2:Settings.data.cols-1
%         if IQ(i,j)>thresh && IQ(i-1,j)>40 && IQ(i,j+1)>40
%             triplemask(i,j) = 1;
%         end
%     end
% end
% 
% gidmask = zeros(Settings.data.rows,Settings.data.cols);
% thresh = 75;
% for i=2:Settings.data.rows-1
%     for j=2:Settings.data.cols-1
%         if (CI(i,j))>thresh && (gid(i-1,j)==gid(i,j)) && (gid(i,j+1)==gid(i,j))
%             gidmask(i,j) = 1;
%         end
%     end
% end


alphasum = squeeze(sum(abs(alpha),1));
% alphasum(gidmask==0) = 1;
alphasum(IQ<100) = 0/0;
% figure; imagesc(log10(alphasum(:,:)./burg)); axis image; colormap('jet'); caxis([13 15])
figure; imagesc(log10(a3)); axis image; colormap('jet'); caxis([13 15])
title('Dislocation Density')
% hold on

alphatensor = zeros(size(Ba_fix_smooth));
alphatensor(1,3,:,:) = alpha(1,:,:);
alphatensor(2,3,:,:) = alpha(2,:,:);
alphatensor(3,3,:,:) = alpha(3,:,:);
alphatensor(1,2,:,:) = alpha(4,:,:);
alphatensor(2,1,:,:) = alpha(5,:,:);
alphatensor(1,1,:,:) = alpha(6,:,:);

alphasettings = mpsettings;
alphasettings.labels = alabels;
alphasettings.clims = [-50000 50000];

 
[b,l, bhat, rhob, ik] = blmap2(alpha);

% figure; imagesc(log10((ik))); axis image; colormap('jet'); caxis([-6 -4])
normb = squeeze(sqrt(b(1,:,:).^2 + b(2,:,:).^2 + b(3,:,:).^2));
normb(isnan(normb))=0;
norml = squeeze(sqrt(l(1,:,:).^2 + l(2,:,:).^2 + l(3,:,:).^2));
norml(isnan(norml))=0;

b1=squeeze(b(1,:,:)); %for plotting
b2=squeeze(b(2,:,:));
meanb=mean(normb(:));
cutoff=6*meanb;
b1(normb<cutoff/8)=0;
b2(normb<cutoff/8)=0;
b1(normb>cutoff)=0;
b2(normb>cutoff)=0;

Xq = 1:Settings.Nx;
Yq = 1:Settings.Ny;
%[Xq,Yq] = meshgrid(1:1:121);
mp=size(b1)
o1 = mp(1);
p1 = mp(2);

if o1>=120
m1=round(o1/24);
elseif o1>=100 && o1<120
m1=4;
elseif o1>=80 && o1<100
m1=3;
elseif o1>=60 && o1<80
m1=2
else
m1=1
end

if p1>=120
n1=round(p1/24);
elseif p1>=100 && p1<120
n1=4;
elseif p1>=80 && p1<100
n1=3;
elseif p1>=60 && p1<80
n1=2
else
n1=1
end

f = @(D,m1,n1) blockproc(D,[m1 n1],@(block_struct) mean(block_struct.data,'all'));
Xd = f(Xq,m1,n1);
Yd = f(Yq,m1,n1);
Ud = f(-b1,m1,n1);
Vd = f(-b2,m1,n1);
[Ud1,TF,L,U,C] = filloutliers(Ud,"center");
[Vd1,TF,L,U,C] = filloutliers(Vd,"center");
% Plot dislocation density and quiver map of Burgers directions
figure; imagesc(log10((rhob./burg))); axis image; colormap('jet'); caxis([12 15])
hold on
quiver(-b1,-b2,'color',[1 1 1], 'AutoScale','on',AutoScaleFactor=4/3) % negative in order to go from Euler reference frame to Imagesc plotting frame
quiver(Xd,Yd,Ud1,Vd1,'color',[1 1 1], 'linewidth', m1/3, 'AutoScale','on',AutoScaleFactor=4/3) % negative in order to go from Euler reference frame to Imagesc plotting frame
title('Log10 of Dislocation density, and projected net Burgers vector')

cl = rotatevectorfield(l,g); %in crystal frame
cb = rotatevectorfield(b,g);

cbhat = rotatevectorfield(bhat,g);



%alternative GND plot
% figure
% imagesc(log10(a3))
% hold on
% quiver(-b1,-b2,'color',[1 0 0])% negative in order to go from Euler reference frame to Imagesc plotting frame

%**************TEMP*********
% %Just plot alpha(1,3) amd alpha(2,3) as WBV
% figure
% imagesc(log10(a3))
% hold on
% quiver(squeeze(alpha(1,:,:)),squeeze(alpha(2,:,:)),'color',[1 0 0])
% 
% % Compare with OpenXY orientation:
% alphaXY = partialcurl(-Bc_fix_smooth/(Settings.XData(2)*1e-6),-Ba_fix_smooth/(Settings.XData(2)*1e-6));
% figure
% imagesc(log10(a3))
% hold on
% quiver(squeeze(alphaXY(1,:,:)),squeeze(alphaXY(2,:,:)),'color',[1 0 0])
% 
% % Compare with OpenXY orientation but don't smooth it
% alphaXY = partialcurl(-Bc_fix/(Settings.XData(2)*1e-6),-Ba_fix/(Settings.XData(2)*1e-6));
% figure
% imagesc(log10(a3))
% hold on
% quiver(squeeze(alphaXY(1,:,:)),squeeze(alphaXY(2,:,:)),'color',[1 0 0])

% Find crystalographic directions of b
% cd('/Users/fullwood/Documents/GitHub/OpenXY/Code/')
symops=permute(gensymops, [2, 3, 1]); % I would not need to permute these if I removed the permute in StereoDir.m for the symops
% cd('/Users/fullwood/Dropbox/SyncFolder/Current Students/Grads/Landon Hansen/Polycrystal Paper/ViewData/')
% cd('/Users/fullwood/Dropbox/SyncFolder/Collaborators/Tim Ruggles')
% get the direction (in the crystal frame) that is in the correct FZ of the
% sphere

n = Settings.Nx;
m = Settings.Ny;
SD=zeros(n*m,3);
f=waitbar(0,'working');
count=0;
for j=1:n
    for i=1:m
        count=count+1;
    if round(j/100)==j/100
    waitbar(j/n,f)
    end
    if normb(i,j)>cutoff/2  % only look at the larger WBVs and points in the center of grains
        temp=StereoDir(squeeze(g(:,:,i,j)),symops,squeeze(b(:,i,j))/normb(i,j)); % b is already in Euler frame 
%         temp=StereoDir(squeeze(g(:,:,i,j)),symops,[0 1 0]); % check texture in tensile direction
        % note: alpha is in the sample frame - but the Euler system sample
        % frame. I think StereoDir (from IPF_Calc) expects the sample
        % direction to be in the microscope (xData, yData) frame? (hence it
        % rearranges the x/y in the euler space?????? not sure
        SD(count,:)=temp(:)/norm(temp);
    end
    end
end
close(f)

%stereographic projections
SDSP=zeros(length(SD(:,1)),2);
SDSP(:,1)=SD(:,1)./(1+SD(:,3));
SDSP(:,2)=SD(:,2)./(1+SD(:,3));

SS=[SDSP(SDSP(:,1)>1e-4,1),SDSP(SDSP(:,1)>1e-4,2)];

% find local density
[H,N]=densityplot(SS(:,1),SS(:,2),'nbins',[50,50]);
hold on
TM = max(SS, [], 'all');
XM=[0.01 0.01 TM];
YM=[0.01 TM TM];
fill(XM, YM, [.9412 .9412 .9412]);
title('Crystallographic directions of Burgers vectors')
hold off

% cd('/Users/fullwood/Documents/GitHub/OpenXY/Code/')
figure;
IPF_map = PlotIPF(euler2gmat(Settings.Angles),[Settings.Nx,Settings.Ny],'Square',1);
axis image
hold on
quiver(-b1,-b2,'color',[1 1 1], 'AutoScale','on',AutoScaleFactor=4/3) % negative in order to go from Euler reference frame to Imagesc plotting frame
quiver(Xd,Yd,Ud1,Vd1,'color',[1 1 1], 'linewidth', m1/3, 'AutoScale','on',AutoScaleFactor=4/3) % negative in order to go from Euler reference frame to Imagesc plotting frame
% cd('/Users/fullwood/Dropbox/SyncFolder/Collaborators/Tim Ruggles')
set(gca,'FontSize',16)


