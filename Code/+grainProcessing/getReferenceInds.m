function refInds = getReferenceInds(Settings)

import grainProcessing.refImageInds.*;

switch Settings.GrainRefImageType
    case 'Min Kernel Avg Miso'
        OIM_mapValues = ReadOIMMapData(Settings.KernelAvgMisoPath);
        refInds = getImageDataBasedRefInds(Settings, OIM_mapValues{4});
    case 'IQ > Fit > CI'
        refInds = getImageDataBasedRefInds(Settings);
    case 'Grain Mean Orientation'
    case 'Manual'
        %Figure this out later...
    otherwise
        error('OpenXY:UnknownRefImageType',...
            '%s is not a recognized reference image type.',...
            Settings.GrainRefImageType)
end

end

