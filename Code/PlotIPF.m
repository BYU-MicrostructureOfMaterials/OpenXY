function IPF_map = PlotIPF(g,dims,plot)
if nargin < 3
    plot = 1;
end
IPF = IPF_rgbcalc(g);
IPF = real(IPF);
IPF_map(:,:,1) = reshape(IPF(:,1),dims(1),dims(2))';
IPF_map(:,:,2) = reshape(IPF(:,2),dims(1),dims(2))';
IPF_map(:,:,3) = reshape(IPF(:,3),dims(1),dims(2))';
if plot
    image(IPF_map)
end