function [grainID refInd] = subGrains(Settings,tolerance)

if ~nargin
    load TESTING.mat Settings
    tolerance = 1;
end

%Get Quaternion symmetry operators
if length(unique(Settings.Phase)) > 1
    %TODO handle Multi-Phase materials
else
    M = ReadMaterial(Settings.Phase{1});
end
lattype = M.lattice;
if strcmp(lattype,'hexagonal')
    q_symops = rmat2quat(permute(gensymopsHex,[3 2 1]));
else
    q_symops = rmat2quat(permute(gensymops,[3 2 1]));
end

%Set up Function for finding refference immages
IQ = Settings.IQ;
CI = Settings.CI;
Fit = Settings.Fit;
grainID = Settings.grainID;
    function newID = getNewRefInd(newGrainIDIn)
        indVec = find(grainID == newGrainIDIn);
        [MaxCI,CIInd] = max(CI(indVec));
        [MinFit,FitInd] = min(Fit(indVec));
        [MaxIQ,IQInd] = max(IQ(indVec));
        
        MaxCITradeoff = Fit(indVec(CIInd))/MinFit + MaxIQ/IQ(indVec(CIInd));
        MinFitTradeOff = MaxIQ/IQ(indVec(FitInd)) + MaxCI/CI(indVec(FitInd));
        MaxIQTradeoff = Fit(indVec(IQInd))/MinFit + MaxCI/CI(indVec(IQInd));
        
        candidates = [CIInd FitInd IQInd];
        
        [~,vote] = min([MaxCITradeoff MinFitTradeOff MaxIQTradeoff]);
        
        newID = indVec(candidates(vote));
    end

%.gif recording stuff for testing, edit doGIF to true to use.
doGIF = false;
if doGIF
    grainIDMap = vec2map(grainID,Settings.Nx,Settings.ScanType);
    figure(314);
    imagesc(grainIDMap);
    axis image
    f = getframe(figure(314));
    [im,map] = rgb2ind(f.cdata,256,'nodither');
end

%The PixleIdxList produced by bwconncomp follows Matlab's matrix indexing
%style of indexing the entire collumn, then row. OpenXY, howerver, does the
%opposite, going row first, then column. This vector is to change between
%the two indexing styles.
IDChangeVec = 1:Settings.ScanLength;
tempMap = vec2map(IDChangeVec',Settings.Ny,Settings.ScanType);
IDChangeVec = map2vec(tempMap');

misoThresh = deg2rad(tolerance);%PLACEHOLDER VALUE

refInds = zeros(max(grainID),1);
currentGrainNumber = min(grainID);
for ii = currentGrainNumber:max(grainID)
    refInds(ii) = getNewRefInd(ii);
end

while currentGrainNumber <= max(grainID)
    currentRefInd = refInds(currentGrainNumber);
    referenceOreintation = euler2quat(Settings.Angles(currentRefInd,:));
    
    currentGrainBool = grainID == currentGrainNumber;
    
    grainOreintations = euler2quat(Settings.Angles(currentGrainBool,:));
    
    goodPoints = false(Settings.ScanLength,1);
    
    goodPoints(currentGrainBool) = quatMisoSym(referenceOreintation,grainOreintations,q_symops) < misoThresh;
    
    goodPointsMap = vec2map(goodPoints,Settings.Nx,Settings.ScanType);
    CC = bwconncomp(goodPointsMap,4);
    
    if CC.NumObjects > 1
        changedRefInd = IDChangeVec(currentRefInd);
        for ii = 1:CC.NumObjects
            if ismember(changedRefInd,CC.PixelIdxList{ii})
                break;
            end
        end
        tempInd = find(1:CC.NumObjects ~= ii);
        for jj = tempInd
            goodPointsMap(CC.PixelIdxList{jj}) = false;
        end
        goodPoints = map2vec(goodPointsMap);
    end
    newGrainsBool = currentGrainBool & ~goodPoints;
    if any(newGrainsBool)
        newGrainsBoolMap = vec2map(newGrainsBool,Settings.Nx,Settings.ScanType);
        
        CC = bwconncomp(newGrainsBoolMap);
        if CC.NumObjects > 1
            L = labelmatrix(CC);
            for ii = 1:CC.NumObjects
                newGrainID = max(grainID) + 1;
                grainID(map2vec(L == ii)) = newGrainID;
                refInds(end + 1) = getNewRefInd(newGrainID);
            end
        else
            newGrainID = max(grainID) + 1;
            grainID(newGrainsBool) = newGrainID;
            refInds(end + 1) = getNewRefInd(newGrainID);
        end
    end
    
    currentGrainNumber = currentGrainNumber + 1;
    if doGIF
        imagesc(vec2map(grainID,Settings.Nx,Settings.ScanType));
        axis image
        f = getframe(figure(314));
        im(:,:,1,currentGrainNumber) = rgb2ind(f.cdata,map,'nodither');
    end
end
if doGIF
    gifName = 'testing.gif';
    imwrite(im,map,gifName,'DelayTime',0.25,'LoopCount',inf)
end

if nargout >= 2
    refInd = zeros(size(grainID));
    for ii = min(grainID):max(grainID)
        refInd(grainID == ii) = refInds(ii);
    end
end

end

%for each grain in Scan
%   find all points whos misorientation from refference point is within a certain tolerance
%   find all of those points that are continuously connected to the refference point
%   append all points not in this new set of points to the end of the Scan as a new grain
%   select reference point in new grain

