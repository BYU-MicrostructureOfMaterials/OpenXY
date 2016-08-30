function PlotScan(im,PlotType)
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
    Limits(2) = Mean*1.5;
end

switch PlotType
    case 'Image Quality'
        imagesc(im,Limits);
        colormap gray
    case 'IPF'
        image(im)
        colormap jet
end
axis image