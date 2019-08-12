function [refInds, sortedRefInds] = getReferenceInds(Settings, currentRefInds)

if nargin < 2
    uniqueGrains = length(unique(Settings.grainID));
    currentRefInds = nan(uniqueGrains, 1);
end

import grainProcessing.refImageInds.*;

switch Settings.GrainRefImageType
    case 'Min Kernel Avg Miso'
        OIM_mapValues = ReadOIMMapData(Settings.KernelAvgMisoPath);
        refInds = getImageDataBasedRefInds(...
            Settings, currentRefInds, OIM_mapValues{4});
    case {'IQ > Fit > CI', 'Manual'}
        refInds = getImageDataBasedRefInds(Settings, currentRefInds);
    case 'Grain Mean Orientation'
        refInds = getMeanOrientationRefInds(Settings, currentRefInds);
    otherwise
        error('OpenXY:UnknownRefImageType',...
            '%s is not a recognized reference image type.',...
            Settings.GrainRefImageType)
end

if nargout > 1
    [sortedGrains, sortedOrder] = sort(Settings.grainID);
    [~, ia] = unique(sortedGrains);
    grainIds = sortedOrder(ia);
    sortedRefInds = refInds(grainIds);
end

end

