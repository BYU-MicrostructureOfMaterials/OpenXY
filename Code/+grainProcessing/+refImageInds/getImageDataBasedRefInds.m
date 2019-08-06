function refInds = getImageDataBasedRefInds(Settings, mapData)

useMapData = nargin > 1;

IQ = Settings.IQ;
CI = Settings.CI;
fit = Settings.Fit;

grainID = Settings.grainID;
IndVect = 1:length(grainID);

RefInd = zeros(size(IQ,1),1);
firstGrain = min(grainID);
lastGrain = max(grainID);

for currID = firstGrain:lastGrain
    
    currGrain = IndVect(grainID == currID);
    
    if numel(currGrain) == 0
        continue
    end
    
    [MaxCI, CIInd] = max(CI(currGrain));
    [MaxIQ, IQInd] = max(IQ(currGrain));
    [MinFit, FitInd] = min(fit(currGrain));
    
    fitTradeOff =...
        MaxIQ / IQ(currGrain(FitInd)) + ...
        MaxCI / CI(currGrain(FitInd));
    CITradeOff =...
        fit(currGrain(CIInd)) / MinFit + ...
        MaxIQ / IQ(currGrain(CIInd));
    IQTradeOff =...
        fit(currGrain(IQInd)) / MinFit + ...
        MaxCI / CI(currGrain(IQInd));

    
    if useMapData
        if DoUseMin
            [MinMap, MapInd] = min(mapData(currGrain));
            
            fitTradeOff = fitTradeOff + ...
                mapData(currGrain(FitInd)) / MinMap;
            CITradeOff = CITradeOff + ...
                mapData(currGrain(CIInd)) / MinMap;
            IQTradeOff = IQTradeOff + ...
                mapData(currGrain(IQInd)) / MinMap;
        else
            [MaxMap, MapInd] = max(mapData(currGrain));
            
            fitTradeOff = fitTradeOff + ...
                MaxMap / mapData(currGrain(FitInd));
            CITradeOff = CITradeOff + ...
                MaxMap / mapData(currGrain(CIInd));
            IQTradeOff = IQTradeOff + ...
                MaxMap / mapData(currGrain(IQInd));
        end
        
        MapTradeOff =...
            fit(currGrain(MapInd)) / MinFit + ...
            MaxCI / CI(currGrain(MapInd)) + ...
            MaxIQ / IQ(currGrain(MapInd));
        
        
        
        %Do some voting - rate MapData > IQ > Fit > CI
        Votes = [CIInd FitInd IQInd MapInd];
        [~, VoteInd] = min([CITradeOff fitTradeOff IQTradeOff MapTradeOff]);
    else
        Votes = [CIInd FitInd IQInd];
        [~,VoteInd] = min([CITradeOff fitTradeOff IQTradeOff]);
        
    end
    %Get best reference image in each grain;
    BestInd = Votes(VoteInd);
    
    %Give all images in the same grain the new reference image path.
    RefInd(currGrain') = currGrain(BestInd);
    
    
end
