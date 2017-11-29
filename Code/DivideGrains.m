function [subgrainID,subRefInds,subgrains,numGrains] =  DivideGrains(Settings)
grainmap = vec2map(Settings.grainID,Settings.Nx,Settings.ScanType);
numGrains = length(unique(grainmap));
grainmap0 = grainmap;
numGrains0 = numGrains;
RefMap = vec2map(Settings.RefInd,Settings.Nx,Settings.ScanType);
q = euler2quat(Settings.Angles);
q_symops = rmat2quat(permute(gensymops,[3 2 1]));
subgrains = cell(numGrains0,1);

plot = false;
if plot
    figure(1)
%     filename = 'DivideGrains.gif';
%     frame = 1;
%     t = 0.1;
end
h = waitbar(0,'Dividing Grains');
for gID = 1:numGrains0
    SplitGrain(gID);
    subgrains(gID) = {unique(grainmap(grainmap0 == gID))};
    waitbar(gID/numGrains0,h)
end
subgrainID = map2vec(grainmap,Settings.ScanType);
subRefInds = map2vec(RefMap,Settings.ScanType);
close(h);

    function SplitGrain(gID)
        gmap = grainmap==gID;
        gInds = find(gmap');
        if numel(gInds) == 1; return; end
        RefInd = RefMap(gmap);
        if std(RefInd) > 0
            disp('Something went wrong')
        end
        RefInd = RefInd(1);
        
        % Calculate the misorientation from reference pattern
        miso = zeros(Settings.ScanLength,1);
        miso(gInds) = real(quatMisoSym(q(gInds,:,:),q(RefInd,:),q_symops,'default'));
        misomap = vec2map(miso,Settings.Nx,Settings.ScanType)*180/pi;
        
        if plot
            figure(1);
            clf; imagesc(misomap); hold on; caxis([0,Settings.MisoTol]); colormap jet
            PlotRefImageInds(RefInd,[Settings.Nx,Settings.Ny],Settings.ScanType);
            PlotGBs(grainmap);
            drawnow;
%             RecordGIF(filename,frame,t)
%             frame = frame + 1;
        end
        
        percentout = sum(miso*180/pi > Settings.MisoTol)/length(gInds);
        if percentout > 0.001
            stats = regionprops(gmap,'Centroid','Orientation');
            m = tand(180-stats(1).Orientation+90);
            [X,Y] = meshgrid(1:Settings.Nx,1:Settings.Ny);
            bot = (Y > m*(X-stats(1).Centroid(1))+stats(1).Centroid(2)) & gmap;
            top = ~bot & gmap;
            numGrains = numGrains + 1;
            newGrainNum = numGrains;
            grainmap(bot) = newGrainNum;
            
            RefMap(bot) = GetRefInd(find(bot'),Settings.IQ,Settings.Fit,Settings.CI);
            RefMap(top) = GetRefInd(find(top'),Settings.IQ,Settings.Fit,Settings.CI);
            
            SplitGrain(gID);
            SplitGrain(newGrainNum);
        end
    end

end