function [Xinds,Yinds,Inds] = GridPattern(arraysize,numpts,plot)
if nargin < 3
    plot = 0;
end
Nx = arraysize(1);
Ny = arraysize(2);
if numpts > Nx*Ny
    numpts = Nx*Ny;
end


Dx = sqrt(Nx*numpts/Ny);
Dy = (numpts/Dx);
Sx = round(Nx/(Dx+1));
Sy = round(Ny/(Dy+1));
Lx = (round(Dx)-1)*Sx;
Ly = (round(Dy)-1)*Sy;
if Lx >= Nx
    Sx = Sx-1;
    Lx = (round(Dx)-1)*Sx;
end
if Ly >= Ny
    Sy = Sy-1;
    Ly = (round(Dy)-1)*Sy;
end
Cx = round((Nx-Lx)/2);
Cy = round((Ny-Ly)/2);
Ix = Cx:Sx:Nx;
Iy = Cy:Sy:Ny;

Ix = Ix(1:round(Dx));
Iy = Iy(1:round(Dy));

[Xinds,Yinds] = meshgrid(Ix,Iy);
Inds = sub2ind(arraysize,Xinds(:),Yinds(:));

if plot
    figure(1)
    cla
    image(ones(Nx,Ny))
    axis equal
    hold on
    scatter(Yinds(:),Xinds(:),'rd')
    numel(Xinds)-numpts
end


