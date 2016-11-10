function Settings = CropScan(Settings)
Nx = Settings.Nx;
Ny = Settings.Ny;

Y = unique(Settings.YData);
cropped = false;

%Check if complete grid
if strcmp(Settings.ScanType,'Square')
    if (Nx * Ny) ~= Settings.ScanLength && ...
            sum(Settings.YData == Y(end)) ~= sum(Settings.YData == Y(1)) && ... % Last row has different number of points than the first
            sum(Settings.YData == Y(end-1)) == sum(Settings.YData == Y(1))      % Second to last row has same number of points as the first
        Ny = Ny - 1;
        Settings.ScanLength = Nx * Ny;
        cropped = true;
    end
elseif strcmp(Settings.ScanType,'Hexagonal')
    % Account for changing number of points per row
    extra = 0;
    if mod(Ny,2) == 0 % Even
        extra = 1;
    end
    if HexLength(Nx,Ny) ~= Settings.ScanLength && ...
            sum(Settings.YData == Y(end)) ~= (sum(Settings.YData == Y(1)) + extra) && ... % Last row has different number of points than the first
            sum(Settings.YData == Y(end-1)) ~= (sum(Settings.YData == Y(1)) + extra)      % Second to last row has same number of points as the first
        Ny = Ny - 1;
        Settings.ScanLength = HexLength(Ny,Ny);
        cropped = true;
    end
end
if cropped
    disp('Incomplete Grid, cropping last row...')
    Inds = 1:Settings.ScanLength;
    Settings.Angles = Settings.Angles(Inds,:);
    Settings.XData = Settings.XData(Inds,:);
    Settings.YData = Settings.YData(Inds,:);
    Settings.IQ = Settings.IQ(Inds,:);
    Settings.CI = Settings.CI(Inds,:);
    Settings.Fit = Settings.Fit(Inds,:);
    Settings.grainID = Settings.grainID(Inds,:);
    Settings.Phase = Settings.Phase(Inds,:);
end
Settings.Nx = Nx;
Settings.Ny = Ny;