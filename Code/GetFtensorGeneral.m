function [F,g,U] = GetFtensorGeneral(ImageInd,RefInd,Settings)

H5Images = false;
if size(Settings.ImageNamesList,1)==1
    H5Images = true;
    H5ImageParams = {Settings.ScanFilePath,Settings.ImageNamesList,Settings.imsize,Settings.ImageFilter};
end

if H5Images
    ScanImage = ReadH5Pattern(H5ImageParams{:},ImageInd);
else
    ImagePath = Settings.ImageNamesList{ImageInd};
    if strcmp(Settings.ImageFilterType,'standard')
        ScanImage = ReadEBSDImage(ImagePath,Settings.ImageFilter);
    else
        ScanImage = localthresh(ImagePath);
    end
end
g = euler2gmat(Settings.Angles(ImageInd,1) ...
    ,Settings.Angles(ImageInd,2),Settings.Angles(ImageInd,3));
if isempty(ScanImage)
    F = -eye(3); SSE = 101; U = -eye(3); sigma = -eye(3);
    return;
end

pixsize = Settings.PixelSize;
[roixc,roiyc]= GetROIs(ScanImage,Settings.NumROIs,pixsize,Settings.ROISize,...
    Settings.ROIStyle);
Settings.roixc = roixc;
Settings.roiyc = roiyc;


RefImageInd = RefInd;
if H5Images
    RefImage = ReadH5Pattern(H5ImageParams{:},RefImageInd);
else
    RefImagePath = Settings.ImageNamesList{RefImageInd}; % original line
    if strcmp(Settings.ImageFilterType,'standard')
        RefImage = ReadEBSDImage(RefImagePath,Settings.ImageFilter);
    else
        RefImage = localthresh(RefImagePath);
    end
end

clear global rs cs Gs
%         disp(RefImagePath);
gr = euler2gmat(Settings.Angles(RefImageInd,:));
F = CalcF(RefImage,ScanImage,gr,eye(3),ImageInd,Settings,Settings.Phase{ImageInd},RefImageInd);
[R,U] = poldec(F);
g = R'*gr;
U = U - eye(3);