function PCData = PCGrid(Settings,PCSettings)
if nargin == 1
    numpats=10;  % number of points to take from scan
    numpc=40;    % number of PC points to take in each dimension (about 2 points per hour for a grid of 10x10x10 PCs)
    deltapc=0.06/numpc;   %step size for PC grid search
    [~,~,Inds] = GridPattern([Settings.Nx Settings.Ny],numpats);
else
    numpats = PCSettings.numpats;
    numpc = PCSettings.numpc;
    deltapc = PCSettings.deltapc;
    if isfield(PCSettings,'CalibrationIndices')
        Inds = PCSettings.CalibrationIndices;
    else
        [~,~,Inds] = GridPattern([Settings.Nx Settings.Ny],numpats);
    end
end

tic

%Try to filter out useless points based on CI and Fit
Inds = Inds(Settings.CI(Inds) > 0.1 & Settings.Fit(Inds) < 1.2);
numpats = length(Inds);

%Apply Naive Plane Fit
xstar = Settings.ScanParams.xstar-Settings.XData/Settings.PhosphorSize;
ystar = Settings.ScanParams.ystar+Settings.YData/Settings.PhosphorSize*sin(Settings.SampleTilt-Settings.CameraElevation);
zstar = Settings.ScanParams.zstar+Settings.YData/Settings.PhosphorSize*cos(Settings.SampleTilt-Settings.CameraElevation);

%Extract out Settings
Av = Settings.AccelVoltage*1000; %put it in eV from KeV
sampletilt = Settings.SampleTilt;
elevang = Settings.CameraElevation;
pixsize = Settings.PixelSize;
if length(unique(Settings.Phase)) == 1
    Material = ReadMaterial(Settings.Phase{1});
end
if ~strcmp('Intensity',Settings.ROIStyle)
    [roixc,roiyc]= GetROIs(zeros(Settings.Nx,Settings.Ny),Settings.NumROIs,pixsize,Settings.ROISize,...
        Settings.ROIStyle);
    Settings.roixc = roixc;
    Settings.roiyc = roiyc;
end

pctest = zeros(length(Inds),numpc);
PCvals = zeros(length(Inds),numpc);

for dir = 1:3
    for qq=1:numpats
        Ind=Inds(qq);
        PC0(1) = xstar(qq);
        PC0(2) = ystar(qq);
        PC0(3) = zstar(qq);
        if length(unique(Settings.Phase)) > 1
            Material = ReadMaterial(Settings.Phase{Ind});
        end
        
        star = PC0(dir);
        
        ImagePath = Settings.ImageNamesList{Ind};
        ScanImage = ReadEBSDImage(ImagePath,Settings.ImageFilter);
        if strcmp('Intensity',Settings.ROIStyle)
            [roixc,roiyc]= GetROIs(ScanImage,Settings.NumROIs,pixsize,Settings.ROISize,...
                Settings.ROIStyle);
            Settings.roixc = roixc;
            Settings.roiyc = roiyc;
        end
        g = euler2gmat(Settings.Angles(Ind,1)+0.05,Settings.Angles(Ind,2),Settings.Angles(Ind,3)); % DTF - don't use ref angles for grain as is done on previous line!!
        
        PCvals(qq,:) = star+((1:numpc)-1-(numpc-1)/2)*deltapc;
        for xx=1:numpc
            PC0(dir) = PCvals(qq,xx);
            paramspat={PC0(1);PC0(2);PC0(3);pixsize;Av;sampletilt;elevang;Material.Fhkl;Material.dhkl;Material.hkl};
            [pctest(qq,xx),~,F]=CalcNormFMod(PC0,ScanImage,paramspat,Material.lattice,Material.a1,Material.b1,Material.c1,Material.axs,g,Settings.ImageFilter,Ind,Settings);
            R = poldec(F);
            %g = R'*g; %Use Corrected Orientation
        end
        
        %Show Progress
        switch dir
            case 1
                disp(['XStar Point ' num2str(qq)])
            case 2
                disp(['YStar Point ' num2str(qq)])
            case 3
                disp(['ZStar Point ' num2str(qq)])
        end
    end
    toc
    
    PCopt = EvalPCGrid(pctest,PCvals,0);
    
    PCnew(dir) = PCopt;
    PCData.PCPoints(:,:,dir) = PCvals;
    PCData.StrainPoints(:,:,dir) = pctest;
end

PCData.CalibrationIndices = Inds;
PCData.xstar = PCnew(1);
PCData.ystar = PCnew(2);
PCData.zstar = PCnew(3);
PCData.numpats = numpats;
PCData.numpc = numpc;
PCData.deltapc = deltapc;

