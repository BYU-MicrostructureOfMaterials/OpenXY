function M = ReadMaterial(Material)
% Reads material data from text file in /Materials subfolder into a
% structure
if strcmp(Material,'newphase')
    Material='iron-alpha';
end
if strcmp(Material,'Austenite') || strcmp(Material,'austenite')
    Material='iron-gamma';
end
if strcmp(Material,'Ferrite') || strcmp(Material,'ferrite')
    Material='iron-alpha';
end

filename = fullfile(pwd,'Materials',[Material '.txt']);

if exist(filename,'file')
    fid = fopen(fullfile(pwd,'Materials',[Material '.txt']));
    % Import each line into a structure with field names determined by file
    while ~feof(fid)
        tline = fgetl(fid);
        [parname, value] = strtok(tline);
        if ~strcmp(parname,'Material') && ~strcmp(parname,'lattice')
            value = sscanf(value,'%f');
        else
            value = strtrim(value);
        end
        M.(parname)= value;
    end
    % Reshape hkl with correct number of columns
    if isfield(M,'hkl')
        if strcmp(M.lattice, 'hexagonal')
            LatticeNumber = 4;
        else
            LatticeNumber = 3;
        end
        M.hkl = reshape(M.hkl,LatticeNumber,[])';
    end
    fclose(fid);
else
    warndlg('Material file not found');
end
 {'Mg','Cu','Mg (a systems only)','Ta','Ta (with 112 planes)','Mg(no a-pyram)','Ni','Ni(18ss)','Al-18ss'};
%SplitDD info
switch lower(Material)
    case 'nickel'
        M.SplitDD = {'Ni','Ni(18ss)'};
    case 'magnesium'
        M.SplitDD = {'Mg','Mg (a systems only)'};
    case 'copper'
        M.SplitDD = {'Cu'};
    case 'tantalum'
        M.SplitDD = {'Ta','Ta (with 112 planes)'};
    case 'aluminum'
        M.SplitDD = {'Al-18ss'};
end
        
        
        
        
        