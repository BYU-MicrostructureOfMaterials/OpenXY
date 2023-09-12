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

% clc
% clear
% close all

% [FILENAME, PATHNAME, FILTERINDEX] = uigetfile('*.mat', 'Select an AnalysisParams file');
% 
% load(fullfile(PATHNAME, FILENAME));

IQ = reshape(Settings.IQ(Settings.Inds),Settings.data.cols,Settings.data.rows)';
CI = reshape(Settings.CI(Settings.Inds),Settings.data.cols,Settings.data.rows)';
gid = reshape(Settings.grainID(Settings.Inds),Settings.data.cols,Settings.data.rows)';


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

B = tensorvector2map(Settings.data.F, Settings.data.rows, Settings.data.cols) - eyefield(3,Settings.data.rows, Settings.data.cols);
sigma = tensorvector2map(Settings.data.sigma, Settings.data.rows, Settings.data.cols);
g = tensorvector2map(euler2gmat(Settings.NewAngles), Settings.data.rows, Settings.data.cols);
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

% multiplot(B, mpsettings);
% multiplot(B_s, mpsettings);
% multiplot(B_p, mpsettings);

multiplot(E, esettings);

if exist('alpha_data') && isfield(alpha_data, 'Fa')
    Ba = tensorvector2map(alpha_data.Fa, Settings.data.rows, Settings.data.cols);
    Bc = tensorvector2map(alpha_data.Fc, Settings.data.rows, Settings.data.cols);

    Ba = Ba - eyefield(3,Settings.data.rows, Settings.data.cols);
    Bc = -(Bc - eyefield(3,Settings.data.rows, Settings.data.cols));

    Ba_p = rotatetensorfield(Ba, Qps');
    Bc_p = rotatetensorfield(Bc, Qps');

    mpsettings.clims = [-1 1]*.001;
%     multiplot(Ba_p, mpsettings);
%     multiplot(Bc_p, mpsettings);
else
    disp('No derivatives found, calculating instead...')
    [Ba, Bc] = calcBderivs(B_s);

    Ba_p = rotatetensorfield(Ba, Qps');
    Bc_p = rotatetensorfield(Bc, Qps');

    mpsettings.clims = [-1 1]*1000/1e6;
%     multiplot(Ba_p, mpsettings);
%     multiplot(Bc_p, mpsettings);

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

mpsettings.clims = [-1 1]*4000/1e6;
% multiplot(Ba_fix_smooth, mpsettings);
% multiplot(Bc_fix_smooth, mpsettings);

alpha = partialcurl(Ba_fix_smooth/(Settings.XData(2)*1e-6),Bc_fix_smooth/(Settings.XData(2)*1e-6));


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

burg = 287 * 1e-12;
burg=3.3026e-10; % Tantalum

alphasum = squeeze(sum(abs(alpha),1));
% alphasum(gidmask==0) = 1;
alphasum(IQ<100) = 0/0;
figure; imagesc(log10(alphasum(:,:)/burg)); axis image; colormap('jet'); caxis([13 15])


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
% multiplot(alphatensor,alphasettings);

% for i=1:6
%     tosave = squeeze(alpha(i,:,:));
%     thisrgb = scaledrgb(tosave, alphasettings.clims);
%     imwrite(thisrgb, ['alpha' num2str(i) '.png'], 'png')
% end
% hfig = figure; h = colorbar; caxis(alphasettings.clims); colormap('jet'); axis off
% set(h,'location', 'north', 'FontName', 'Times New Roman', 'FontSize', 12)
% set(get(h,'label'),'string','m^{-1}')
% saveas(hfig, 'alphacb.png', 'png')
 
[b,l, bhat, rhob, ik] = blmap2(alpha);

quiver(squeeze(b(1,:,:)),squeeze(b(2,:,:)),10)

figure; imagesc(log10((ik))); axis image; colormap('jet'); caxis([-6 -4])
normb = squeeze(sqrt(b(1,:,:).^2 + b(2,:,:).^2 + b(3,:,:).^2));
norml = squeeze(sqrt(l(1,:,:).^2 + l(2,:,:).^2 + l(3,:,:).^2));

cl = rotatevectorfield(l,g);
cb = rotatevectorfield(b,g);

cbhat = rotatevectorfield(bhat,g);

return
% thmins = zeros(size(ik));
% dimap = thmins;
% [~,m,n] = size(alpha);
% for i=1:m
%     for j=1:n
%         thisgmat = squeeze(g(:,:,i,j));
%         thisbexp = squeeze(cbhat(:,i,j));
%         [thisthmin,di] = thmincalc(thisbexp, thisgmat, 'Ni(18ss)');
%         thmins(i,j) = thisthmin;
%         dimap(i,j) = di;
%     end
% end
% 
% figure; imagesc(thmins); axis image; colormap('jet');
% caxis([0 40]); axis off
% h = colorbar;
% set(h,'FontName', 'Times New Roman', 'FontSize', 12)
% set(get(h,'label'), 'string', 'degrees')


cutoff = 1e5;
maskalpha = squeeze(sum(abs(alpha),1))<cutoff;
mask = ik > .8e-5;%.0005;
mask = 1 - (1-mask).*(1-maskalpha);

figure;
subplot(2,3,1)
toplot = (180/pi)*atan2(squeeze(cl(2,:,:)),squeeze(cl(1,:,:)));
toplot = (toplot + 180)/360;
toplot = round(63*toplot)+1;
toplot = ind2rgb(toplot,colormap('jet'));
toplot = blackoutrgb(toplot,mask,[1 1 1]);
imshow(toplot); axis image;
imwrite(toplot,'cla.png','png')
xlabel('Line vector aziumuthal')

subplot(2,3,2)
toplot = (180/pi)*atan2(squeeze(cb(2,:,:)),squeeze(cb(1,:,:)));
toplot = (toplot + 180)/360;
toplot = round(63*toplot)+1;
toplot = ind2rgb(toplot,colormap('jet'));
toplot = blackoutrgb(toplot,mask,[1 1 1]);
imshow(toplot); axis image;
imwrite(toplot,'cba.png','png')
xlabel('Burgers vector aziumuthal')

subplot(2,3,[3,6]);
h = colorbar;
caxis([-180 180])
set(h,'Location','west')
axis off

subplot(2,3,4)
toplot = (180/pi)*squeeze(atan2(cl(3,:,:),sqrt(cl(1,:,:).^2 + cl(2,:,:).^2)));
toplot = (toplot + 180)/360;
toplot = round(63*toplot)+1;
toplot = ind2rgb(toplot,colormap('jet'));
toplot = blackoutrgb(toplot,mask,[1 1 1]);
imshow(toplot); axis image;
imwrite(toplot,'cle.png','png')
xlabel('Line vector elevation')

subplot(2,3,5)
toplot = (180/pi)*squeeze(atan2(cb(3,:,:),sqrt(cb(1,:,:).^2 + cb(2,:,:).^2)));
toplot = (toplot + 180)/360;
toplot = round(63*toplot)+1;
toplot = ind2rgb(toplot,colormap('jet'));
toplot = blackoutrgb(toplot,mask,[1 1 1]);
imshow(toplot); axis image;
imwrite(toplot,'cbe.png','png')
xlabel('Burgers vector elevation')

hfig = figure; h = colorbar; caxis([-180 180]); colormap('jet'); axis off
set(h,'location', 'north', 'FontName', 'Times New Roman', 'FontSize', 12)
set(get(h,'label'),'string','degrees')
saveas(hfig, 'anglecb.png', 'png')

figure;
subplot(2,3,1)
toplot = (180/pi)*atan2(squeeze(l(2,:,:)),squeeze(l(1,:,:)));
toplot = (toplot + 180)/360;
toplot = round(63*toplot)+1;
toplot = ind2rgb(toplot,colormap('jet'));
toplot = blackoutrgb(toplot,squeeze(sum(abs(alpha),1))<cutoff,[1 1 1]);
imshow(toplot); axis image;
xlabel('Line vector aziumuthal')

subplot(2,3,2)
toplot = (180/pi)*atan2(squeeze(b(2,:,:)),squeeze(b(1,:,:)));
toplot = (toplot + 180)/360;
toplot = round(63*toplot)+1;
toplot = ind2rgb(toplot,colormap('jet'));
toplot = blackoutrgb(toplot,squeeze(sum(abs(alpha),1))<cutoff,[1 1 1]);
imshow(toplot); axis image;
xlabel('Burgers vector aziumuthal')

subplot(2,3,[3,6]);
h = colorbar;
caxis([-180 180])
set(h,'Location','west')
axis off

subplot(2,3,4)
toplot = (180/pi)*squeeze(atan2(l(3,:,:),sqrt(l(1,:,:).^2 + l(2,:,:).^2)));
toplot = (toplot + 180)/360;
toplot = round(63*toplot)+1;
toplot = ind2rgb(toplot,colormap('jet'));
toplot = blackoutrgb(toplot,squeeze(sum(abs(alpha),1))<cutoff,[1 1 1]);
imshow(toplot); axis image;
xlabel('Line vector elevation')

subplot(2,3,5)
toplot = (180/pi)*squeeze(atan2(b(3,:,:),sqrt(b(1,:,:).^2 + b(2,:,:).^2)));
toplot = (toplot + 180)/360;
toplot = round(63*toplot)+1;
toplot = ind2rgb(toplot,colormap('jet'));
toplot = blackoutrgb(toplot,squeeze(sum(abs(alpha),1))<cutoff,[1 1 1]);
imshow(toplot); axis image;
xlabel('Burgers vector elevation')




% threeorsix = 1;
% minscheme = 1;
% L1 = 1;
% x0type = 0;
% matchoose = 'Ni(18ss)';
% [bedge,ledge, bscrew,lscrew,v, normals, crssfactor, type] = choosemat( matchoose );
% numtype = length(bedge) + length(bscrew);
% rhos = zeros(numtype,size(alpha,2),size(alpha,3));
% for i=1:size(alpha,2)
%     for j=1:size(alpha,3)
%         alphavec = squeeze(alpha(:,i,j));
%         gmat = squeeze(g(:,:,i,j));
%         [rho]=resolvedislocB(alphavec,threeorsix, minscheme,matchoose,gmat, L1, x0type);
%         rhos(:,i,j) = rho;
%     end
% end
% 
% rpsettings.clims = [-5e14 5e14];
% rpsettings.cmap = 'jet';
% for i=1:numtype
%     rlabels{i} = ['\rho_{' num2str(i) '}'];
% end
% rpsettings.labels = rlabels;
% rhoplot(rhos, rpsettings);

figure;
IPF_map = PlotIPF(euler2gmat(Settings.Angles),[Settings.data.cols,Settings.data.rows],'Square',[0 1 0],1);
axis image

