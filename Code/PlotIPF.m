function IPF_map = PlotIPF(g,dims,ScanType,plot)
if nargin < 4
    plot = 1;
end
IPF = IPF_rgbcalc(g);
IPF = real(IPF);
if strcmp(ScanType,'Square')
    IPF_map(:,:,1) = reshape(IPF(:,1),dims(1),dims(2))';
    IPF_map(:,:,2) = reshape(IPF(:,2),dims(1),dims(2))';
    IPF_map(:,:,3) = reshape(IPF(:,3),dims(1),dims(2))';
elseif strcmp(ScanType,'Hexagonal')
    IPF_map(:,:,1) = Hex2Array(IPF(:,1),dims(1));
    IPF_map(:,:,2) = Hex2Array(IPF(:,2),dims(1));
    IPF_map(:,:,3) = Hex2Array(IPF(:,3), dims(1));
end
if plot
    image(IPF_map)
end