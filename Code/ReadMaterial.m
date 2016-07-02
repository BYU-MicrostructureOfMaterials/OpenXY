function M = ReadMaterial(Material)
% Reads material data from text file in /Materials subfolder into a
% structure
if strcmp(Material,'newphase')
    Material='iron-alpha';
end
if strcmpi(Material,'Austenite')
    Material='iron-gamma';
end
if strcmpi(Material,'Ferrite')
    Material='iron-alpha';
end
if strcmpi(Material,'aluminium')
    Material = 'aluminum';
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
        if strcmp(M.lattice, 'hexagonal')
                hkil = M.hkl;
                hkl = zeros(size(hkil,1),3);
                for i = 1:size(hkil,1)
                    hkl(i,1) = 3/2*hkil(i,1);
                    hkl(i,2) = sqrt(3)/2*(hkil(i,1)+2*hkil(i,2));
                    hkl(i,3) = 3/2*1/(M.c1/M.a1)*hkil(i,4);
                end
                M.hkl_hex = M.hkl;
                M.hkl = hkl;
        end
    end
    fclose(fid);
else
    warndlg('Material file not found');
    M = {};
end

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
    case 'iron-alpha'
        M.SplitDD = {'Fe'};
end
        
        
        
        
        
