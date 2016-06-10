function [im,sel] = ChoosePlot(mapsize,IQ,Angles)
%Determine ScanType
Nx = mapsize(1);
Ny = mapsize(2);
ScanLength = length(IQ);
if prod(mapsize) == ScanLength
    ScanType = 'Square';
elseif prod(mapsize)*3 == ScanLength
    ScanType = 'LGrid';
else
    ScanType = 'Hexagonal';
end

%Convert angles to gmat
g = euler2gmat(Angles);

%Ask image type
sel = questdlg('Select Image to Display','Resize Scan','Image Quality','IPF','Image Quality');
if strcmp(sel,'Image Quality')
    if strcmp(ScanType,'Square')
        im = reshape(IQ,Nx,Ny)';
    elseif strcmp(ScanType,'Hexagonal')
        im = Hex2Array(IQ,mapsize(1));
    end
elseif strcmp(sel,'IPF')
    im = PlotIPF(g,[Nx Ny],ScanType,0);
end