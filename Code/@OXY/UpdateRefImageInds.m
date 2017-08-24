
function UpdateRefImageInds(obj)
%UpdateRefImageInds
%Ref Ind = UpdateRefImageInds(ScanFileVals, GrainID, MapDataPath, DoUseMin)
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
%
%Revised from GetRefImageNames to only return indices of reference images. ImageNamesList no
%longer passed in - Brian Jackson, June 2016


DoUseMapData = 0;
if strcmp(obj.GrainRefImageType,'Min Kernel Avg Miso')
    DoUseMapData = 1;
    DoUseMin = 1;%#ok
end
DoUseMin = 1;

%Create variables from GrainFileVals
IQ = obj.IQ;
CI = obj.CI;
Fit = obj.Fit;
GrainID = obj.grainID;

IndVect = 1:length(GrainID);

GrainID(GrainID==0)=1; % ***************this seems odd **************
RefInd = zeros(size(IQ,1),1);

%sort by grain ID
for GrnInd = unique(GrainID)'
    
    SortedGrainInds = IndVect(GrainID == GrnInd);
        
    
    if numel(SortedGrainInds) ~= 0

        %Get Max CI for each grain;

        [MaxCI,CIInd] = max(CI(SortedGrainInds));


        %Get Max IQ for each grain;

        [MaxIQ,IQInd] = max(IQ(SortedGrainInds));


        %Get Min Fit

        [MinFit,FitInd] = min(Fit(SortedGrainInds));


        MinFitTradeOff = MaxIQ/IQ(SortedGrainInds(FitInd)) + ...
            MaxCI/CI(SortedGrainInds(FitInd));

        MaxCITradeOff = Fit(SortedGrainInds(CIInd))/MinFit + ...
            MaxIQ/IQ(SortedGrainInds(CIInd));

        MaxIQTradeOff = Fit(SortedGrainInds(IQInd))/MinFit + ...
            MaxCI/CI(SortedGrainInds(IQInd));



        if DoUseMapData

            OIMMapVals = ReadOIMMapData(obj.KernelAvgMisoPath);
            MapData = OIMMapVals{4};%use only the fourth "color" column in the exported OIM map data
            if DoUseMin
                [~,MapInd] = min(MapData(SortedGrainInds));
            else
                [~,MapInd] = max(MapData(SortedGrainInds));
            end


            %Do some voting - rate MapData > IQ > Fit > CI
            Votes = [CIInd FitInd FitInd IQInd...
                IQInd IQInd MapInd MapInd ...
                MapInd MapInd];
        else
            Votes = [CIInd FitInd IQInd];
            [~,VoteInd] = min([MaxCITradeOff MinFitTradeOff MaxIQTradeOff]);

        end
        %Get best reference image in each grain;
        BestInd = Votes(VoteInd);


        %Give all images in the same grain the new reference image path.
        RefInd(SortedGrainInds') = SortedGrainInds(BestInd);
    end
end

obj.RefInd = RefInd;
