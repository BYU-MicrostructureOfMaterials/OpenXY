function RefInd = EditRefInds(grainID,mapsize,ScanType,AutoRefInds,Inds)
if nargin<5
    Inds = 0;
end

GrainMap = vec2map(grainID,mapsize(1),ScanType);
if size(GrainMap,1) == 1 %Line Scans
    GrainMap = repmat(GrainMap,round(size(GrainMap,2)/6),1);
end
Nx = mapsize(1);
Ny = mapsize(2);

morepoints = 1;
npoints = 1;

figure(1)
cla
imagesc(GrainMap)
axis image

if Inds ~= 0
    hold on
    Grain = grainID(Inds);
    %Remove duplicates
    [Grain,UID] = unique(Grain);
    Inds = Inds(UID);
    npoints = length(Inds)+1;
    
    %Plot Inds
    [Xind,Yind] = ind2sub2([size(GrainMap,2) size(GrainMap,1)],Inds,ScanType);
    plot(Xind,Yind,'kd','MarkerFaceColor','k')
else
    Xind = zeros(1); Yind = zeros(1); Grain = zeros(1);
end

while morepoints
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
        sze = [size(GrainMap,2),size(GrainMap,1)];
        ind = sub2ind2(sze,round(x),round(y),ScanType);
        grn = grainID(ind);
        if button ~= 2
            [La,Lb] = ismember(ind,Inds);
            [Ga,Gb] = ismember(grn,Grain);
            
            if La %De-select Point
                Inds(Lb) = [];
                Xind(Lb) = [];
                Yind(Lb) = [];
                Grain(Lb) = [];
            else
                if Ga %Replace Point in Grain
                    Inds(Gb) = [];
                    Xind(Gb) = [];
                    Yind(Gb) = [];
                    Grain(Gb) = [];
                    npoints = npoints - 1;
                end
                Inds(npoints,1) = ind;
                Xind(npoints,1) = round(x);
                Yind(npoints,1) = round(y);
                Grain(npoints,1) = grn;
            end
            npoints = length(Inds)+1;
        end
        if button == 3 %Exit on Right-Click
            morepoints = 0;
        end
    else %Press RETURN
        morepoints = 0;
    end
    
    %Plot Points
    cla
    imagesc(GrainMap);
    hold on
    plot(Xind,Yind,'kd','MarkerFaceColor','k')
    %title(Title{:})
    axis image
end
[Grains,GrainInds,ic] = unique(grainID);
GrainRefInds = AutoRefInds(GrainInds);
EmptyGrains = Grains(~ismember(Grains,Grain));
[~,sortI] = sort([Grain;EmptyGrains]);
IndsAll = [Inds; GrainRefInds(EmptyGrains)];
IndsAll = IndsAll(sortI);
[Xind,Yind] = ind2sub2(sze,IndsAll,ScanType);

RefInd = IndsAll(ic);

%Plot Points
cla
imagesc(GrainMap);
hold on
plot(Xind,Yind,'kd','MarkerFaceColor','k')
%title(Title{:})
axis image





