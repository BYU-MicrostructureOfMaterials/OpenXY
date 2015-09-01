% changes to PC calibration

Put PhosphorSize in microscope settings gui:
input mperpix=microns/pixel
Settings.PhosphorSize=pixelsize*mperpix

PCCalGUI:
move line 279 to line 271 (note - we are taking out this box and putting it in microscope settings)
lines 272-274 (recalibrate all PCs to 0,0 position before taking mean)
    handles.MeanXstar = mean(Settings.CalibrationPointsPC(:,1)+(Settings.XData(Settings.CalibrationPointIndecies(:)))/psize);
    handles.MeanYstar = mean(Settings.CalibrationPointsPC(:,2))-(Settings.YData(Settings.CalibrationPointIndecies(:)))/psize*sin(Settings.SampleTilt);
    handles.MeanZstar = mean(Settings.CalibrationPointsPC(:,3))-(Settings.YData(Settings.CalibrationPointIndecies(:)))/psize*cos(Settings.SampleTilt);;
    
    
 PCMinSinglePattern:
 New line 2:
 psize=Settings.PhosphorSize;
 lines 2-4
xstar = ScanParams.xstar-(Settings.XData(Ind))/psize;
ystar = ScanParams.ystar+(Settings.YData(Ind))/psize*sin(Settings.SampleTilt);
zstar = ScanParams.zstar+(Settings.YData(Ind))/psize*cos(Settings.SampleTilt);

In case of no PC calibration - use naive plane fit with PC given in .ang.