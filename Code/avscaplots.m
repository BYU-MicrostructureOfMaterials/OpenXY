% code to analyze slip-level GND data for Khushahal
% DTF 20/2/19
% clear
% close all
% [picname,picpath] = uigetfile('*.mat','Analysis parameters');
% load([picpath,picname]);

function avscaplots(Settings, alpha_data, rhos, DDSettings)

if isfield(alpha_data,'stepsize')
    stepsize = alpha_data.stepsize;
elseif isfield(alpha_data,'stepsizea')
    stepsize = alpha_data.stepsizea;
else
    stepsize = (Settings.XData(2)-Settings.XData(1))*(Settings.NumSkipPts+1);
end
n = Settings.Nx;
m = Settings.Ny;

[nd,L] = size(rhos);
showtitle = 0;

matchoice = DDSettings.matchoice;
[bedge,ledge, bscrew,lscrew,v, normals, crssfactor, type] = choosemat(matchoice);
b=[bscrew;bedge];
l=[lscrew;ledge];
nscrew = size(bscrew,1);
nedge = size(bedge,1);

edgea=zeros(m,n);
edgeca=edgea;
screwa=edgea;
screwca=edgea;
tot_basal=edgea;
tot_prism=edgea;
tot_pyramidala=edgea;
tot_pyramidalca=edgea;

%count=1;
% for i=1:nd
%     ri = reshape(shiftdim(rhos(i,:)),n,m)';
%     if i <= nscrew
%         if type(i)==1
%             screwa=screwa+abs(ri);
%             tot_basal=tot_basal+abs(ri);
%         elseif type(i)==2
%             screwa=screwa+abs(ri);
%             tot_prism=tot_prism+abs(ri);
%             %         elseif type(i)==3
%             %             screwa=screwa+abs(ri);
%             %             tot_pyramidala=tot_pyramidala+abs(ri);
%
%         else
%             screwca=screwca+abs(ri);
%             tot_pyramidalca=tot_pyramidalca+abs(ri);
%         end
%     else
%
%         i=i-nscrew;
%
%         if type(i)==1
%             edgea=edgea+abs(ri);
%             tot_basal=tot_basal+abs(ri);
%         elseif type(i)==2
%             edgea=edgea+abs(ri);
%             tot_prism=tot_prism+abs(ri);
%             %         elseif type(i)==3
%             %             edgeca=edgeca+abs(ri);
%             %             tot_pyramidala=tot_pyramidala+abs(ri);
%
%         else
%             edgeca=edgeca+abs(ri);
%             tot_pyramidalca=tot_pyramidalca+abs(ri);
%         end
%     end
%
%     i=i+1;
% end

for i=1:nd
    ri = reshape(shiftdim(rhos(i,:)),n,m)';
    if i<=nscrew
        if type(i)==1
            tot_basal=tot_basal+abs(ri);
        elseif type(i)==2
            tot_prism=tot_prism+abs(ri);
                    elseif type(i)==3
                        screwa=screwa+abs(ri);
                        tot_pyramidala=tot_pyramidala+abs(ri);
            
        else
            tot_pyramidalca=tot_pyramidalca+abs(ri);
            
        end
    else
        i=i-nscrew;
        if type(i)==1
            tot_basal=tot_basal+abs(ri);
        elseif type(i)==2
            tot_prism=tot_prism+abs(ri);
                    elseif type(i)==3
                        screwa=screwa+abs(ri);
                        tot_pyramidala=tot_pyramidala+abs(ri);
            
        else
            tot_pyramidalca=tot_pyramidalca+abs(ri);
            
        end
    end
end

cmin = log10(1/stepsize^2);
cmax = log10(1/(2.5e-10*stepsize)/nd);
figure
imagesc(log10(tot_basal))
title('log10(Total basal) type GND')
caxis([12 15]);
colorbar

figure
imagesc(log10(tot_prism))
title('log10(Total Prismatic) type GND')
caxis([12 15]);
colorbar


figure
imagesc(log10(tot_pyramidala))
title('log10(Total Pyramidal-a) type GND')
caxis([12 15]);
colorbar

figure
imagesc(log10(tot_pyramidalca))
title('log10(Total Pyramidal-c+a) type GND')
caxis([12 15]);
colorbar

figure
imagesc(log10(tot_basal)./log10(tot_pyramidalca))
title('Ratio of log10(a) vs log10(c+a)-type GND')
caxis([0.8,1.2])
colorbar

% weighted Burgers Vector plot...
%normb=alpha_data.b(1,1); % Burger's vector size
normb=5.89000000000000e-10;
thisvec=zeros(L,3);
for i=1:L
    thisvec(i,:)=alpha_data.alpha(:,3,i)*normb;
    if thisvec(i,3)<0
        thisvec(i,:)=-thisvec(i,:);
    end
    thisvec(i,:)=thisvec(i,:)/vecnorm(thisvec(i,:));
