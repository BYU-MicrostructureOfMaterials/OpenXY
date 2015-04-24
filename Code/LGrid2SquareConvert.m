% Convert Lgrid scan to a Square-grid scan
% Written by Sadegh Ahmadi, 9/28/2010
function NewScanFilePath = LGrid2SquareConvert(OIMPath,TxtPath)
%LGRID2SQUARECONVERT
%NewScanFilePath = LGrid2SquareConvert(OIMPath,TxtPath)
% Convert Lgrid scan to a Square-grid scan
% Written by Sadegh Ahmadi, 9/28/2010, modified for use in the Green
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

% phi1=phi1(1:73440);
% phi2=phi2(1:73440);
% Phi=Phi(1:73440);
% IQ=IQ(1:73440);
% CI=CI(1:73440);
% Bdary=Bdary(1:73440);
% GID=GID(1:73440);
% fit=fit(1:73440);
%% Read .txt file
%because the sign of xpos and ypos is not acheived from reading the .ang
%file and the scan can be taken from any quadrant of cartesian coordinates,
%the .txt custom scan file is read here and the values of xpos and ypos are
%shifted to the right location to make the normal square grid file
% [TxtFile TxtPath]=uigetfile({'*.txt';'*.*'},'Select custom scan read (custsacn.txt) file.',[OIMPath,'custscan.txt']);
[t1,xpos,t2,ypos,t3,t4,t5,t6,t9,imgname]=textread(TxtPath, '%s %f %s %f %s %f %s %f %s %s','headerlines',0); clear t1 t2 t3 t4 t5 t6 t7 t8 t9
xpos=xpos(1:length(fit)); ypos=ypos(1:length(fit));
xpos=xpos+10e6*xpos(2); ypos=ypos+10e6*ypos(2); %10e6 was used to make sure that all the points are shifted to the first quadrant 
xpos=xpos-xpos(2); ypos=ypos-ypos(2);

angdata = [phi1,Phi,phi2,xpos,ypos,IQ,CI,Bdary,GID,fit];
indlist = 2:3:size(angdata,1);
newdata = angdata(indlist,:);

NewScanFilePath = [OIMPath(1:end-4),'_OIMreadable.ang'];

[fid message] = fopen(NewScanFilePath, 'w+');
% write the headers
for i=1:length(headerlines)
    fprintf(fid,'%s\n',headerlines{i});
end
% write columns
fprintf(fid, '%9.5f %9.5f %9.5f %12.5f %12.5f %12.3f %7.3f %2.0f %6.0f %6.3f\r\n', newdata');
fclose(fid);


