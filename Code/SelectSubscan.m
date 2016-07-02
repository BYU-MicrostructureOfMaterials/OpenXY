function [X,Y] = SelectSubscan(im,PlotType)

selectfig = figure;
PlotScan(im,PlotType)
axis image
title('Press RETURN key to select area');

[Ny,Nx,~] = size(im);

redo = 1;
X = [];
Y = [];
while redo
    Xind = [];
    Yind = [];
    npoints = 1;
    while (npoints < 3) && (redo)
        %Gets X,Y data from user
        [x,y, button] = ginput(1);
        if x > Nx
            x = Nx;
        elseif x < 1
            x = 1;
        end
        if y > Ny
            y = Ny;
        elseif y < 1
            y = 1;
        end
        if ~isempty(x)
            Xind(npoints) = round(x);
            Yind(npoints) = round(y);
            npoints = npoints + 1;
        elseif isempty(button) && (npoints == 1) && (~isempty(X)) %RETURN key is pressed
            redo = 0;
            break;
        end   

        hold off
        PlotScan(im,PlotType)
        axis image
        hold on
        plot(Xind,Yind,'kd','MarkerFaceColor','k');
    end
    if redo
        X(1) = min(Xind);
        X(2) = max(Xind);
        Y(1) = min(Yind);
        Y(2) = max(Yind);
        offset = 0.6;
        xbox = [X(1)-offset X(1)-offset; X(1)-offset X(2)+offset; X(1)-offset X(2)+offset; X(2)+offset X(2)+offset]';
        ybox = [Y(1)-offset Y(2)+offset; Y(1)-offset Y(1)-offset; Y(2)+offset Y(2)+offset; Y(1)-offset Y(2)+offset]';
        plot(xbox,ybox,'k','LineWidth',2)
    end
end
close(selectfig);