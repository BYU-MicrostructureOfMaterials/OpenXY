function [grainID,RefInds,numGrains] = SplitGrains(Settings,misotol,doplot)
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
%       'misotol' is the maximum allowable misorientation (in radians)
%
%       [optional] 'doplot' plots the progress of the recursive algorithm
%       and the final result
%
%   NOTE: This function requires the Image Processing Toolbox

if nargin == 2
    doplot = false;
end

% Extract variables out of Settings
grainID = Settings.grainID;
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
for i = 1:numGrains0
    gID = grainIDList(i);
    [grainID,numGrains] = SplitGrain(grainID,numGrains,gID);
    
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

    end


end