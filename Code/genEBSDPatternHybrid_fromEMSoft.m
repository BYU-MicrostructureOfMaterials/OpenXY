function [pic]=genEBSDPatternHybrid_fromEMSoft(g,xstar,ystar,zstar,pixsize,mperpix,elevang,Material,Av)

L=(zstar*pixsize*mperpix); %define mperpix in original script
thetac=elevang*180/pi; % in degrees
delta=mperpix;
numsx=pixsize;
numsy=numsx;
xpc=(xstar-0.5)*pixsize; % in pixels measured from center of phosphor
ypc=(ystar-0.5)*pixsize;

%Get EMsoft Path
if exist('SystemSettings.mat','file')
    load SystemSettings
    EMdataPath = fullfile(fileparts(EMsoftPath),'EMdata');
end

%added masterfile and energyfile to the code folder.  Is that right?
masterfile=fullfile(EMdataPath,sprintf('%s_EBSDmaster.h5',Material));  
energyfile=fullfile(EMdataPath,sprintf('%s_MCoutput.h5',Material));
datafile=['temp' filesep 'EBSDout.h5'];
beamcurrent=15; %Make variable later
dwelltime=100;   %Make variable later
binning=1;       %Make variable later
gammavalue=.4;   %Make variable later
filename= ['temp' filesep 'testeuler.txt'];

[phi1,PHI,phi2]=gmat2euler(g); % in radians

%Write testeuler.txt file
fid=fopen(filename,'w');

fprintf(fid,'eu\n');
fprintf(fid,'1\n');
fprintf(fid,'%g,%g,%g\n',phi1*180/pi,PHI*180/pi,phi2*180/pi);% in degrees

fclose(fid);

%Write EMEBSDexample.nml file
fid=fopen(['temp' filesep 'EMEBSDexample.nml'],'w');

fprintf(fid,'&EBSDdata\n');
fprintf(fid,'! template file for the CTEMEBSD program\n');
fprintf(fid,'!\n');
fprintf(fid,'! distance between scintillator and illumination point [microns]\n');
fprintf(fid,'L=%g\n',L);
fprintf(fid,'! tilt angle of the camera (positive below horizontal, [degrees])\n');
fprintf(fid,'thetac=%g\n',thetac);
fprintf(fid,'! CCD pixel size on the scintillator surface [microns]\n');
fprintf(fid,'delta=%g\n',delta);
fprintf(fid,'! number of CCD pixels along x and y\n');
fprintf(fid,'numsx=%g\n',numsx);
fprintf(fid,'numsy=%g\n',numsy);
fprintf(fid,'! pattern center coordinates in units of pixels\n');
fprintf(fid,'xpc=%g\n',xpc);
fprintf(fid,'ypc=%g\n',ypc);
fprintf(fid,'! name of angle file (euler angles or quaternions)\n');
fprintf(fid,'anglefile=''%s''\n',filename);
fprintf(fid,'! ''tsl'' or ''hkl'' Euler angle convention parameter\n');
fprintf(fid,'eulerconvention=''tsl''\n');
fprintf(fid,'! name of EBSD master output file\n');
fprintf(fid,'masterfile=''%s''\n',masterfile);
fprintf(fid,'! name of Monte Carlo output file\n');
fprintf(fid,'energyfile=''%s''\n',energyfile);
fprintf(fid,'! name of output file\n');
fprintf(fid,'datafile=''%s''\n',datafile);
fprintf(fid,'! incident beam current [nA]\n');
fprintf(fid,'beamcurrent=%g\n',beamcurrent);
fprintf(fid,'! beam dwell time [micro s]\n');
fprintf(fid,'dwelltime=%g\n',dwelltime);
fprintf(fid,'! binning mode (1, 2, 4, or 8)\n');
fprintf(fid,'binning=%g\n',binning);
fprintf(fid,'! intensity scaling mode ''not'' = no scaling, ''lin'' = linear, ''gam'' = gamma correction\n');
fprintf(fid,'scalingmode= ''gam''\n');
fprintf(fid,'! gamma correction factor\n');
fprintf(fid,'gammavalue=%g\n',gammavalue);
fprintf(fid,'! output format selector ''bin'' for dictionaries, ''gui'' for interactive mode\n');
fprintf(fid,'outputformat = ''bin''\n');
fprintf(fid,'! should a circular mask be applied to the data? ''y'', ''n''\n');
fprintf(fid,'maskpattern=''n''\n');
fprintf(fid,'! number of threads (default = 1)\n');
fprintf(fid,'nthreads=1\n');
fprintf(fid,'energymin = 10.0\n'); % these extra 3 lines from Marc de Graef in email Aug 12 2015
fprintf(fid,'energymax =%f\n', Av/1000); %beam voltage in kV
fprintf(fid,'energyaverage = 0\n');
fprintf(fid,'/\n');

fclose(fid);

%run EMsoft
[status,cmdout] = system(['"' fullfile(EMsoftPath,'bin','EMEBSD') '" ' fullfile(OpenXYPath,'temp','EMEBSDexample.nml')]);
%!EMEBSD EMEBSDexample.nml

%generate pic
h5infostruct=h5info(datafile);
data1=h5read(h5infostruct.Filename,'/EMData/EBSDpatterns');
pic=zeros(numsx,numsy);  
pic(:,:)=data1(:,:,1);
pic=flipud(pic');   % flip to correct OIM reference frame (swap TD and RD)
%imagesc(pic)
%colormap 'gray'
end

