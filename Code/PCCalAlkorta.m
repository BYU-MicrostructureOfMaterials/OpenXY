function PCData = PCCalAlkorta(Settings,PlaneFit,Inds)

if nargin < 3
    %Select Calibration Points
    button = questdlg('Point selection type?','Select Type','Manual','Grid','Manual');
    switch button
        case 'Manual'
            Inds = SelectCalibrationPoints([Settings.Nx,Settings.Ny],...
                Settings.IQ,Settings.Angles);
        case 'Grid'
            input = inputdlg('Enter Number of Points.\n(will be rounded to the nearest square number)');
            nPoints = str2num(input{1});
            [~,~,Inds] = GridPattern([Settings.Nx Settings.Ny],nPoints);
        otherwise
            return;
    end
end

%I may want to make these adjustable variables in the GUI? ZRC 
CICutoff = 0.1;
FitCutoff = 1.2;

goodInds = Settings.CI(Inds) > CICutoff & Settings.Fit(Inds) < FitCutoff;
removedInds = Inds(~goodInds);
Inds = Inds(goodInds);

fprintf('Starting calibriations with %u points.\n',length(Inds))

if strcmp(Settings.HROIMMethod,'Dynamic Simulated')
    PCData = PCCalAlkortaEMSoft(Settings,PlaneFit,Inds);
else
    PCData = PCCalAlkortaKinematic(Settings,PlaneFit,Inds);
end

PCData.removedInds = removedInds;