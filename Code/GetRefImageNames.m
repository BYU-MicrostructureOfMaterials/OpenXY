
function [RefImageNames, phi1ref, PHIref, phi2ref, RefInd] = GetRefImageNames(ImageNamesList, ScanFileVals, GrainID, MapDataPath, DoUseMin)
%GETREFIMAGENAMES
%[RefImageNames phi1ref PHIref phi2ref GrainID] = GetRefImageNames(ImageNamesList, GrainFilePath, MapDataPath, DoUseMin)
%Given an ImageNamesList and the path for the OIM output file GrainFilePath
%find the best quality images in each grain to use as reference images and
%return this list and their respective orientations and GrainID.
%
%MapDataPath is the file path to map data exported from OIM 5 or 6 - this
%is mostly for the kernel average misorientation but one might have other
%critereon in the same format.
%
%DoUseMin is defaulted to 1/True and should stay that way unless the
%MapDataPath input requires differently.
%Jay Basinger
%March 31, 2011

%DoUseMin = 1 indicates that a minimum of whatever data is passed in via
%MapDataPath is preferred for selecting reference images in each grain.
%DoUseMin = 0 prefers the maximum values in the MapDataPath file
DoUseMapData = 0;
if nargin == 4
    DoUseMapData = 1;
    DoUseMin = 1;
end
if nargin == 5
    DoUseMapData = 1;
end


%Create variables from GrainFileVals
phi1 = ScanFileVals{1}(:,1);
PHI = ScanFileVals{1}(:,2);
phi2 = ScanFileVals{1}(:,3);
IQ = ScanFileVals{2};
CI = ScanFileVals{3};
Fit = ScanFileVals{4};

IndVect = 1:length(GrainID);

GrainID(GrainID==0)=1; % ***************this seems odd **************
RefImageNames = cell(length(ImageNamesList),1);
RefInd = zeros(length(ImageNamesList),1);
%sort by grain ID
for GrnInd = min(GrainID):max(GrainID)
    
    SortedGrainInds{GrnInd} = IndVect(GrainID == GrnInd);
        
    
    if numel(SortedGrainInds{GrnInd}) ~= 0;

        %Get Max CI for each grain;

        [MaxCI(GrnInd) CIInd(GrnInd)] = max(CI(SortedGrainInds{GrnInd}));

    %     [MeanCI(GrnInd) CIMeanInd(GrnInd)] = mean(CI(SortedGrainInds{GrnInd}));
    %     [CISort CISortInd] = sort(CI(SortedGrainInds{GrnInd}));

        %Get Max IQ for each grain;

        [MaxIQ(GrnInd) IQInd(GrnInd)] = max(IQ(SortedGrainInds{GrnInd}));

    %     [MeanIQ(GrnInd) IQMeanInd(GrnInd)] = mean(IQ(SortedGrainInds{GrnInd}));
    %     [IQSort IQSortInd] = sort(IQ(SortedGrainInds{GrnInd}));

        %Get Min Fit

        [MinFit(GrnInd) FitInd(GrnInd)] = min(Fit(SortedGrainInds{GrnInd}));

    %     [MeanFit(GrnInd) FitMeanInd(GrnInd)] = mean(Fit(SortedGrainInds{GrnInd}));
    %     [FitSort FitSortInd] = sort(Fit(SortedGrainInds{GrnInd}));

    %     CIDiff = MaxCI(GrnInd) - MeanCI(GrnInd);
    %     IQDiff = MaxIQ(GrnInd) - MeanIQ(GrnInd);
    %     FitDiff = MeanFit(GrnInd) - MinFit(GrnInd);

        MinFitTradeOff = MaxIQ(GrnInd)/IQ(SortedGrainInds{GrnInd}(FitInd(GrnInd))) + ...
            MaxCI(GrnInd)/CI(SortedGrainInds{GrnInd}(FitInd(GrnInd)));

        MaxCITradeOff = Fit(SortedGrainInds{GrnInd}(CIInd(GrnInd)))/MinFit(GrnInd) + ...
            MaxIQ(GrnInd)/IQ(SortedGrainInds{GrnInd}(CIInd(GrnInd)));

        MaxIQTradeOff = Fit(SortedGrainInds{GrnInd}(IQInd(GrnInd)))/MinFit(GrnInd) + ...
            MaxCI(GrnInd)/CI(SortedGrainInds{GrnInd}(IQInd(GrnInd)));



        if DoUseMapData

            OIMMapVals = ReadOIMMapData(MapDataPath);
            MapData = OIMMapVals{4};%use only the fourth "color" column in the exported OIM map data
            if DoUseMin
                [MapVal(GrnInd) MapInd(GrnInd)] = min(MapData(SortedGrainInds{GrnInd}));
            else
                [MapVal(GrnInd) MapInd(GrnInd)] = max(MapData(SortedGrainInds{GrnInd}));
            end


            %Do some voting - rate MapData > IQ > Fit > CI
            Votes = [CIInd(GrnInd) FitInd(GrnInd) FitInd(GrnInd) IQInd(GrnInd)...
                IQInd(GrnInd) IQInd(GrnInd) MapInd(GrnInd) MapInd(GrnInd) ...
                MapInd(GrnInd) MapInd(GrnInd)];
        else
    %         Votes = [CIInd(GrnInd) FitInd(GrnInd) FitInd(GrnInd) IQInd(GrnInd) IQInd(GrnInd)...
    %              IQInd(GrnInd)];
            Votes = [CIInd(GrnInd) FitInd(GrnInd) IQInd(GrnInd)];
            [TradeOff VoteInd] = min([MaxCITradeOff MinFitTradeOff MaxIQTradeOff]);

        end
        %Get best reference image in each grain;
        BestInd(GrnInd) = Votes(VoteInd);
    %     [MaxVotes(GrnInd) BestInd(GrnInd)] = max(histc(Votes,1:length(CI)));


        %Give all images in the same grain the new reference image path.
        GrainRefName = ImageNamesList(SortedGrainInds{GrnInd}(BestInd(GrnInd)));
        RefImageNames(SortedGrainInds{GrnInd}') = GrainRefName;
        phi1ref(SortedGrainInds{GrnInd}') = phi1(SortedGrainInds{GrnInd}(BestInd(GrnInd)));
        PHIref(SortedGrainInds{GrnInd}') = PHI(SortedGrainInds{GrnInd}(BestInd(GrnInd)));
        phi2ref(SortedGrainInds{GrnInd}') = phi2(SortedGrainInds{GrnInd}(BestInd(GrnInd)));
        RefInd(SortedGrainInds{GrnInd}') = SortedGrainInds{GrnInd}(BestInd(GrnInd));
    end
end
