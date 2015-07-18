function materials = GetMaterialsList
mats = dir('Materials');
materials = {mats([mats.isdir] == 0).name}';
for i = length(materials):-1:1
    [~,materials{i+1},~] = fileparts(materials{i});
end
materials{1} = 'Auto-detect';
materials = [materials; {'ferrite';'austenite';'aluminium'}];
