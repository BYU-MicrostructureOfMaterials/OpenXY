function materials = GetMaterialsList
mats = dir('Materials');
materials = {mats([mats.isdir] == 0).name};
materials{1} = 'Auto-detect';
for i = 2:length(materials)
    [~,materials{i},~] = fileparts(materials{i});
end
