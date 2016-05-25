function [F1,gr,SSE,XX] = CalcDefGradientTensor(ScanImage,Settings,ImageInd,gr)
    if nargin < 4
        gr = euler2gmat(Settings.Angles(ImageInd,1),Settings.Angles(ImageInd,2),Settings.Angles(ImageInd,3));
    end
    
    Settings.XStar(1:Settings.ScanLength) = Settings.ScanParams.xstar-Settings.XData/Settings.PhosphorSize;
    Settings.YStar(1:Settings.ScanLength) = Settings.ScanParams.ystar+Settings.YData/Settings.PhosphorSize*sin(Settings.SampleTilt-Settings.CameraElevation);
    Settings.ZStar(1:Settings.ScanLength) = Settings.ScanParams.zstar+Settings.YData/Settings.PhosphorSize*cos(Settings.SampleTilt-Settings.CameraElevation);
    
    xstar = Settings.XStar(ImageInd);
    ystar = Settings.YStar(ImageInd);
    zstar = Settings.ZStar(ImageInd);
    pixsize = size(ScanImage,1); %Account for binning
    mperpix = Settings.mperpix;
    elevang = Settings.CameraElevation;
    curMaterial = Settings.Phase{ImageInd};
    Av = Settings.AccelVoltage*1000;
    
    [roixc,roiyc]= GetROIs(ScanImage,Settings.NumROIs,pixsize,Settings.ROISize,...
        Settings.ROIStyle);
    Settings.roixc = roixc;
    Settings.roiyc = roiyc;
    Settings.PixelSize = pixsize;
    
    RefImage = genEBSDPatternHybrid_fromEMSoft(gr,xstar,ystar,zstar,pixsize,mperpix,elevang,curMaterial,Av);
    
    clear global rs cs Gs
    [F1,SSE,XX] = CalcF(RefImage,ScanImage,gr,eye(3),ImageInd,Settings,curMaterial,0);

    for iq=1:3
        rr=poldec(F1); % extract the rotation part of the deformation, rr
        gr=rr'*gr; % correct the rotation component of the deformation so that it doesn't affect strain calc
        RefImage = genEBSDPatternHybrid_fromEMSoft(gr,xstar,ystar,zstar,pixsize,mperpix,elevang,curMaterial,Av);

        clear global rs cs Gs
        [F1,SSE,XX] = CalcF(RefImage,ScanImage,gr,eye(3),ImageInd,Settings,curMaterial,0);
    end
    
    rr=poldec(F1); % extract the rotation part of the deformation, rr
    gr=rr'*gr; % correct the rotation component of the deformation so that it doesn't affect strain calc
    
end