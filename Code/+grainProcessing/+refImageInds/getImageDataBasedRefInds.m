function refInds = getImageDataBasedRefInds(Settings, mapData, useMin)

import grainProcessing.refImageInds.*;

useMapData = nargin > 1;
useMin = nargin < 3 || useMin;

IQ = Settings.IQ;
CI = Settings.CI;
fit = Settings.Fit;

grainID = Settings.grainID;

refInds = zeros(size(IQ,1),1);
firstGrain = min(grainID);
lastGrain = max(grainID);

for currID = firstGrain:lastGrain
    
    currGrain = find(grainID == currID)';
    if numel(currGrain) == 0
        continue
    end
    
    currentCI = CI(currGrain);
    currentIQ = IQ(currGrain);
    currentFit = fit(currGrain);
    
    if useMapData
        currentMapData = mapData(currGrain);
        refInd = ImageDataBasedGrainRefInd(...
            currentCI, currentIQ, currentFit, currentMapData, useMin);
    else
        refInd = ImageDataBasedGrainRefInd(...
            currentCI, currentIQ, currentFit);
    end
    
    %Give all images in the same grain the new reference image path.
    refInds(currGrain') = currGrain(refInd);
    
    
end
