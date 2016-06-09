function PlotScan(im,PlotType)
switch PlotType
    case 'Image Quality'
        imagesc(im)
        colormap gray
    case 'IPF'
        image(im)
        colormap jet
end
axis image