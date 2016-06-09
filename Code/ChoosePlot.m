function [im,sel] = ChoosePlot(mapsize,IQ,Angles)
%Convert angles to gmat
Nx = mapsize(1);
Ny = mapsize(2);
ScanLength = Nx*Ny;
g = zeros(3,3,ScanLength);
for i = 1:ScanLength
    g(:,:,i) = euler2gmat(Angles(i,:));
end

%Ask image type
sel = questdlg('Select Image to Display','Resize Scan','Image Quality','IPF','Image Quality');
if strcmp(sel,'Image Quality')
    im = reshape(IQ,Nx,Ny)';
elseif strcmp(sel,'IPF')
    im = PlotIPF(g,[Nx Ny],0);
end