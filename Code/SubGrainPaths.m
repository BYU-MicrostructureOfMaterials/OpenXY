doplot = 0;
if doplot
    imagesc(grainmap)
    hold on
    PlotGBs(subgrainID,mapsize,Settings.ScanType);
    colormap jet
    PlotRefImageInds(subRefInds,mapsize,Settings.ScanType);
end

q_symops = rmat2quat(permute(gensymops,[3 2 1]));
q = euler2quat(Settings.Angles);
misostep = 2;

disp('Splitting grains')
tic
[subgrainID,subRefInds,subgrains,numsubGrains] = SplitGrains(Settings,Settings.MisoTol);
toc

mapsize = [Settings.Nx,Settings.Ny];G
type = Settings.ScanType;
disp('Getting neighbors')
tic
neighborGrains = GetNeighbors(subgrainID,mapsize,Settings.ScanType);
toc

numGrains = length(subgrains);
[grainList, inds] = unique(Settings.grainID);
grainRefs = Settings.RefInd(inds);

[subgrainList, inds] = unique(subgrainID);
subgrainRefs = subRefInds(inds);

disp('Finding paths')
progressbar;
tic
path = cell(numGrains,1);
for curGrain = 1:numGrains
    
    curRef = subgrainRefs(curGrain);
    SubGrainIter = 1;
    curSubGrains = subgrains{curGrain};
    curSubGrains(curSubGrains==curGrain) = [];
    
    if doplot
        [x,y] = ind2sub2(mapsize,curRef,type);
        plot(x,y,'rd','MarkerFaceColor','r')
    end
    
    subgrainPaths = cell(length(curSubGrains),2);
    for SubGrainIter = 1:length(curSubGrains)
        curSubGrain = curSubGrains(SubGrainIter);

        curSubGrainRef = subgrainRefs(curSubGrain);

        vec = VectorPoints(ind2sub2(mapsize,curRef,type),ind2sub2(mapsize,curSubGrainRef,type));
        vecinds = sub2ind2(mapsize,vec(:,1),vec(:,2),type);

        misang = quatMisoSym(q(curRef,:),q(vecinds,:),q_symops,'default')*180/pi;
        endmisang = misang(end);
        steps = 1;
        while endmisang > misostep
            next = find((misang-misang(steps(end)))>misostep);
            steps = [steps next(1)];
            endmisang = misang(end)-misang(steps(end));
        end
        steps = [steps length(vecinds)];
        subgrainPaths(SubGrainIter,:) = {curSubGrain,vecinds(steps)};

        if doplot
            plot(vec(:,1),vec(:,2),'k*')
            plot(vec(steps,1),vec(steps,2),'rd','MarkerFaceColor','r')
            pause(0.5)
            clf
            imagesc(grainmap); hold on
            PlotGBs(grainID,mapsize,Settings.ScanType);
            PlotRefImageInds(subRefInds,mapsize,Settings.ScanType);
        end
        progressbar([],SubGrainIter/length(curSubGrains))
    end
    if doplot
        clf
        imagesc(grainmap); hold on
        PlotGBs(Settings.grainID,mapsize,Settings.ScanType);
        PlotRefImageInds(subRefInds,mapsize,Settings.ScanType);
    end
    path{curGrain} = subgrainPaths;
    progressbar(curGrain/numGrains)
end
toc
%plot(vec(:,1),vec(:,2),'kd')




