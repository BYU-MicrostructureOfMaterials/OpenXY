function materials = GetMaterialsList
mats = dir('Materials');
materials = {mats([mats.isdir] == 0).name};
for i = 1   :length(materials)
    [~,materials{i},~] = fileparts(materials{i});
end
