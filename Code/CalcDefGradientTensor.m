function CalcDefGradientTensor(RefImage,ScanImage,Settings, ImageInd)
    gr = euler2gmat(Settings.Angles(ImageInd,1),Settings.Angles(ImageInd,2),Settings.Angles(ImageInd,3));
    xstar = Settings.XStar(ImageInd);
    ystar = Settings.YStar(ImageInd);
    zstar = Settings.ZStar(ImageInd);
    pixsize = Settings.PixelSize;
    mperpix = Settings.mperpix;
    elevang = Settings.CameraElevation;
    curMaterial = Settings.Phase{ImageInd};
    Av = Settings.AccelVoltage;
    
    RefImage = genEBSDPatternHybrid_fromEMSoft(gr,xstar,ystar,zstar,pixsize,mperpix,elevang,curMaterial,Av);
        
    clear global rs cs Gs
    [F1,SSE1,XX] = CalcF(RefImage,ScanImage,gr,eye(3),ImageInd,Settings,curMaterial,0);

    for iq=1:5
        [rr,uu]=poldec(F1); % extract the rotation part of the deformation, rr
        gr=rr'*gr; % correct the rotation component of the deformation so that it doesn't affect strain calc
        RefImage = genEBSDPatternHybrid_fromEMSoft(gr,xstar,ystar,zstar,pixsize,mperpix,elevang,curMaterial,Av);

        clear global rs cs Gs
        [F1,SSE1,XX] = CalcF(RefImage,ScanImage,gr,eye(3),ImageInd,Settings,curMaterial,0);
    end
end