function ImageNamesList = ImportImageNamesList(Settings)
X = unique(Settings.XData);
Y = unique(Settings.YData);

%Step size in x and y
if strcmp(Settings.ScanType,'Square')
    XStep = X(2)-X(1);
    if length(Y) > 1
        YStep = Y(2)-Y(1);
    else
        YStep = 0; %Line Scans
    end
else
    XStep = X(3)-X(1);
    YStep = Y(3)-Y(1);
end

%Get Image Names
if ~isempty(Settings.FirstImagePath)
    disp('Generating Image Names List...')
    ImageNamesList = GetImageNamesList(Settings.ScanType, ...
        Settings.ScanLength,[Settings.Nx Settings.Ny], Settings.FirstImagePath, ...
        [Settings.XData(1),Settings.YData(1)], [XStep, YStep]);
end