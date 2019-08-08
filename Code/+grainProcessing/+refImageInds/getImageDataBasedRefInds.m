function refInds = getImageDataBasedRefInds(...
    Settings, currentRefInds, mapData, useMin)

import grainProcessing.refImageInds.*;

useMapData = nargin > 2;
useMin = nargin < 4 || useMin;

IQ = Settings.IQ;
CI = Settings.CI;
fit = Settings.Fit;

grainID = Settings.grainID;

refInds = zeros(Settings.ScanLength ,1);
firstGrain = min(grainID);
lastGrain = max(grainID);

for currID = firstGrain:lastGrain
    
    currGrain = find(grainID == currID)';
    if numel(currGrain) == 0
        continue
    end
    
    if ~isnan(currentRefInds(currID))
        refInds(currGrain) = currentRefInds(currID);
        continue
    end
    
    currentCI = CI(currGrain);
    currentIQ = IQ(currGrain);
    currentFit = fit(currGrain);
    
    if useMapData
        currentMapData = mapData(currGrain);
        refInd = getGrainRefInd(...
            currentCI, currentIQ, currentFit, currentMapData, useMin);
    else
        refInd = getGrainRefInd(...
            currentCI, currentIQ, currentFit);
    end
    
    %Give all images in the same grain the new reference image path.
    refInds(currGrain') = currGrain(refInd);
    
    
end

function refInd = getGrainRefInd(CI, IQ, fit, mapData, useMin)

useMapData = nargin > 3;
useMin = nargin < 5 || useMin;

[MaxCI, CIInd] = max(CI);
[MaxIQ, IQInd] = max(IQ);
[MinFit, FitInd] = min(fit);

fitTradeOff =...
    MaxIQ / IQ(FitInd) + ...
    MaxCI / CI(FitInd);
CITradeOff =...
    fit(CIInd) / MinFit + ...
    MaxIQ / IQ(CIInd);
IQTradeOff =...
    fit(IQInd) / MinFit + ...
    MaxCI / CI(IQInd);


if useMapData
    if useMin
        [MinMap, MapInd] = min(mapData);
        
        fitTradeOff = fitTradeOff + ...
            mapData(FitInd) / MinMap;
        CITradeOff = CITradeOff + ...
            mapData(CIInd) / MinMap;
        IQTradeOff = IQTradeOff + ...
            mapData(IQInd) / MinMap;
    else
        [MaxMap, MapInd] = max(mapData);
        
        fitTradeOff = fitTradeOff + ...
            MaxMap / mapData(FitInd);
        CITradeOff = CITradeOff + ...
            MaxMap / mapData(CIInd);
        IQTradeOff = IQTradeOff + ...
            MaxMap / mapData(IQInd);
    end
    
    MapTradeOff =...
        fit(MapInd) / MinFit + ...
        MaxCI / CI(MapInd) + ...
        MaxIQ / IQ(MapInd);
    
    
    
    %Do some voting - rate MapData > IQ > Fit > CI
    Votes = [CIInd FitInd IQInd MapInd];
    [~, VoteInd] = min([CITradeOff fitTradeOff IQTradeOff MapTradeOff]);
else
    Votes = [CIInd FitInd IQInd];
    [~,VoteInd] = min([CITradeOff fitTradeOff IQTradeOff]);
    
end
%Get best reference image in each grain;
refInd = Votes(VoteInd);
