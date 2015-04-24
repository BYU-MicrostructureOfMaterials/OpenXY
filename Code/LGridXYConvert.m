function NewScanFilePath = LGridXYConvert(OIMPath,TxtPath)
%LGRIDXYCONVERT
% NewScanFilePath = LGridXYConvert(OIMPath,TxtPath)
% In a custom scan, depending on where the starting point is chosen, values of xpos and ypos can be positive or negative. 
% Negative values of x and y positions cause problems in finding the size of scan and location of scan points.  
% This code will shift all the negative values to the positive area and makes the (0,0) point as the starting point of the custom scan.
% Written by Sadegh Ahmadi, 10/18/2010, modified for use in the Green
% Machine code by Jay Basinger 

% [OIMFile OIMPath]=uigetfile({'*.ang';'*.txt';'*.*'},'Select OIM .ang file.');
 fid = fopen(OIMPath,'r');
if fid == -1
   NewScanFilePath  = []; 
   return;
end

FoundLastSharp = 0; count=0;
while FoundLastSharp == 0
    count=count+1;
    line = fgetl(fid);
    if (strcmp(line(1),'#') == 0)
        FoundLastSharp = 1;
        fseek(fid, -length(line)-2, 'cof');
        GrainFileValues = textscan(fid, '%f %f %f %f %f %f %f %f %f %f');
    else
        headerlines{count}=line;
    end
end
phi1 = GrainFileValues{1,1};
Phi = GrainFileValues{1,2};
phi2 = GrainFileValues{1,3};
IQ = GrainFileValues{1,6};
CI = GrainFileValues{1,7};
Bdary = GrainFileValues{1,8};
GID = GrainFileValues{1,9};
fit = GrainFileValues{1,10};

%% Read .txt file
%because the sign of xpos and ypos is not specified from reading the .ang
%file and the scan can be taken from any quadrant of cartesian coordinates,
%the .txt custom scan file is imported here and the location of scan points
%are updated by a shift to the first quadrant.
% [TxtFile TxtPath]=uigetfile({'*.txt';'*.*'},'Select custom scan read (custsacn.txt) file.',[OIMPath,'custscan.txt']);
[t1,xpos,t2,ypos,t3,t4,t5,t6,t9,imgname]=textread(TxtPath, '%s %f %s %f %s %f %s %f %s %s','headerlines',0); clear t1 t2 t3 t4 t5 t6 t7 t8 t9
xpos=xpos(1:length(fit)); ypos=ypos(1:length(fit));
xpos=xpos+10e6*xpos(2); ypos=ypos+10e6*ypos(2); %10e6 was used to make sure that all the points are shifted to the first quadrant 
xpos=xpos-xpos(2); ypos=ypos-ypos(2);

newdata = [phi1,Phi,phi2,xpos,ypos,IQ,CI,Bdary,GID,fit];

NewScanFilePath = [OIMPath(1:end-4),'correctedXY.ang'];
fid = fopen(NewScanFilePath, 'w+');
% write the headers
for i=1:length(headerlines)
    fprintf(fid,'%s\n',headerlines{i});
end
% write columns
fprintf(fid, '%9.5f %9.5f %9.5f %12.5f %12.5f %12.3f %7.3f %2.0f %6.0f %6.3f\r\n', newdata');
fclose(fid);