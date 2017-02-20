function miso = GrainMiso(Settings,doplot)
if nargin == 1
    doplot = false;
end
Inds = Settings.Inds;
grainIDList = unique(Settings.grainID(Inds));
numGrains = length(grainIDList);
q = euler2quat(Settings.Angles(Inds,:));
q_symops = rmat2quat(permute(gensymops,[3 2 1]));
miso = zeros(Settings.ScanLength,1);
RefInds = Settings.RefInd(Inds);
for i = 1:numGrains
    gID = grainIDList(i);
    gInds = find(Settings.grainID(Inds) == gID);
    RefInd = RefInds(gInds);
    if std(RefInd) > 0
        disp('Something went wrong')
    end
    RefInd = RefInd(1);
    miso(gInds) = real(quatMisoSym(q(gInds,:),q(RefInd,:),q_symops,'default'));
    
end

if doplot
    GrainMap = vec2map(Settings.grainID,Settings.Nx,Settings.ScanType);
    misomap = vec2map(miso,Settings.Nx,Settings.ScanType);
    RefInds = unique(Settings.RefInd);
    [Xinds,Yinds] = ind2sub2([Settings.Nx Settings.Ny],RefInds,Settings.ScanType);
    figure(1),clf
    imagesc(GrainMap);
    hold on
    plot(Xinds,Yinds,'kd','MarkerFaceColor','k')

    figure(2),clf
    imagesc(misomap*180/pi);
    hold on
    PlotGBs(GrainMap)
    
    disp(['Max Misorientation: ' num2str(max(miso(:))*180/pi) ' degrees']);
end

