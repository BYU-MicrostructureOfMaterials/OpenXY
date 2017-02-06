function [grainID,RefInds,subgrains,numGrains] = SplitGrains(Settings,misotol,doplot)
%SPLITGRAINS Splits grains into smaller grains based on a misorientation
%tolerance
%
%   This function calculates the misorientation within each grain relative
%   to the reference pattern. If the misorientation is over the specified
%   tolerance ('misotol') then the algorithm will assign all points outside
%   the tolerance to a new grain. The algorithm uses the Image Processing
%   Toolbox to check if the region is one consecutive region or several
%   smaller regions and assigns new grains as necessary.
%
%   [grainID, RefInds, numGrains] = SplitGrains(Settings,misotol,doplot)
%       'grainID' is the new vector of grain IDs with misorientations under
%       'misotol'
%
%       'RefInds' is the new vector of reference indices
%
%       'numGrains' is the new number of total grains
%       
%       'misotol' is the maximum allowable misorientation (in degrees)
%
%       [optional] 'doplot' plots the progress of the recursive algorithm
%       and the final result
%
%   NOTE: This function requires the Image Processing Toolbox

if nargin == 2
    doplot = false;
end

% Convert misotol to radians
misotol = misotol*pi/180;

% Extract variables out of Settings
grainID = Settings.grainID;
grainID0 = grainID;
RefInds = Settings.RefInd;
IQ = Settings.IQ;
Fit = Settings.Fit;
CI = Settings.CI;
ScanType = Settings.ScanType;
mapsize = [Settings.Ny Settings.Nx];

% Convert angles to quaternions
q = euler2quat(Settings.Angles);
q_symops = rmat2quat(permute(gensymops,[3 2 1]));

% Get Grain List
grainIDList = unique(Settings.grainID);
numGrains = length(grainIDList);

% Iterate over each of the original grains
numGrains0 = numGrains;
subgrains = cell(numGrains0,1);
progressbar;
for i = 1:numGrains0
    gID = grainIDList(i);
    [grainID,numGrains] = SplitGrain(grainID,numGrains,gID);
    subgrains(i) = {unique(grainID(grainID0 == i))};
    progressbar(i/numGrains0)
end

% Plot the new map
if doplot
    Settings.grainID = grainID;
    Settings.RefInd = RefInds;
    GrainMiso(Settings,true);
end
    
    % Recursive Function
    function [grainID,numGrains] = SplitGrain(grainID,numGrains,gID)
        % Get Indices for the grain
        gInds = find(grainID == gID);
        RefInd = RefInds(gInds);
        if std(RefInd) > 0
            disp('Something went wrong')
        end
        RefInd = RefInd(1);
        
        % Calculate the misorientation from reference pattern
        miso = zeros(size(grainID));
        miso(gInds) = real(quatMisoSym(q(gInds,:,:),q(RefInd,:),q_symops,'default'));
        
        % Create maps
        GrainMap = vec2map(grainID,mapsize(2),ScanType);
        misomap = vec2map(miso,mapsize(2),ScanType);
        
        % Plot the misorientation within the grain (and the reference point)
        if doplot
            figure(1)
            imagesc(misomap*180/pi)
            hold on
            PlotGBs(GrainMap)
            [Xinds,Yinds] = ind2sub2(fliplr(mapsize),RefInd,ScanType);
            plot(Xinds,Yinds,'rd','MarkerFaceColor','r')
            pause(0.1)
        end
        
        % Identify regions of the grain that are outside the tolerance
        newGrain = GrainMap == gID & misomap > misotol;
        
        % Use Image Processing Toolbox to identify distinct regions
        CC = bwconncomp(newGrain',4);
        
        % Recursively split up sub-regions
        for j = 1:CC.NumObjects
            % Increment grain number count
            numGrains = numGrains + 1;
            
            % Assign new grain number
            grainID(CC.PixelIdxList{j}) = numGrains;
            
            % Find new reference point
            RefInds(CC.PixelIdxList{j}) = GetRefInd(CC.PixelIdxList{j},IQ,Fit,CI);
            
            % Plot new sub-grain
            [Xinds,Yinds] = ind2sub2(fliplr(mapsize),CC.PixelIdxList{j},ScanType);
            if doplot;plot(Xinds,Yinds,'kd','MarkerFaceColor','k');end
            
            % Recursively split grain
            [grainID,numGrains] = SplitGrain(grainID,numGrains,numGrains);
        end
        
        % Check if leftover grain has more than 1 piece
        oldGrain = GrainMap == gID & misomap <= misotol;
        CC = bwconncomp(oldGrain',4);
        if CC.NumObjects > 1
            % Find new reference point
            RefInds(CC.PixelIdxList{1}) = GetRefInd(CC.PixelIdxList{1},IQ,Fit,CI);
            
            for j = 2:CC.NumObjects
                % Increment grain number count
                numGrains = numGrains + 1;

                % Assign new grain number
                grainID(CC.PixelIdxList{j}) = numGrains;

                % Find new reference point
                RefInds(CC.PixelIdxList{j}) = GetRefInd(CC.PixelIdxList{j},IQ,Fit,CI);

                % Plot new sub-grain
                [Xinds,Yinds] = ind2sub2(fliplr(mapsize),CC.PixelIdxList{j},ScanType);
                if doplot;plot(Xinds,Yinds,'kd','MarkerFaceColor','k');end
            end
            
        end
    end


end