function [misomap,miso] = GrainLocalMiso(Settings)
Mats = unique(Settings.Phase);
if length(Mats) == 1
    M = ReadMaterial(Mats{1});
    [~,miso] = LocalMiso(Settings.Angles,[Settings.Nx Settings.Ny],M.lattice,1);
else
    error('Only Single Phase scans are currently supported for this function')
end

grainID = Settings.grainID;
misomap = zeros(Settings.Ny, Settings.Nx);
for gID = 1:length(unique(grainID))
    IndMap = vec2map((1:Settings.ScanLength)',Settings.Nx,Settings.ScanType);
    TopInd  = circshift(IndMap,1,1);
    BotInd  = circshift(IndMap,-1,1);
    LftInd  = circshift(IndMap,1,2);
    RhtInd  = circshift(IndMap,-1,2);

    grainInds = vec2map(grainID == gID,Settings.Nx,Settings.ScanType);
    top = grainID(TopInd)==gID & grainInds;
    bot = grainID(BotInd)==gID & grainInds;
    lft = grainID(LftInd)==gID & grainInds;
    rht = grainID(RhtInd)==gID & grainInds;

    maxmiso = max(miso(:,:,1).*top,miso(:,:,2).*bot);
    maxmiso = max(maxmiso,miso(:,:,3).*lft);
    maxmiso = max(maxmiso,miso(:,:,4).*rht);

    misomap(grainInds) = maxmiso(grainInds);
end