function updatePC(Settings)
index = Settings.PCInd;
type = Settings.PCList{index,4};
if strcmp(type,'Tiff')||strcmp(type,'Alkorta')
    Settings.XStar = Settings.PCList{index,7}.XStar;
    Settings.YStar = Settings.PCList{index,7}.YStar;
    Settings.ZStar = Settings.PCList{index,7}.ZStar;
else
    xstar = Settings.PCList{index,1};
    ystar = Settings.PCList{index,2};
    zstar = Settings.PCList{index,3}; 
    if strcmp(Settings.PCList{index,5},'Naive')
        Settings.XStar = xstar - Settings.XData/Settings.PhosphorSize;
        detector_angle = pi/2 - Settings.SampleTilt + Settings.CameraElevation;
        Settings.YStar = ystar + Settings.YData/Settings.PhosphorSize*cos(detector_angle);
        Settings.ZStar = zstar + Settings.YData/Settings.PhosphorSize*sin(detector_angle);
    else
        Settings.XStar(:) = xstar;
        Settings.YStar(:) = ystar;
        Settings.ZStar(:) = zstar;
    end
    
end
Settings.notify('PCEvent');