function [orientation,tet,coefs,stuff]=ResolvePseudosymmetry(Settings,bin,noise)
Settings = HREBSDPrep(Settings);

if nargin == 1
    noise = 0;
    bin = 1;
end
BinningScale = bin;
lambda = noise;

%Account for Binning
Settings.PixelSize = size(imresize(zeros(Settings.PixelSize),BinningScale),1); %Correct image size
Settings.ROISize = round((Settings.ROISizePercent * .01)*Settings.PixelSize);

%Extract out Variables from Settings
pixsize = Settings.PixelSize;
mperpix = Settings.mperpix;
elevang = Settings.CameraElevation;
Av = Settings.AccelVoltage*1000;

[roixc,roiyc]= GetROIs(ones(Settings.PixelSize),Settings.NumROIs,pixsize,Settings.ROISize,...
    Settings.ROIStyle);
Settings.roixc = roixc;
Settings.roiyc = roiyc;

%Pre-allocation
orientation = zeros(3,3,Settings.ScanLength);
tet = zeros(Settings.ScanLength,3);
XX = zeros(Settings.ScanLength,3);
MI = zeros(Settings.ScanLength,3);
SC = zeros(Settings.ScanLength,3);
SSE = zeros(Settings.ScanLength,3);

%Get Inds
if ~isfield(Settings,'Inds')
    Settings.Inds = (1:Settings.ScanLength)';
end

%Extract variables from Settings to reduce parfor overhead
Inds = Settings.Inds;
XStar = Settings.XStar(Inds);
YStar = Settings.YStar(Inds);
ZStar = Settings.ZStar(Inds);
ImNames = Settings.ImageNamesList(Inds);
ImageFilter = Settings.ImageFilter;
g = euler2gmat(Settings.Angles(Inds,:));

imsize = Settings.PixelSize;

h = parfor_progressbar(Settings.ScanLength,'Resolving');
for i = 1:Settings.ScanLength
    ImageInd = Inds(i);
    
    %Pre-allocate
    F = zeros(3,3,3);
    RefImage = zeros(imsize,imsize,3);
    
    %Get variables from Settings
    xstar = XStar(i);
    ystar = YStar(i);
    zstar = ZStar(i);
    curMaterial = 'TiAl';%Settings.Phase{ImageInd};
    
    %Read in EBSD Image
    ScanImage = ReadEBSDImage(ImNames{i},ImageFilter);
    ScanImage = imresize(ScanImage,BinningScale);
    if noise > 0
        ScanImage = PoissonNoise(ScanImage,lambda);
    end
    
    [F(:,:,1),gr,SSE1,SC1] = CalcDefGradientTensor(ScanImage,Settings,ImageInd,g(:,:,i));
    pseudo = gr; 
    
    %Cross-correlate pseudosymmetric orientations
    [~,pseudo(:,:,2:3)] = GetPseudoOrientations(gr);
    RefImage(:,:,1) = genEBSDPatternHybrid_fromEMSoft(pseudo(:,:,1),xstar,ystar,zstar,pixsize,mperpix,elevang,curMaterial,Av,ImageInd);
    RefImage(:,:,2) = genEBSDPatternHybrid_fromEMSoft(pseudo(:,:,2),xstar,ystar,zstar,pixsize,mperpix,elevang,curMaterial,Av,ImageInd);
    RefImage(:,:,3) = genEBSDPatternHybrid_fromEMSoft(pseudo(:,:,3),xstar,ystar,zstar,pixsize,mperpix,elevang,curMaterial,Av,ImageInd);
    [F(:,:,2),SSE2,SC2] = CalcF(RefImage(:,:,2),ScanImage,pseudo(:,:,2),eye(3),ImageInd,Settings,curMaterial,0);
    [F(:,:,3),SSE3,SC3] = CalcF(RefImage(:,:,3),ScanImage,pseudo(:,:,3),eye(3),ImageInd,Settings,curMaterial,0);
    
    %Choose orientation with lowest tetragonality
    tet(i,:) = [CalcTet(F(:,:,1)) CalcTet(F(:,:,2)) CalcTet(F(:,:,3))];
    [~,minInd] = max(tet(i,:));
    orientation(:,:,i,1) = pseudo(:,:,minInd);
    
    %Calculate Cross Correlation Coefficient
    XX1 = CalcCrossCorrelationCoefficient(RefImage(:,:,1),ScanImage);
    XX2 = CalcCrossCorrelationCoefficient(RefImage(:,:,2),ScanImage);
    XX3 = CalcCrossCorrelationCoefficient(RefImage(:,:,3),ScanImage);
    XX(i,:) = [XX1 XX2 XX3];
    [~,maxInd] = max(XX(i,:));
    orientation(:,:,i,2) = pseudo(:,:,maxInd);
    
    %Use Mutual Information
    MI1 = CalcMutualInformation(RefImage(:,:,1),ScanImage);
    MI2 = CalcMutualInformation(RefImage(:,:,2),ScanImage);
    MI3 = CalcMutualInformation(RefImage(:,:,3),ScanImage);
    MI(i,:) = [MI1 MI2 MI3];
    [~,maxInd] = max(MI(i,:));
    orientation(:,:,i,3) = pseudo(:,:,maxInd);
    
    %Shift Confidence
    SC1 = mean(SC1(:,2));
    SC2 = mean(SC2(:,2));
    SC3 = mean(SC3(:,2));
    SC(i,:) = [SC1 SC2 SC3];
    [~,maxInd] = max(SC(i,:));
    orientation(:,:,i,4) = pseudo(:,:,maxInd);
    
    %SSE
    SSE(i,:) = [SSE1 SSE2 SSE3]; 
    [~,minInd] = min(SSE(i,:));
    orientation(:,:,i,5) = pseudo(:,:,minInd);
    
    Index(i) = minInd;
    pseudo_out(:,:,:,i) = pseudo;
    F_out(:,:,:,i) = F; 
    
    h.iterate();
end
close(h);

coefs(:,:,1) = XX;
coefs(:,:,2) = MI;
coefs(:,:,3) = SC;
coefs(:,:,4) = SSE;
stuff.pseudo = pseudo_out;
stuff.Index = Index;
stuff.F = F_out;