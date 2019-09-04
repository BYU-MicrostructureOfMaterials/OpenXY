function refInds = getMeanOrientationRefInds(Settings, currentRefInds)

import grainProcessing.refImageInds.*;

grainIDs = Settings.grainID;
CI = Settings.CI;
angles = Settings.Angles;

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

skipVector = ~isnan(currentRefInds);
[grainAvg, symQuats] = grainProcessing.getGrainAverageOrientation(...
    grainIDs, angles, q_symops, CI, skipVector);

refInds = zeros(Settings.ScanLength, 1);
firstGrain = min(grainIDs);
lastGrain = max(grainIDs);

for id = firstGrain:lastGrain
    
    currGrain = find(grainIDs == id);
    if skipVector(id)
        refInds(currGrain) = currentRefInds(id);
        continue;
    end
    avgOrientation = grainAvg(id, :);
    grainOrientations = symQuats(currGrain, :);
    
    misos = quatangle(grainOrientations, avgOrientation);
    [~, bestFit] = min(misos);
    refInds(currGrain) = currGrain(bestFit);
end

end
