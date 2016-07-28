function [orientation,tet] = CorrectPseudoSymmetry(Settings)
    Settings = HREBSDPrep(Settings);
    
    BinningScale = 1;
    lambda = 500;
    
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
    
    %ScanFileData = ReadScanFile('/Volumes/Shared/TiAl/Scans/TiAl_Sim_Line_Short.ctf');
    %CorrectAngles = [ScanFileData{1:3}];
    
    
    %Initialize Variables
    tet_corr = repmat({zeros(3,3)},Settings.ScanLength,1);
    XX_corr = tet_corr;
    MI_corr = tet_corr;
    SC_corr = tet_corr;
    SSE_corr = tet_corr;
    tet = zeros(Settings.ScanLength,3);
    
    %Get Inds
    if ~isfield(Settings,'Inds')
        Settings.Inds = (1:Settings.ScanLength)';
    end
    
    %Set up parallel processing
    Settings.DoParallel = 2;
    if Settings.DoParallel > 1
        ppool = gcp('nocreate');
        if isempty(ppool)
            parpool(Settings.DoParallel);
        end 
        if ~any(strcmp(javaclasspath,fullfile(pwd,'java')))
            pctRunOnAll javaaddpath('java')
        end
    else
        if ~any(strcmp(javaclasspath,fullfile(pwd,'java')))
            javaaddpath('java')
        end
    end
    tic
    
    
    disp('Starting cross-correlation');
    ppm = ParforProgMon('Cross Correlation Analysis ',Settings.ScanLength,1,400,50);
    %h = waitbar(0,'Pseudo Progress');
    
    %Extract variables from Settings to reduce parfor overhead
    Inds = Settings.Inds;
    XStar = Settings.XStar(Inds);
    YStar = Settings.YStar(Inds);
    ZStar = Settings.ZStar(Inds);
    Angles = Settings.Angles(Inds,:);
    ImNames = Settings.ImageNamesList(Inds);
    ImageFilter = Settings.ImageFilter;
    
    %Use Tetragonality to Correct Psuedosymmetry
    for i = 1:Settings.ScanLength
        
        F = zeros(3,3,3);
        XX = zeros(3,1);
        MI = zeros(3,1);
        SC = zeros(3,1);
        SSE = zeros(3,1);
        
        ImageInd = Inds(i);
        
        %Get variables from Settings
        xstar = XStar(i);
        ystar = YStar(i);
        zstar = ZStar(i);
        curMaterial = 'TiAl';%Settings.Phase{ImageInd};

        %Extract cross-correlation information
        g = euler2gmat(Angles(i,:));
        
        %Re-read in EBSD Image
        ScanImage = ReadEBSDImage(ImNames{i},ImageFilter);
        ScanImage = PoissonNoise(imresize(ScanImage,BinningScale),lambda);
        
        %Get other possible orientations
        %[~,pseudo(:,:,2:3)] = GetPseudoOrientations(pseudo);
        %For each orientation generate a pattern and compare to scan image
%         RefImage1 = genEBSDPatternHybrid_fromEMSoft(pseudo(:,:,1),xstar,ystar,zstar,pixsize,mperpix,elevang,curMaterial,Av);
%         RefImage2 = genEBSDPatternHybrid_fromEMSoft(pseudo(:,:,2),xstar,ystar,zstar,pixsize,mperpix,elevang,curMaterial,Av);
%         RefImage3 = genEBSDPatternHybrid_fromEMSoft(pseudo(:,:,3),xstar,ystar,zstar,pixsize,mperpix,elevang,curMaterial,Av);
%         [F1,SSE1,XX1] = CalcF(RefImage1,ScanImage,pseudo(:,:,1),eye(3),ImageInd,Settings,curMaterial,0);
%         [F2,SSE2,XX2] = CalcF(RefImage2,ScanImage,pseudo(:,:,2),eye(3),ImageInd,Settings,curMaterial,0);
%         [F3,SSE3,XX3] = CalcF(RefImage3,ScanImage,pseudo(:,:,3),eye(3),ImageInd,Settings,curMaterial,0);
        
        %Settings.DoShowPlot = 1;
        
        [F(:,:,1),gr,SSE1,XX1] = CalcDefGradientTensor(ScanImage,Settings,ImageInd,g);
        pseudo = gr;
        
        
        %Correct PseudoSymmetry
        [~,pseudo(:,:,2:3)] = GetPseudoOrientations(gr);
        RefImage1 = genEBSDPatternHybrid_fromEMSoft(pseudo(:,:,1),xstar,ystar,zstar,pixsize,mperpix,elevang,curMaterial,Av,ImageInd);
        RefImage2 = genEBSDPatternHybrid_fromEMSoft(pseudo(:,:,2),xstar,ystar,zstar,pixsize,mperpix,elevang,curMaterial,Av,ImageInd);
        RefImage3 = genEBSDPatternHybrid_fromEMSoft(pseudo(:,:,3),xstar,ystar,zstar,pixsize,mperpix,elevang,curMaterial,Av,ImageInd);
        [F(:,:,2),SSE2,XX2] = CalcF(RefImage2,ScanImage,pseudo(:,:,2),eye(3),ImageInd,Settings,curMaterial,0);
        [F(:,:,3),SSE3,XX3] = CalcF(RefImage3,ScanImage,pseudo(:,:,3),eye(3),ImageInd,Settings,curMaterial,0);
        
        %Choose orientation with lowest tetragonality
        tet(i,:) = [CalcTet(F(:,:,1)) CalcTet(F(:,:,2)) CalcTet(F(:,:,3))];
        [~,minInd] = max(tet(i,:));
        
        %if GeneralMisoCalc(pseudo(:,:,minInd),euler2gmat(CorrectAngles(ImageInd,:)),'tetragonal')>1
        %    disp('Greater than 1');
        %end
        
        %[~,gr] = CalcDefGradientTensor(ScanImage,Settings,ImageInd,pseudo(:,:,minInd));
        tet_corr{i} = pseudo(:,:,minInd);
            
        %Choose orientation with highest cross-correlation coefficient
        XX(1) = CrossCorrelationCoefficient(RefImage1,ScanImage);
        XX(2) = CrossCorrelationCoefficient(RefImage2,ScanImage);
        XX(3) = CrossCorrelationCoefficient(RefImage3,ScanImage);
        [~,maxInd] = max(XX);
        XX_corr{i} = pseudo(:,:,maxInd);
        
        %Choose orientation with highest Mutual Information
        MI(1) = CalcMutualInformation(RefImage1,ScanImage);
        MI(2) = CalcMutualInformation(RefImage2,ScanImage);
        MI(3) = CalcMutualInformation(RefImage3,ScanImage);
        [~,maxInd] = max(MI);
        MI_corr{i} = pseudo(:,:,maxInd);
        
        %Choose orientation with highest shift confidence
        SC(1) = mean(XX1(:,3));
        SC(2) = mean(XX2(:,3));
        SC(3) = mean(XX3(:,3));
        [~,maxInd] = max(SC);
        SC_corr{i} = pseudo(:,:,maxInd);
        
        %Choose orientation with lowest SSE
        SSE(1) = SSE1;
        SSE(2) = SSE2;
        SSE(3) = SSE3;
        [~,minInd] = min(SSE);
        SSE_corr{i} = pseudo(:,:,minInd);
        
        ppm.increment();
        %waitbar(i/Settings.ScanLength,h);
    end
    assignin('base','tet_corr','tet_corr_import');
    ppm.delete();
    
    orientation = [tet_corr XX_corr MI_corr SC_corr SSE_corr];
    toc
    `
end