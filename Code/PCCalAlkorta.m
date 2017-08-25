function PCData = PCCalAlkorta(Settings,PlaneFit,Inds)

if nargin < 3
    %Select Calibration Points
    Inds = SelectCalibrationPoints([Settings.Nx,Settings.Ny],...
        Settings.IQ,Settings.Angles);
end

%I may want to make these adjustable variables in the GUI? ZRC 
CICutoff = 0.1;
FitCutoff = 1.2;

goodInds = Settings.CI(Inds) > CICutoff & Settings.Fit(Inds) < FitCutoff;
removedInds = Inds(~goodInds);
Inds = Inds(goodInds);

if strcmp(Settings.HROIMMethod,'Dynamic Simulated')
    PCData = PCCalAlkortaEMSoft(Settings,PlaneFit,Inds);
else
    PCData = PCCalAlkortaKinematic(Settings,PlaneFit,Inds);
end

PCData.removedInds = removedInds;