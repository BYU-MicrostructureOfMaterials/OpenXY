function PlotRefImageInds(RefInds,mapsize,scantype)
Inds = unique(RefInds);
[Xinds,Yinds] = ind2sub2(mapsize,Inds,scantype);
plot(Xinds,Yinds,'kd','MarkerFaceColor','k')