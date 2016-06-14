function PlotScan(im,PlotType)
%Copy data for Line Scans
if size(im,1) == 1
    im = repmat(im,round(size(im,2)/6),1);
end

StdDev = std(im(:));
Mean = mean(im(:));
Limits(1) = Mean - 3*StdDev;
Limits(2) = Mean + 3*StdDev;

switch PlotType
    case 'Image Quality'
        imagesc(im)
        caxis(Limits)
        colormap gray
    case 'IPF'
        image(im)
        colormap jet
end
axis image