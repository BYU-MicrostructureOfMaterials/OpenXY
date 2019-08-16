function [pic]=genEBSDPatternHybrid_fromEMSoft(g,xstar,ystar,zstar,pixsize,mperpix,elevang,sampleTilt,Material,Av,ImageInd)

if nargin < 11
    ImageInd = 0;
end

%Initialize variables for EMEBSD
L=(zstar*pixsize*mperpix); %define mperpix in original script TODO Grab real working distance from ang file
thetac = elevang * 180 / pi; % in degrees
delta = mperpix;
numsx = pixsize;
numsy = numsx;
xpc = (xstar-0.5)*pixsize; % in pixels measured from center of phosphor
ypc = (ystar-0.5)*pixsize;
omega = 0;
alphaBD = 0;
energymin = 5.0;
energymax = 20.0;
includebackground = 'y';
anglefile = ['OpenXY_euler' num2str(ImageInd) '.txt'];  %fullfile(OpenXYPath,'temp','testeuler.txt');%['temp' filesep 'testeuler.txt'];
eulerconvention = 'tsl';

%Get EMsoft Path
if exist('SystemSettings.mat','file')
    load SystemSettings
    EMdataPath = fullfile(fileparts(EMsoftPath),'EMdata');
end

%added masterfile and energyfile to the code folder.  Is that right?
if ~exist(fullfile(EMdataPath,sprintf('%s_EBSDmaster.h5',Material)),'file')
    masterfile = (sprintf('%s_EBSDmasterout.h5',Material));
else
    masterfile = (sprintf('%s_EBSDmaster.h5',Material)); 
end
energyfile = masterfile;%EMsoft now uses the master output for both the master file and energy file(sprintf('%s_MCoutput.h5',Material));
datafile = ['EBSDout_' num2str(ImageInd) '.h5'];
bitdepth = '8bit';
beamcurrent = 15; %Make variable later
dwelltime = 100;   %Make variable later
binning = 1;       %Make variable later
applyDeformation = 'n';
Ftensor = '1.D0, 0.D0, 0.D0, 0.D0, 1.D0, 0.D0, 0.D0, 0.D0, 1.D0,';
scalingmode = 'not';
gammavalue = .4;   %Make variable later
maskpattern = 'y';
nthreads = 1;

[phi1,PHI,phi2] = gmat2euler(g); % in radians

datafilepath = fullfile(EMdataPath,datafile);%['temp' filesep 'EBSDout.h5'];
inputfile = fullfile(EMdataPath,['OpenXY_' num2str(ImageInd) '.nml']);

%Write testeuler.txt file
fid=fopen(fullfile(EMdataPath,anglefile),'w');

fprintf(fid,'eu\n');
fprintf(fid,'1\n');
fprintf(fid,'%g,%g,%g\n',phi1*180/pi,PHI*180/pi,phi2*180/pi);% in degrees
fclose(fid);

cleanupAngles = onCleanup(@() delete(fullfile(EMdataPath,anglefile)));

