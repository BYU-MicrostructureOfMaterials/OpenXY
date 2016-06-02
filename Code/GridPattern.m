function [Xinds,Yinds,Inds] = GridPattern(arraysize,numpts,plot)
if nargin < 3
    plot = 0;
end
Nx = arraysize(1);
Ny = arraysize(2);

Dx = sqrt(Nx*numpts/Ny);
Dy = (numpts/Dx);
Sx = Nx/(Dx+1);
Sy = Ny/(Dy+1);
Ix = 0:round(Sx):Nx;
Iy = 0:round(Sy):Ny;
Ix = Ix(2:round(Dx)+1);
Iy = Iy(2:round(Dy)+1);
[Xinds,Yinds] = meshgrid(Ix,Iy);
Inds = sub2ind(arraysize,Xinds,Yinds);

if plot
    figure(1)
    cla
    image(ones(Nx,Ny))
    axis equal
    hold on
    scatter(Yinds(:),Xinds(:),'rd')
    numel(Xinds)-numpts
end


