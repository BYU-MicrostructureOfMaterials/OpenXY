%% Section 1

tmp=load('/Users/Adams/Documents/CalcF_ROIs.mat');
Settings = tmp.Settings;
clear tmp

%for i = 1:9;
    ImageInd = 1;  %put ImageInd in a for loop from like 1 to 50
    Ind = ImageInd;
    RefInd = Ind+1;
    Path1 = Settings.ImageNamesList{Ind};
    Path2 = Settings.ImageNamesList{RefInd};

    ScanImage = ReadEBSDImage(Path1, Settings.ImageFilter);
    RefImage = ReadEBSDImage(Path2, Settings.ImageFilter);

    Fo = eye(3);
    g = euler2gmat(Settings.Angles);
    g = g(:,:,Ind);
    curMaterial = Settings.Phase{Ind};
    [roixc,roiyc]= GetROIs(ScanImage,Settings.NumROIs,Settings.PixelSize,Settings.ROISize,...
        Settings.ROIStyle);
    Settings.roixc = roixc;
    Settings.roiyc = roiyc;
%end
%% Section 2

profile on
tic
for i = 1:100
CalcF_original(RefImage,ScanImage,g,Fo,Ind,Settings,curMaterial,RefInd);
end
time_serial = toc;
profile off
profile viewer

profile on
tic
for i = 1:100
CalcF(RefImage,ScanImage,g,Fo,Ind,Settings,curMaterial,RefInd);
end
time_parfor = toc;
profile off
profile viewer