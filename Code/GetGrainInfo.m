function [ grainID, Phase ] = GetGrainInfo( ScanFilePath, Material, ScanParams, Angles, MaxMisorientation )
%GETGRAININFO Returns grainID and material for HKL and OIM data
%   INPUTS: ScanFilePath-Full path to .ang or .ctf file
%           Material-Manual material selection from MainGUI. Looks for 'Auto-detect' parameter
%           ScanParams-Struct of info gathered from ScanFile
%           Angles-ScanLength x 3 matrix of euler angles, from ScanFile.
%               Used by findgrain.m for HKL data.
%           MaxMisorientation-Param need for findgrains.m
%
%   OUTPUT: grainID-vector of integers of ScanLength with grain assignments.
%               Uses findgrain.m for HKL data and the grainfile for OIM data
%           Phase-vector of strings of ScanLength with material name. Will
%               assign it to Material input or auto-detect it from scan data
%
%   ASSUMPTIONS:
%           Grain file has the same name as the .ang file
%
%   Written by Brian Jackson 4/28/2015

[path, name, ext] = fileparts(ScanFilePath);
if strcmp(ext,'.ang')
    GrainFilePath = fullfile(path,[name '.txt']);
    GrainFileVals = ReadGrainFile(GrainFilePath);
    grainID = GrainFileVals{9};
    if strcmp(Material,'Auto-detect')
        Phase=lower(GrainFileVals{11});
    else
        Phase = cell(length(GrainFileVals),1);
        Phase(:) = {Material};
    end
elseif strcmp(ext,'.ctf')
    Phase = cell(length(Angles),1); 
    if strcmp(Material,'Auto-detect')
        %Determine if material from .ctf/.cpr file is in list of known materials
        MaterialsList = GetMaterialsList;
        if strmatch(lower(ScanParams.material),MaterialsList,'exact')
            MaterialData = ReadMaterial(ScanParams.material);
            Phase(:)={lower(ScanParams.material)};
        else
            error(['Auto material detection failed. ' lower(ScanParams.material) ' not found in list of known materials']);
        end
    else
        Phase(:) = {Material};
        MaterialData = ReadMaterial(Material);
    end
    
    %Set up params for findgrains.m
    angles = reshape(Angles,Nx,Ny,3);
    clean = true;
    small = true;
    mistol = MaxMisorientation*pi/180;
    [Settings.grainID] = findgrains(angles, MaterialData.lattice, clean, small,mistol);
end

end

