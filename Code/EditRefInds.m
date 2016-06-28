function RefInd = EditRefInds(grainID,ImageNames,ScanData,mapsize,ScanType,AutoRefInds,ImageFilt,Inds)
if nargin<8
    Inds = 0;
end

%Get background maps
CI = vec2map(ScanData(:,1),mapsize(1),ScanType)./max(ScanData(:,1));
Fit = vec2map(ScanData(:,2),mapsize(1),ScanType)./max(ScanData(:,2));
IQ = vec2map(ScanData(:,3),mapsize(1),ScanType)./max(ScanData(:,3));
bg = 1;
bgtitle = 'none';
pat = -1;

%Title
T = {{'{\bf \fontsize{14} Select 1 reference point per grain}';'{Left-click to select point}';'{Right-click (or SHIFT-click) to change secondary value}';...
    '{Click wheel (or CTRL-click) to view pattern info}';'{RETURN to finish}'},'Interpreter','tex','FontWeight','Normal','FontSize',10};
subT = sprintf('Secondary value: %s',bgtitle);

Nx = mapsize(1);
Ny = mapsize(2);

GrainMap = vec2map(grainID,mapsize(1),ScanType);
if size(GrainMap,1) == 1 %Line Scans
    newsize = round(size(GrainMap,2)/6);
    GrainMap = repmat(GrainMap,newsize,1);
    CI = repmat(CI,newsize,1);
    Fit = repmat(Fit,newsize,1);
    IQ = repmat(IQ,newsize,1);
    mapsize(2) = newsize;
end


morepoints = 1;
npoints = 1;

main = figure(1);
cla
imagesc(GrainMap)
axis image
title(T{:})
xlabel(subT)


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
        if button == 1
            if ishandle(pat); close(pat); end;
            
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
        elseif button == 2
            if ishandle(pat)
                figure(pat)
            else
                pos = get(main,'Position');
                pat = figure('Position',[pos(1)+pos(3)+15 pos(2) pos(3) pos(4)]);
            end
            pattern = ReadEBSDImage(ImageNames{ind,1},ImageFilt);
            imagesc(pattern); colormap gray;
            title(['CI: ' num2str(ScanData(ind,1)) ' Fit: ' num2str(ScanData(ind,2))]);
        elseif button == 3
            bg = bg + 1;
            if bg == 5; bg = 1; end;
        end
    else %Press RETURN
        morepoints = 0;
    end
    
    %Background 
    switch bg
        case 1
            background = ones(mapsize(2),mapsize(1));
            bgtitle = 'none';
        case 2
            background = Fit;
            bgtitle = 'Fit';
        case 3
            background = CI;
            bgtitle = 'Confidence Index';
        case 4
            background = IQ;
            bgtitle = 'Image Quality';
    end
    subT = sprintf('Secondary value: %s',bgtitle);
    
    %Plot Points
    figure(main);
    cla
    imagesc(GrainMap.*background);
    hold on
    plot(Xind,Yind,'kd','MarkerFaceColor','k')
    %title(Title{:})
    axis image
    title(T{:})
    xlabel(subT)
    
    if button == 2
        plot(round(x),round(y),'rd','MarkerFaceColor','r')
    end
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
if ishandle(pat); close(pat); end;
title('')
xlabel('')




