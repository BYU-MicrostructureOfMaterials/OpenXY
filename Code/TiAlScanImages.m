%change scan name, material

%Setup EMsoft environment variables
EMsoftVarSetup();

%Generate TiAl scans
scan = 'TiAl_Sim_Line_Short';

%Set Folder
if ispc
    folder = '\\CB165_NAS\Shared\TiAl\Scans';
else
    folder = '/Volumes/Shared/TiAl/Scans';
end

%Create Folder Structure
ImageFolder = fullfile(folder,scan);
if ~isdir(ImageFolder)
    mkdir(ImageFolder);
end
CtfFile = '/Volumes/Shared/TiAl/Scans/TiAl_Sim.ctf';

%Scan Params
xstar = 0.5;
ystar = 0.5;
zstar = 0.5;
pixsize = 512;
mperpix = 25;
elevang = 10*pi/180;
Material = 'TiAl'; %change back to scan
Av = 20000; %should be in eV, not KeV
PhosphorSize = pixsize*mperpix;
SampleTilt = 1.2217;
SSE = ones(100,1);
NumPoints = 1;
NumGrains = 10;
Length = NumPoints*NumGrains;

XData = 1:Length;
YData = zeros(1,Length);
XStar(1:Length) = xstar-(XData-1)/PhosphorSize;
YStar(1:Length) = ystar+YData/PhosphorSize*sin(SampleTilt-elevang);
ZStar(1:Length) = zstar+YData/PhosphorSize*cos(SampleTilt-elevang);

%Orientation, values taken from Zambaldi Paper
orientation(1,:) = [221.6, 108.0, 270.7]; %orientation_3, this is the correct solution
orientation(2,:) = [38.6, 162.4, 177.3]; %orientation_4, no pseudo with 3
orientation(3,:) = [131.1, 90.3, 72.2];%orientation_1, symmetric with 3
orientation(4,:) = [0,0,0];%orientation_2, symmetric with 1 and 3
orientation(5,:) = [180,90,90];%orientation_5, not symmetric with any
orientation(6,:) = [45,0,0];
orientation(7,:) = [90,90,0];
orientation(8,:) = [225,90,90];
orientation(9,:) = [0,30,0];
orientation(10,:) = [135,90,0];
orientation = orientation*pi/180;

%phi3 = [orientation(1,3); orientation(2,3); orientation(3,3); orientation(4,3); orientation(5,3);...
    %orientation(6,3); orientation(7,3); orientation(8,3); orientation(9,3); orientation(10,3)];
phi3 = orientation(:,3);
for i = 1:NumGrains
    angles(NumPoints*(i-1)+1:NumPoints*i,:) = repmat(orientation(i,:),NumPoints,1);
end

%Add orientation shift over grain
angles_rot = angles;
angles_rot(:,3) = angles_rot(:,3)+repmat(((0:.1:(NumPoints/10)-0.1)*pi/180)',NumPoints,1);

% for i = 0:.1:.9;
%     rotation(:,int8((i+.1)*10)) = (phi3+i)*pi/180;
% end
% rot_mat(:,:) = [orientation, rotation];

%TiAl Images
cols = 1;
for i = 1:Length %each orientation
    g = euler2gmat(angles_rot(i,1), angles_rot(i,2), angles_rot(i,3));
    RefImage = genEBSDPatternHybrid_fromEMSoft(g,XStar(i),YStar(i),ZStar(i),pixsize,mperpix,elevang,Material,Av);
    for j = 1:cols
        imwrite(RefImage,gray(256),fullfile(ImageFolder,[scan '_' sprintf('x%dy%d',[i-1,j-1]*10) '.jpg']),'jpg');
    end
end

%Copy angles
angles_rot = repmat(angles_rot,cols,1);

%Write .ctf File
OutputFile = fullfile(folder,[scan '.ctf']);
% WriteHROIMCtfFile(folder, OutputFile, orientation(:,1)...
%     ,orientation(:,2), orientation(:,3), SSE);
WriteHROIMCtfFile(CtfFile, OutputFile, angles_rot(:,1)...
    ,angles_rot(:,2), angles_rot(:,3), num2cell(SSE));

%under construction...

%%Add Angle Error
%angle_error = 0.5; %degrees
%angle_error = angle_error*pi/180; %convert to radians
%rand_sign = ones(size(Angles));
%rand_sign(rand(size(Angles))>0.5) = -1;
%Angles_er = Angles + rand(size(Angles))*angle_error.*rand_sign;

%Write .ctf File
%OutputFile = fullfile(folder,[scan '.ctf']);
%WriteHROIMCtfFile(folder, OutputFile, orientation(:,1)...
    %,orientation(:,2), orientation(:,3), Settings.SSE);
 
    