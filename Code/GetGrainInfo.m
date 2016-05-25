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
    if ~exist(GrainFilePath,'file')
        button = questdlg('No matching grain file was found. Would you like to manually select a grain file?','Grain file not found');
        if strcmp(button,'Yes')
            w = pwd;
            cd(path);
            [name, path] = uigetfile({'*.txt', 'Grain Files (*.txt)'},'Select a Grain File');
            GrainFilePath = fullfile(path,name);
            cd(w);
        else
            error('No grain matching ground file was found');
        end
    end
    GrainFileVals = ReadGrainFile(GrainFilePath);
    grainID = GrainFileVals{9};
    if strcmp(Material,'Auto-detect')
        Phase=lower(GrainFileVals{11});
    else
        Phase = cell(length(GrainFileVals{1}),1);
        Phase(:) = {Material};
    end
    Phase = ValidatePhase(Phase);
    
elseif strcmp(ext,'.ctf')
    Phase = cell(length(Angles),1);
    auto = 0;
    if strcmp(Material,'Auto-detect')
        ind = 1;
        auto = 1;
        if length(ScanParams.material) > 1
            [ind,ok] = listdlg('ListString',ScanParams.material,'PromptString',...
                {'More than one phase detected.';'Mutli-phase scans not currently supported.';'Select one:'},...
                'SelectionMode','single','Name','Select Phase','ListSize',[180 100]);
            if ~ok, ind = 1; end;
        end
        Phase(:)={lower(ScanParams.material{ind})};
        Material = ScanParams.material{ind};
    else
        Phase(:) = {Material};
    end
    Phase = ValidatePhase(Phase);
    if ~isempty(Phase)
        MaterialData = ReadMaterial(Phase{1});
        
        if auto
            disp(['Auto detected material: ' Phase{1}])
        end
        
        %Set up params for findgrains.m
        angles = reshape(Angles,ScanParams.NumColsOdd,ScanParams.NumRows,3);
        clean = true;
        small = true;
        mistol = MaxMisorientation*pi/180;
        [grainID] = findgrains(angles, MaterialData.lattice, clean, small,mistol);
        grainID = reshape(grainID, ScanParams.NumColsOdd*ScanParams.NumRows,1);
    else
        grainID = {};
    end
end
function Phase = ValidatePhase(Phase)
    %Validate Material Detection
    MaterialsList = GetMaterialsList(2);
    if ~all(ismember(Phase,MaterialsList))
        invalidMats = unique(Phase(~ismember(Phase,MaterialsList)));
        er = errordlg(['Auto material detection failed. "' strjoin(invalidMats,', ') '" not found in list of known materials'],'Material Detection');
        uiwait(er)
        op = questdlg('Select an option:','Material Detection Failed','Select Existing Material','Create a New Material','Cancel','Select Existing Material');
        while true
            switch op
                case 'Select Existing Material'
                    Materials = GetMaterialsList(3);
                    [index, ok] = listdlg('PromptString','Select a Material','ListString',Materials,'SelectionMode','single','Name','Material Selection');
                    if ok
                        Phase(:) = {Materials{index}};
                        break;
                    else
                        op = 'Cancel';
                    end
                case 'Create a New Material'
                    material = NewMaterialGUI;
                    if material ~= 0
                        Phase(:) = {material};
                        break;
                    else
                        op = 'Cancel';
                    end
                case 'Cancel'
                    er = warndlg('Material selection failed. Select a new Scan File.','Material Selection');
                    uiwait(er)
                    Phase = {};
                    break;
            end
        end
    end
end

end

