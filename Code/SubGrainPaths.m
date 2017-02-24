function path = SubGrainPaths(Settings,doplot)
if nargin == 1
    doplot = 0;
end

% Prepare Variables
q_symops = rmat2quat(permute(gensymops,[3 2 1]));
q = euler2quat(Settings.Angles);
mapsize = [Settings.Nx,Settings.Ny];
type = Settings.ScanType;

if doplot
    figure(1)
    ax = axes;
    imagesc(ax,grainmap)
    hold on
    PlotGBs(Settings.grainID,mapsize,Settings.ScanType);
    colormap jet
    PlotRefImageInds(Settings.RefInd,mapsize,Settings.ScanType);
end

% Steps in misorientation between points
misostep = 2;

% Split the grains into subgrains
disp('Splitting grains')
profile on
tic
%[subgrainID,subRefInds,subgrains,numsubGrains] = SplitGrains(Settings,Settings.MisoTol);
[subgrainID,subRefInds,subgrains,~] = DivideGrains(Settings);
toc
profile off

% Generate lists of Grains and their Reference Points
numGrains = length(subgrains);
[~, inds] = unique(subgrainID);
subgrainRefs = subRefInds(inds);

% Get paths from grain reference point to the reference point of each subgrain
disp('Finding paths')
progressbar;
tic
path = cell(numGrains,1);
for curGrain = 1:numGrains
    % Get reference point
    curRef = subgrainRefs(curGrain);
    
    % Get IDs of subgrains
    curSubGrains = subgrains{curGrain};
    % Exclude original grain
    curSubGrains(curSubGrains==curGrain) = [];
    
    if doplot
        [x,y] = ind2sub2(mapsize,curRef,type);
        plot(ax,x,y,'rd','MarkerFaceColor','r')
        pause(0.05)
    end
    
    % Loop over all subgrains
    subgrainPaths = cell(length(curSubGrains),2);
    for SubGrainIter = 1:length(curSubGrains)
        curSubGrain = curSubGrains(SubGrainIter);
        curSubGrainRef = subgrainRefs(curSubGrain);

        % Get vector between original reference  and subgrain reference
        vec = VectorPoints(ind2sub2(mapsize,curRef,type),ind2sub2(mapsize,curSubGrainRef,type));
        vecinds = sub2ind2(mapsize,vec(:,1),vec(:,2),type);

        % Calculate misorientation along vector
        misang = quatMisoSym(q(curRef,:),q(vecinds,:),q_symops,'default')*180/pi;
        
        % Find steps of 'misostep' to get to sub reference point
        % Approximates misorientation between points based on the
        % difference in misorientation with the original pattern
        endmisang = misang(end);
        steps = 1;
        while endmisang > misostep
            % Get the first step outside of the step tolerance
            next = find((misang-misang(steps(end)))>misostep);
            % Add index of the point to the list
            steps = [steps next(1)];
            % Update the misorientation to the end
            endmisang = misang(end)-misang(steps(end));
        end
        % Add last point
        steps = [steps length(vecinds)];
        % Store map indices of step points
        subgrainPaths(SubGrainIter,:) = {curSubGrain,vecinds(steps)};

        if doplot
            plot(ax,vec(:,1),vec(:,2),'k*')
            plot(ax,vec(steps,1),vec(steps,2),'rd','MarkerFaceColor','r')
            pause(0.5)
            cla(ax)
            imagesc(ax,grainmap); hold on
            PlotGBs(Settings.grainID,mapsize,Settings.ScanType,ax);
            PlotRefImageInds(subRefInds,mapsize,Settings.ScanType,ax);
        end
        progressbar([],SubGrainIter/length(curSubGrains))
    end
    if doplot
        cla(ax)
        imagesc(ax,grainmap); hold on
        PlotGBs(Settings.grainID,mapsize,type,ax);
        PlotRefImageInds(subRefInds,mapsize,type,ax);
    end
    path{curGrain} = subgrainPaths;
    progressbar(curGrain/numGrains)
end
toc




