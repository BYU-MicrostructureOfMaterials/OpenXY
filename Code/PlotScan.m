function PlotScan(im,PlotType)
%Copy data for Line Scans
if size(im,1) == 1
    im = repmat(im,round(size(im,2)/6),1);
end

switch PlotType
    case 'Image Quality'
        imagesc(im)
        colormap gray
    case 'IPF'
        image(im)
        colormap jet
end
axis image