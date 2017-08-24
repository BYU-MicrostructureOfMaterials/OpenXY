function UpdateGrainID(Settings)
if strcmp(Settings.GrainMethod,'Grain File')
    Settings.grainID = Settings.GrainVals.grainID;
    return;
end
% Get grainID
Phases = unique(Settings.GrainVals.Phase);
NumPhases = length(Phases);
PhaseLattice = cell(NumPhases,1);
for i = 1:NumPhases
    M = ReadMaterial(Phases{i});
    PhaseLattice{i} = M.lattice;
end
% Check if phases with different lattices exist
if any(~strcmp(PhaseLattice{1},PhaseLattice))
    w = warndlg('Phases with different lattices exist. Grains will be identified using a cubic lattice.');
    uiwait(w,5)
    lattice = 'cubic';
else
    lattice = PhaseLattice{1};
end
angles = vec2map(Settings.Angles,Settings.Nx,Settings.ScanType);
mistol = Settings.MisoTol*pi/180;
MinGrainSize = Settings.MinGrainSize;
clean = MinGrainSize ~= 0;
grainID = findgrains(angles, lattice, clean, MinGrainSize, mistol)';
grainID = reshape(grainID,Settings.Ny,Settings.Nx);
Settings.grainID = reshape(grainID',Settings.Nx*Settings.Ny,1);

