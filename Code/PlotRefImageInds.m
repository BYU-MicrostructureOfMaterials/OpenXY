function PlotRefImageInds(RefInds,mapsize,scantype,ax)
if nargin < 4
    ax = gca;
end
Inds = unique(RefInds);
[Xinds,Yinds] = ind2sub2(mapsize,Inds,scantype);
plot(ax,Xinds,Yinds,'kd','MarkerFaceColor','k')