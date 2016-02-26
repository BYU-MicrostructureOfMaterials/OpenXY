function Settings = CropScan(Settings)
Nx = Settings.Nx;
Ny = Settings.Ny;

Y = unique(Settings.YData);

%Check if complete grid
if (Nx * Ny) ~= Settings.ScanLength && ...
        sum(Settings.YData == Y(end)) ~= sum(Settings.YData == Y(1)) && ...
        sum(Settings.YData == Y(end-1)) == sum(Settings.YData == Y(1))
    disp('Incomplete Grid, cropping last row...')
    Ny = Ny - 1;
    Settings.ScanLength = Nx * Ny;
    Settings.Angles = Settings.Angles(1:Settings.ScanLength,:);
    Settings.XData = Settings.XData(1:Settings.ScanLength,:);
    Settings.YData = Settings.YData(1:Settings.ScanLength,:);
    Settings.IQ = Settings.IQ(1:Settings.ScanLength,:);
    Settings.CI = Settings.CI(1:Settings.ScanLength,:);
    Settings.Fit = Settings.Fit(1:Settings.ScanLength,:);
end
Settings.Nx = Nx;
Settings.Ny = Ny;