%Write EMEBSDexample.nml file
fid=fopen(inputfile,'w');
formatString = [
' &EBSDdata\n'...
... template file for the EMEBSD program
...
... distance between scintillator and illumination point [microns]
' L = %g\n'...
... tilt angle of the camera (positive below horizontal, [degrees])
' thetac = %g,\n'...
... CCD pixel size on the scintillator surface [microns]
' delta = %g,\n'...50.0
... number of CCD pixels along x and y
' numsx = %g,\n'...
' numsy = %g,\n'...
... pattern center coordinates in units of pixels
' xpc = %g,\n'...
' ypc = %g,\n'...
... angle between normal of sample and detector
' omega = %g,\n'...
... transfer lens barrel distortion parameter
' alphaBD = %g,\n'...0.0
... energy range in the intensity summation [keV]
' energymin = %g,\n'...5.0
' energymax = %g,\n'...20.0
... include a realistic intensity background or not ...
' includebackground = ''%s'',\n'...'y'
... name of angle file (euler angles or quaternions); path relative to EMdatapathname
' anglefile = ''%s'',\n'...'testeuler.txt'
... does this file have only orientations ('orientations') or does it also have pattern center and deformation tensor ('orpcdef')
... if anglefiletype = 'orpcdef' then each line in the euler input file should look like this: (i.e., 15 floats)
...   55.551210  58.856774  325.551210  0.0  0.0  15000.0  1.00 0.00 0.00 0.00 1.00 0.00 0.00 0.00 1.00
...   <-   Euler angles  (degrees)  ->  <- pat. ctr.   ->  <- deformation tensor in column-major form->
' anglefiletype = ''orientations'',\n'...
... 'tsl' or 'hkl' Euler angle convention parameter
' eulerconvention = ''%s'',\n'...'tsl'
... name of EBSD master output file; path relative to EMdatapathname
' masterfile = ''%s'',\n'...'master.h5'
... name of output file; path relative to EMdatapathname
' datafile = ''%s'',\n'...'EBSDout.h5'
... bitdepth '8bit' for [0..255] bytes; 'float' for 32-bit reals; '##int' for 32-bit integers with ##-bit dynamic range
... e.g., '9int' will get you 32-bit integers with intensities scaled to the range [ 0 .. 2^(9)-1 ];
... '17int' results in the intensity range [ 0 .. 2^(17)-1 ]
' bitdepth = ''%s'',\n'...'8bit'
 ... incident beam current [nA]
' beamcurrent = %g,\n'...'150.0'
... beam dwell time [micro s]
' dwelltime = %g,\n'...'100.0'
... include Poisson noise ? (y/n) (noise will be applied *before* binning and intensity scaling)
' poisson = ''n'',\n'...
... binning mode (1, 2, 4, or 8)
' binning = %u,\n'...'1'
... should we perform an approximate computation that includes a lattice distortion? ('y' or 'n')
... This uses a polar decomposition of the deformation tensor Fmatrix which results in
... an approcimation of the pattern for the distorted lattice; the bands will be very close
... to the correct position in each pattern, but the band widths will likely be incorrect.
' applyDeformation = ''%s''\n'...'n'
... if applyDeformation='y' then enter the 3x3 deformation tensor in column-major form
... the default is the identity tensor, i.e., no deformation
' Ftensor = %s\n'...1.D0, 0.D0, 0.D0, 0.D0, 1.D0, 0.D0, 0.D0, 0.D0, 1.D0,
... intensity scaling mode 'not' = no scaling, 'lin' = linear, 'gam' = gamma correction
' scalingmode = ''%s'',\n'...'not',
... gamma correction factor
' gammavalue = %g,\n'...1.0,
... if the 'makedictionary' parameter is 'n', then we have the normal execution of the program
... if set to 'y', then all patterns are pre-processed using the other parameters below, so that
... the resulting dictionary can be used for static indexing in the EMEBSDDI program...
... these parameters must be taken identical to the ones in the EMEBSDDI.nml input file to have
... optimal indexing...
' makedictionary = ''n'',\n'...
... should a circular mask be applied to the data? 'y', 'n'
' maskpattern = ''%s'',\n'...'n',
... mask radius (in pixels, AFTER application of the binning operation)
' maskradius = %u,\n'...
... hi pass filter w parameter; 0.05 is a reasonable value
' hipassw = 0.05,\n'...
... number of regions for adaptive histogram equalization
' nregions = 10,\n'...
... number of threads (default = 1)
' nthreads = %u,\n'...1
' /\n'];

fprintf(fid,formatString,L,thetac,delta,numsx,numsy,xpc,ypc,omega,...
    alphaBD,energymin,energymax,includebackground,anglefile,...
    eulerconvention,masterfile,datafile,bitdepth,...
    beamcurrent,dwelltime,binning,applyDeformation,Ftensor,...
    scalingmode,gammavalue,maskpattern,floor(numsx/2),nthreads);
%{
fprintf(fid,'&EBSDdataERROR\n');
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
fprintf(fid,'anglefile=''%s''\n',anglefile);
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
%}
fclose(fid);

cleanupNamelist = onCleanup(@() delete(inputfile));

%run EMsoft
cd(EMdataPath);
%setenv('DYLD_LIBRARY_PATH',['/opt/local/lib/libgcc/']);
[status,cmdout] = system(['"' fullfile(EMsoftPath,'bin','EMEBSD') '" ' inputfile]);
cd(OpenXYPath);

cleanupDataFile = onCleanup(@() delete(fullfile(EMdataPath,datafile)));
%!EMEBSD EMEBSDexample.nml
if status
    disp(cmdout)
end
%generate pic
h5infostruct=h5info(datafilepath);
data1=h5read(h5infostruct.Filename,'/EMData/EBSD/EBSDPatterns');
pic=zeros(numsx,numsy);
pic(:,:)=data1(:,:,1);
pic=(pic');   % flip to correct OIM reference frame (swap TD and RD)
%imagesc(pic)
%colormap 'gray'
% delete(fullfile(EMdataPath,datafile), inputfile, fullfile(EMdataPath,anglefile));
end