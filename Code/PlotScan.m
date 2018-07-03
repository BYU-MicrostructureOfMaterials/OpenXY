function im = PlotScan(im,PlotType)
%Copy data for Line Scans
if size(im,1) == 1
    im = repmat(im,round(size(im,2)/6),1);
end

StdDev = std(im(:));
Mean = mean(im(:));
Limits(1) = Mean - 3*StdDev;
Limits(2) = Mean + 3*StdDev;
if Limits(2)<=Limits(1)
    Limits(1) = Mean*0.5;
    Limits(2) = Mean*1.5 + 1;
end

switch PlotType
    case 'Image Quality'
        im = imagesc(im,Limits);
        colormap(gca,gray)
    case 'IPF'
        im = image(im);
        colormap(gca,jet)
    case 'Misorientation'
        im = imagesc(im);
        colormap(hot)
end
axis image
