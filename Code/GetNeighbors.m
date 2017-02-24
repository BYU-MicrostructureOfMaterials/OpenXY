function neighbors = GetNeighbors(grainID,mapsize,type)
gIDs = unique(grainID);
grainmap = vec2map(grainID,mapsize(1),type);

bot = circshift(grainmap,1,1);
top = circshift(grainmap,-1,1);
rht = circshift(grainmap,1,2);
lft = circshift(grainmap,-1,2);

sides = false(mapsize(2),mapsize(1),4);
sides(end,:,1) = true; % bot
sides(1,:,2) = true; % top
sides(:,end,3) = true; % right
sides(:,1,4) = true; % left

plot = false;

progressbar('Finding Neighbor Grains')
neighbors = cell(length(gIDs),1);
for i = 1:length(gIDs)
    botn = bot==i & grainmap~=i & ~sides(:,:,2);
    topn = top==i & grainmap~=i & ~sides(:,:,1);
    rhtn = rht==i & grainmap~=i & ~sides(:,:,4);
    lftn = lft==i & grainmap~=i & ~sides(:,:,3);
    perim = botn|topn|rhtn|lftn;
    neighbors{i} = unique(grainmap(perim));
    if plot
        PlotRefImageInds(IDs(botn),mapsize,type);
        PlotRefImageInds(IDs(topn),mapsize,type);
        PlotRefImageInds(IDs(rhtn),mapsize,type);
        PlotRefImageInds(IDs(lftn),mapsize,type);
        cla
        imagesc(grainmap)
    end
    progressbar(i/gIDs)
end