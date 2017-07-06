% script to test creating EMSoft pics

xstar =  0.523681823393622; %hitachi 01 silicon 
ystar = 0.877133332932488;
zstar = 0.619355104437968;

% xstar =  0.4582;
% ystar = 0.7781;
% zstar = 0.8466;

% VHRatio=1024/1344; % image size for Aztc image from Tim Ruggles
% xstar=(0.4880- (1-VHRatio)/2)/VHRatio;
% ystar=0.6430;
% zstar=0.6315/VHRatio;

Av = 20*1000; %put it in eV from KeV
sampletilt = 70*pi/180;
elevang = 0*pi/180;
pixsize = 1024;
Material = 'silicon';
% Material = 'aluminum';

mperpix=21.48;
phi1=5.959077665;
PHI=0.044453536;
phi2=1.089678865;

% phi1=202.0230*pi/180;
% PHI=2.9233*pi/180;
% phi2=69.2729*pi/180;

% [g]=(euler2gmat(phi1+pi/2,PHI,phi2)); % change from hkl to TSL
[g]=(euler2gmat(phi1,PHI,phi2)); % no change from hkl to tsl

[pic]=genEBSDPatternHybrid_fromEMSoft(g,xstar,ystar,zstar,pixsize,mperpix,elevang,sampletilt,Material,Av);
%took out elevang from the list 
figure
imagesc(pic)
colormap gray;