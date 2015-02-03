function  [ Fhkl hkl C11 C12 C44 lattice a1 b1 c1 dhkl axs str C13 C33 C66 Burgers] = SelectMaterial(Material)
%returns material parameters for materials in the "str" list. If the
%Material string is not found

if strcmp(Material,'newphase')
    Material='iron-alpha';
end
if strcmp(Material,'Austenite') || strcmp(Material,'austenite')
    Material='iron-gamma';
end
if strcmp(Material,'Ferrite') || strcmp(Material,'ferrite')
    Material='iron-alpha';
end

M = ReadMaterial(Material);
Default = ReadMaterial('grainfile');
Default.str = {};
if isfield(M,'Fhkl')
    Fhkl = M.Fhkl;
else
    Fhkl = Default.Fhkl;
end
if isfield(M,'dhkl')
    dhkl = M.dhkl;
else
    dhkl = Default.dhkl;
end
if isfield(M,'hkl')
    hkl = M.hkl;
else
    hkl = Default.hkl;
end
if isfield(M,'C11')
    C11 = M.C11;
else
    C11 = Default.C11;
end
if isfield(M,'C12')
    C12 = M.C12;
else
    C12 = Default.C12;
end
if isfield(M,'C13')
    C13 = M.C13;
else
    C13 = Default.C13;
end
if isfield(M,'C33')
    C33 = M.C33;
else
    C33 = Default.C33;
end
if isfield(M,'C44')
    C44 = M.C44;
else
    C44 = Default.C44;
end
if isfield(M,'C66')
    C66 = M.C66;
else
    C66 = Default.C66;
end
if isfield(M,'lattice')
    lattice = M.lattice;
else
    lattice = Default.lattice;
end
if isfield(M,'a1')
    a1 = M.a1;
else
    a1 = Default.a1;
end
if isfield(M,'b1')
    b1 = M.b1;
else
    b1 = Default.b1;
end
if isfield(M,'c1')
    c1 = M.c1;
else
    c1 = Default.c1;
end
if isfield(M,'axs')
    axs = M.axs;
else
    axs = Default.axs;
end
if isfield(M,'str')
    str = M.str;
else
    str = Default.str;
end
if isfield(M,'Burgers')
    Burgers = M.axs;
else
    Burgers = Default.axs;
end