end
thisvec=reshape(thisvec,[n,m,3]);
% figure
% imagesc(permute(thisvec,[2,1,3]))


a13=alpha_data.alpha(1,3,:)*normb;
a13=reshape(a13,[n,m])';
% figure
% imagesc(log10(abs(a13/normb)));
% caxis([12,14.5])
% title('Alpha 13')
a23=alpha_data.alpha(2,3,:)*normb;
a23=reshape(a23,[n,m])';
% figure
% imagesc(log10(abs(a23/normb)));
% caxis([12,14.5])
% title('Alpha 23')
a33=alpha_data.alpha(3,3,:)*normb;
a33=reshape(a33,[n,m])';
% figure
% imagesc(log10(abs(a33/normb)));
% caxis([12,14.5])
% title('Alpha 33')

tot_dislocation=alpha_data.alpha_total3*normb;
tot_dislocation=log10(abs(tot_dislocation/normb));
tot_dislocation=reshape(tot_dislocation,[n,m])';
tot_dislocation(tot_dislocation==-Inf)=0;
figure
%imagesc(log10(abs(atot/normb)));
imagesc(tot_dislocation);
caxis([12,16])
title('Alpha total')
colorbar


% put all WBVs in the same hemisphere
a13(a33<0)=-a13(a33<0);
a23(a33<0)=-a23(a33<0);
a33(a33<0)=-a33(a33<0);

figure
quiver(a13,a23)

wbv=cat(3,a13,a23,a33);
for i=1:m
    for j=1:n
        wbv(i,j,:)=wbv(i,j,:)/vecnorm(squeeze(wbv(i,j,:)));
        %         if wbv(i,j,3)<0
        %             wbv(i,j,:)=-wbv(i,j,:);
        %         end
    end
end

% figure
% imagesc(wbv)
% title('Weighted Burgers Vector Direction')



grainnum=Settings.grainID;
grainnum=reshape(grainnum,[n,m])';
a=mean(tot_basal(grainnum==30));

mmmm=msgbox('Click on 6 grains to investigate them; press return if nothing happens');
[xgg, ygg]=ginput(6); % gets user input to select grains from the figures
xgg=floor(xgg);
ygg=floor(ygg);
index=(n*(ygg))+xgg;

grainID=Settings.grainID;
grains=grainID(index);
grainID=reshape(grainID,[n,m])';

valtot_basal=0
valtot_prism=0
valtot_pyramidalca=0
valtotrho=0
norm=0
% tot_basal=log10(tot_basal);
% totp=log10(totp);
% totca=log10(totca);

tot_basal(tot_basal==-Inf)=0;
tot_prism(tot_prism==-Inf)=0;
tot_pyramidalca(tot_pyramidalca==-Inf)=0;

for f=1:6;
    norm=0
    for row=1:m
        for col=1:n
            if grainID(row,col)==grains(f);
                if tot_basal(row,col)~=0
                    norm=norm+1; % counts number of pixels in selected grain to normalize the total counted GND from individual system
                end
                valtot_basal=tot_basal(row,col)+valtot_basal; 
                valtot_prism=tot_prism(row,col)+valtot_prism;
                valtot_pyramidalca=tot_pyramidalca(row,col)+valtot_pyramidalca;
                %valtotrho=atot(row,col)+valtotrho;
                
            end
        end
        
    end
    valtot_basal_1(f)=valtot_basal/norm;
    valtotprism_1(f)=valtot_prism/norm;
    valtotpyramidal_1(f)=valtot_pyramidalca/norm;
    valtot_rho1(f)=valtot_basal_1(f)+valtotprism_1(f)+valtotpyramidal_1(f);
    
    fracbasal(f)=valtot_basal_1(f)/valtot_rho1(f); %Normalising by total Dislocation density of that grain
    fracprism(f)=valtotprism_1(f)/valtot_rho1(f); %Normalising by total Dislocation density of that grain
    fracpyramidal(f)=valtotpyramidal_1(f)/valtot_rho1(f); %Normalising by total Dislocation density of that grain
    
end

fracbasal=fracbasal.'; %fraction
fracprism=fracprism.';
fracpyramidal=fracpyramidal.';

end

% valtot_basal1=valtot_basal1.'
% valtotp1=valtotp1.'
% valtotca1=valtotca1.'
% valtotrho1=valtotrho1.'


% x=-1:.01:1;
% [Y,X]=meshgrid(x,x);
% Z=1-sqrt(X.^2+Y.^2);
% imxyz=cat(3,X,Y,Z);
% figure
% imagesc(imxyz)