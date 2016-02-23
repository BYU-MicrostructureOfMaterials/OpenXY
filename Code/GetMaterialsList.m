function materials = GetMaterialsList(option)
% Option:
%   1 = All materials and alteranate names and Auto-detect 
%   2 = All materials and alternatve names
%   anything else = All Materials (no alternative names and no Auto-detect)
if nargin == 0
    option = 1;
end
mats = dir('Materials');
materials = {mats([mats.isdir] == 0).name}';
for i = length(materials):-1:1
    [~,materials{i+1},~] = fileparts(materials{i});
end
if option == 1
    materials{1} = 'Auto-detect';
else
    materials = materials(2:end);
end
if option == 1 || option == 2
    materials = [materials; {'ferrite';'austenite';'aluminium'}];
end
