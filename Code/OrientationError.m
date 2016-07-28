function [MisAng,Correction] = OrientationError(Settings,ScanFilePath,orientation)
ScanFileData = ReadScanFile(ScanFilePath);
CorrectAngles = [ScanFileData{1:3}];

MisAng = zeros(Settings.Nx,1);
Correction = zeros(Settings.Nx,5);
for i = 1:Settings.ScanLength
    %MisAng(i) = GeneralMisoCalc(CorrectAngles(i,:),Settings.NewAngles(i,:),'tetragonal');
    for j = 1:5
        Correction(i,j) = GeneralMisoCalc(euler2gmat(CorrectAngles(i,:)),orientation(:,:,i,j),'tetragonal');
    end
end