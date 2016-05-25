function orientation = CorrectPseudoSymmetry(Settings)

    BinningScale = 0.25;
    lambda = 0.1;
    
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
    
    ScanFileData = ReadScanFile('/Volumes/Shared/TiAl/Scans/TiAl_Sim.ctf');
    CorrectAngles = [ScanFileData{1:3}];
    
    
    %Initialize Variables
    tet_corr = repmat({zeros(3,3)},Settings.ScanLength,1);
    XX_corr = tet_corr;
    MI_corr = tet_corr;
    SC_corr = tet_corr;
    SSE_corr = tet_corr;
    
    w = waitbar(0,'Progress');
    tic
    
    %Use Tetragonality to Correct Psuedosymmetry
    for ImageInd = 1:Settings.ScanLength/Settings.Ny
        
        %Get variables from Settings
        xstar = Settings.XStar(ImageInd);
        ystar = Settings.YStar(ImageInd);
        zstar = Settings.ZStar(ImageInd);
        curMaterial = 'TiAl';%Settings.Phase{ImageInd};

        %Extract cross-correlation information
        g = euler2gmat(Settings.Angles(ImageInd,:));
        F(:,:,1) = Settings.data.F{ImageInd};
        XX1 = Settings.XX{ImageInd};
        SSE1 = Settings.data.SSE{ImageInd};
        
        %Re-read in EBSD Image
        ScanImage = ReadEBSDImage(Settings.ImageNamesList{ImageInd},Settings.ImageFilter);
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
        
        Settings.DoShowPlot = 1;
        
        [F(:,:,1),gr,SSE1,XX1] = CalcDefGradientTensor(ScanImage,Settings,ImageInd,g);
        pseudo = gr;
        
        
        %Correct PseudoSymmetry
        [~,pseudo(:,:,2:3)] = GetPseudoOrientations(gr);
        RefImage1 = genEBSDPatternHybrid_fromEMSoft(pseudo(:,:,1),xstar,ystar,zstar,pixsize,mperpix,elevang,curMaterial,Av);
        RefImage2 = genEBSDPatternHybrid_fromEMSoft(pseudo(:,:,2),xstar,ystar,zstar,pixsize,mperpix,elevang,curMaterial,Av);
        RefImage3 = genEBSDPatternHybrid_fromEMSoft(pseudo(:,:,3),xstar,ystar,zstar,pixsize,mperpix,elevang,curMaterial,Av);
        [F(:,:,2),SSE2,XX2] = CalcF(RefImage2,ScanImage,pseudo(:,:,2),eye(3),ImageInd,Settings,curMaterial,0);
        [F(:,:,3),SSE3,XX3] = CalcF(RefImage3,ScanImage,pseudo(:,:,3),eye(3),ImageInd,Settings,curMaterial,0);
        
        %Choose orientation with lowest tetragonality
        tet(1) = CalcTet(F(:,:,1));
        tet(2) = CalcTet(F(:,:,2));
        tet(3) = CalcTet(F(:,:,3));
        [~,minInd] = min(abs(tet));
        
        if GeneralMisoCalc(pseudo(:,:,minInd),euler2gmat(CorrectAngles(ImageInd,:)),'tetragonal')>1
            disp('Greater than 1');
        end
        
        %[~,gr] = CalcDefGradientTensor(ScanImage,Settings,ImageInd,pseudo(:,:,minInd));
        tet_corr{ImageInd} = pseudo(:,:,minInd);
            
        %Choose orientation with highest cross-correlation coefficient
        XX(1) = CrossCorrelationCoefficient(RefImage1,ScanImage);
        XX(2) = CrossCorrelationCoefficient(RefImage2,ScanImage);
        XX(3) = CrossCorrelationCoefficient(RefImage3,ScanImage);
        [~,maxInd] = max(XX);
        XX_corr{ImageInd} = pseudo(:,:,maxInd);
        
        %Choose orientation with highest Mutual Information
        MI(1) = CalcMutualInformation(RefImage1,ScanImage);
        MI(2) = CalcMutualInformation(RefImage2,ScanImage);
        MI(3) = CalcMutualInformation(RefImage3,ScanImage);
        [~,maxInd] = max(MI);
        MI_corr{ImageInd} = pseudo(:,:,maxInd);
        
        %Choose orientation with highest shift confidence
        SC(1) = mean(XX1(:,3));
        SC(2) = mean(XX2(:,3));
        SC(3) = mean(XX3(:,3));
        [~,maxInd] = max(SC);
        SC_corr{ImageInd} = pseudo(:,:,maxInd);
        
        %Choose orientation with lowest SSE
        SSE(1) = SSE1;
        SSE(2) = SSE2;
        SSE(3) = SSE3;
        [~,minInd] = min(SSE);
        SSE_corr{ImageInd} = pseudo(:,:,minInd);
        
        waitbar(ImageInd/(Settings.ScanLength/Settings.Ny),w);
    end
    orientation = [tet_corr XX_corr MI_corr SC_corr SSE_corr];
    toc
    
end