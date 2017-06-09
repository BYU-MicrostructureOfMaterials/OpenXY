function RefInd = EditRefInds(Fig,ScanFilePath,grainID,ImageNames,ScanData,...
    mapsize,ScanType,AutoRefInds,imsize,ImageFilt,Inds)
if nargin<8
    Inds = 0;
end

%Get background maps
g = euler2gmat(ScanData(:,4:6));
GrainMap = vec2map(grainID,mapsize(1),ScanType);
CI = vec2map(ScanData(:,1),mapsize(1),ScanType)./max(ScanData(:,1));
Fit = vec2map(ScanData(:,2),mapsize(1),ScanType)./max(ScanData(:,2));
IQ = vec2map(ScanData(:,3),mapsize(1),ScanType)./max(ScanData(:,3));
IPF = PlotIPF(g,mapsize,ScanType,0);
bg = 1;
bgtitle = 'none';
pat = -1;

%Title
T = {{'{\bf \fontsize{14} Select 1 reference point per grain}';'{Left-click to select point}';'{Right-click (or SHIFT-click) to change secondary value}';...
    '{Click wheel (or CTRL-click) to view pattern info}';'{RETURN to finish}'},'Interpreter','tex','FontWeight','Normal','FontSize',10};
subT = sprintf('Secondary value: %s',bgtitle);

Nx = mapsize(1);
Ny = mapsize(2);

Map = GrainMap;
if size(GrainMap,1) == 1 %Line Scans
    newsize = round(size(Map,2)/6);
    Map = repmat(Map,newsize,1);
    CI = repmat(CI,newsize,1);
    Fit = repmat(Fit,newsize,1);
    IQ = repmat(IQ,newsize,1);
    IPF = repmat(IPF,newsize,1,1);
    mapsize(2) = newsize;
end


morepoints = 1;
npoints = 1;

main = figure(Fig);
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
    [Xind,Yind] = ind2sub2([size(Map,2) size(Map,1)],Inds,ScanType);
    plot(Xind,Yind,'kd','MarkerFaceColor','k')
else
    Xind = zeros(1); Yind = zeros(1); Grain = zeros(1);
end

while morepoints
    %Gets X,Y data from user
    try
    [x,y, button] = ginput(1);
    catch ME
       if strcmp(ME.identifier,'MATLAB:ginput:FigureDeletionPause')
           x = [];
           y = [];
           button = [];
       else
           rethrow(ME)
       end
    end
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
    sze = [size(Map,2),size(Map,1)];
    
    if ~isempty(x)   
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
            if ~isempty(ImageNames)
                if size(ImageNames,1)>1
                    pattern = ReadEBSDImage(ImageNames{ind,1},ImageFilt);
                else
                    pattern = ReadH5Pattern(ScanFilePath,ImageNames,...
                        imsize,ImageFilt,ind);
                end
            else
                pattern = imread('NoImage.jpg');
            end
            imagesc(pattern); colormap gray;
            title(['CI: ' num2str(ScanData(ind,1)) ' Fit: ' num2str(ScanData(ind,2))]);
            pause(.25)
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
            Map = GrainMap;
            bgtitle = 'grainID';
        case 2
            Map = IPF;
            bgtitle = 'IPF';
        case 3
            Map = CI;
            bgtitle = 'Confidence Index';
        case 4
            Map = IQ;
            bgtitle = 'Image Quality';
        case 5
            Map = Fit;
            bgtitle = 'Fit';
    end
    subT = sprintf('Secondary value: %s',bgtitle);
    
    %Plot Points
    if ishandle(main)
        figure(main);
        cla
        imagesc(Map);
        hold on
        plot(Xind,Yind,'kd','MarkerFaceColor','k')
        %title(Title{:})
        axis image
        title(T{:})
        xlabel(subT)
    end
    
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
if ishandle(main)
    cla
    imagesc(Map);
    hold on
    plot(Xind,Yind,'kd','MarkerFaceColor','k')
    %title(Title{:})
    axis image
    title('')
    xlabel('')
end
if ishandle(pat); close(pat); end;




