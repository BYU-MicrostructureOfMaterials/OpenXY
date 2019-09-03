function [grainAvg, rotQuats, allAvg] = getGrainAverageOrientation(...
    grainIDs, orientations, symOps, confidenceIndex, skipVector)

scanLength = length(grainIDs);

if nargin < 4
    confidenceIndex = ones(scanLength, 1);
end
if nargin < 5
    skipVector = @(x) false;
end


if isequal(size(orientations), [scanLength, 3])
    % Passed in euler angles
    quats = euler2quat(orientations);
elseif isequal(size(orientations), [scanLength, 4])
    % Passed in quaterinons
    quats = orientations;
elseif isequal(size(orientations), [3, 3, scanLength])
    % Passed in g matricies
    quats = rmat2quat(orientations);
else
    error('OpenXY:GetGrainAverageOrientation', ...
        ['Incorrect orientation shape. The argument ''orientations'' '...
        'should be euler angles, g matricies or quaternions'])
end

sz = size(symOps);
if numel(sz) == 3
    if sz(1) ~= 3
        symOps = permute(symOps, [2 3 1]);
    end
    symOps = rmat2quat(symOps);
end

numGrains = max(grainIDs);
grainAvg = zeros(numGrains, 4);
rotQuats = zeros(scanLength, 4);

allAvg = rotQuats;

for ii = 1:numGrains
    if skipVector(ii)
        continue
    end
    currGrain = grainIDs == ii;
    currQuats = quats(currGrain, :);
    currIQ = confidenceIndex(currGrain);
    [grainAvg(ii, :), rotQuats(currGrain, :)] =...
        getAvgQuat(currQuats, symOps, currIQ);
    allAvg(currGrain, :) = repmat(grainAvg(ii, :), sum(currGrain), 1);
end

end

function [avg_q, rot_quats] = getAvgQuat(quats, symOps, confidenceIndex)

[~, best] = max(confidenceIndex);

refQuat = quats(best, :);

numQuats = size(quats, 1);
symQuats = quatmult(symOps, quats, 'noreshape');
symQuats = cat(3, symQuats, - symQuats);

rot_quats = zeros(size(quats));

for ii = 1:numQuats
    curQuats = symQuats(ii, :, :);
    curQuats = reshape(curQuats, size(curQuats, 2), size(curQuats, 3))';
    misos = 2 * acos(refQuat * curQuats');
    [~, minInd] = min(misos);
    rot_quats(ii, :) = curQuats(minInd, :);
end
qMat = rot_quats' * rot_quats;
[v, d] = eig(qMat);
[~, maxInd] = max(max(d));

avg_q = v(:, maxInd)';
if avg_q(1) < 0
    avg_q = -avg_q;
end
end
