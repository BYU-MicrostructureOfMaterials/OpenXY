function im = makeMisoMap(Settings)

refInds = Settings.RefInd;
M = ReadMaterial(Settings.Phase{1});
if strcmp(M.lattice,'hexagonal')
    q_symops = rmat2quat(permute(gensymopsHex,[3 2 1]));
else
    q_symops = rmat2quat(permute(gensymops,[3 2 1]));
end

misos(length(refInds)) = 0;

angles = Settings.Angles;

for ii = 1:length(refInds)
    ind = angles(ii,:);
    ref = angles(refInds(ii),:);
    if all(ind == ref)
        continue;
    end
    q1 = euler2quat(angles(ii,:));
    q2 = euler2quat(angles(refInds(ii),:));
    out = quatMisoSym(q1,q2,q_symops,'default');
    misos(ii) = out;
end

im = rad2deg(vec2map(misos',Settings.Nx,Settings.ScanType));