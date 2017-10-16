function [path, subgrainID, subRefInds] = SubGrainPaths(Settings,doplot)
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
    grainmap = vec2map(Settings.grainID,Settings.Nx,Settings.ScanType);
    imagesc(ax,grainmap)
    hold on
    PlotGBs(Settings.grainID,mapsize,Settings.ScanType);
    colormap jet
    PlotRefImageInds(Settings.RefInd,mapsize,Settings.ScanType);
    
    t = 0.2;
    frame = 1;
    filename = 'SubGrainPaths.gif';
end

% Steps in misorientation between points
misostep = 2;

% Split the grains into subgrains
disp('Splitting grains')
tic
%[subgrainID,subRefInds,subgrains,numsubGrains] = SplitGrains(Settings,Settings.MisoTol);
[subgrainID,subRefInds,subgrains,~] = DivideGrains(Settings);
toc
grainmap = vec2map(subgrainID,Settings.Nx,Settings.ScanType);

% Generate lists of Grains and their Reference Points
numGrains = length(subgrains);
[~, inds] = unique(subgrainID);
subgrainRefs = subRefInds(inds);

[maxmiso,~] = GrainLocalMiso(Settings);
maxmiso = maxmiso*180/pi;

% Get paths from grain reference point to the reference point of each subgrain
disp('Finding paths')
h = waitbar(0,'Getting Paths');
tic
path = cell(numGrains,1);
for curGrain = 1:numGrains
    % Get reference point
    curRef = subgrainRefs(curGrain);
    curRef = mean(Settings.RefInd(Settings.grainID==curGrain));
    curRefXY = ind2sub2(mapsize,curRef,type);
    grainInds = vec2map(Settings.grainID == curGrain,Settings.Nx,Settings.ScanType);
    
    % Get IDs of subgrains
    curSubGrains = subgrains{curGrain};
    % Exclude original grain
    curSubGrains(curSubGrains==curGrain) = [];
    
    if doplot
        [x,y] = ind2sub2(mapsize,curRef,type);
        plot(ax,x,y,'rd','MarkerFaceColor','r')
        pause(0.05)
        drawnow;
        RecordGIF(filename,frame,t)
        frame = frame + 1;
    end
    
    % Loop over all subgrains
    subgrainPaths = cell(length(curSubGrains),2);
    for SubGrainIter = 1:length(curSubGrains)
        attempts = 1;
        curSubGrain = curSubGrains(SubGrainIter);
        curSubGrainRef = subgrainRefs(curSubGrain);
        subGrain = subgrainID == curSubGrain;

        % Get vector between original reference  and subgrain reference
        %vec = VectorPoints(ind2sub2(mapsize,curRef,type),ind2sub2(mapsize,curSubGrainRef,type));
        %vecinds = sub2ind2(mapsize,vec(:,1),vec(:,2),type);
        misostep_inc = 0.1;
        misostep_temp = misostep;
        misomap = maxmiso/misostep_temp;
        misomap(~grainInds) = 1;
        [vec,success,~] = Astar(curRefXY-1,ind2sub2(mapsize,curSubGrainRef,type)-1,misomap);
        
        while ~success
            attempts = attempts + 1;
            if ~mod(attempts,10) || attempts > 60
                fprintf(1,'%u Attempts\n',attempts)
            end
            misostep_temp = misostep_temp + misostep_inc;
            misomap = maxmiso/misostep_temp;
            misomap(~grainInds) = 1;
            %warning(['Planning not successful. Increasing step size to ' num2str(misostep_temp) ' degrees'])
            [vec,success,~] = Astar(ind2sub2(mapsize,curRef,type)-1,ind2sub2(mapsize,curSubGrainRef,type)-1,misomap);
            if misostep_temp > Settings.MisoTol*2
                error('Valid Path Couln''t be found')
            end
        end
        vec = [curRefXY; vec+1];
        vecinds = sub2ind2(mapsize,vec(:,1),vec(:,2),type);

        % Calculate misorientation along vector
        misang = real(quatMisoSym(q(curRef,:),q(vecinds,:),q_symops,'default')*180/pi);
        
        % Find steps of 'misostep' to get to sub reference point
        % Approximates misorientation between points based on the
        % difference in misorientation with the original pattern
        if length(misang) > 1
            maxstep = max(diff(misang));
        else
            maxstep = misang;
        end
        if maxstep > misostep && maxstep < Settings.MisoTol
            %warning(['Increasing step size to ' num2str(maxstep) ' degrees'])
            misostep_temp = maxstep;
        elseif maxstep > Settings.MisoTol
            %warning('Cannot get viable path. Local misorientation is too high')
        end
            
        endmisang = misang(end);
        steps = 1;
        while endmisang >= misostep_temp
            % Get the first step outside of the step tolerance
            next = find((misang-misang(steps(end)))<=misostep_temp);
            % Add index of the point to the list
            steps = [steps next(end)];
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
            drawnow;
            RecordGIF(filename,frame,t)
            frame = frame + 1;
            cla(ax)
            imagesc(ax,grainmap); hold on
            PlotGBs(Settings.grainID,mapsize,Settings.ScanType,ax);
            PlotRefImageInds(subRefInds,mapsize,Settings.ScanType,ax);
        end
        waitbar((curGrain - 1 + SubGrainIter / length(curSubGrains))/numGrains,h)
    end
    if doplot
        cla(ax)
        imagesc(ax,grainmap); hold on
        PlotGBs(Settings.grainID,mapsize,type,ax);
        PlotRefImageInds(subRefInds,mapsize,type,ax);
    end
    path{curGrain} = subgrainPaths;
    waitbar(curGrain/numGrains,h)
end
close(h)
toc




