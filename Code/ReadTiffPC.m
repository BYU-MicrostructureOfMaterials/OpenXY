function [XStar,YStar,ZStar] = ReadTiffPC(ImageNamesList,mapsize,VHRatio)

Nx=mapsize(1);Ny=mapsize(2);
if Ny>1
    getdat = [1 2 Nx+1];
else
    getdat = [1 2];
end
xread = zeros(length(getdat),1);
yread = zeros(length(getdat),1);
zread = zeros(length(getdat),1);
for loopvar=1:length(getdat)
    i = getdat(loopvar);
    info = imfinfo(ImageNamesList{i});
    
    %XStar
    xistart = strfind(info.UnknownTags.Value,'<pattern-center-x-pu>');
    xifinish = strfind(info.UnknownTags.Value,'</pattern-center-x-pu>');
    thisx = str2double(info.UnknownTags.Value(xistart+length('<pattern-center-x-pu>'):xifinish-1));
    xread(loopvar) = (thisx - (1-VHRatio)/2)/VHRatio;
    
    %YStar
    yistart = strfind(info.UnknownTags.Value,'<pattern-center-y-pu>');
    yifinish = strfind(info.UnknownTags.Value,'</pattern-center-y-pu>');
    yread(loopvar) = str2double(info.UnknownTags.Value(yistart+length('<pattern-center-y-pu>'):yifinish-1))/VHRatio;
    
    %ZStar
    zistart = strfind(info.UnknownTags.Value,'<detector-distance-pu>');
    zifinish = strfind(info.UnknownTags.Value,'</detector-distance-pu>'); 
    zread(loopvar) = str2double(info.UnknownTags.Value(zistart+length('<detector-distance-pu>'):zifinish-1))/VHRatio;
end

PTX = mod((1:Nx*Ny) - 1,Nx)';
PTY = floor(((1:Nx*Ny) - 1)/Nx)';

xxstep = xread(2) - xread(1);
xystep = yread(2) - yread(1);
xzstep = zread(2) - zread(1);

if Ny>1
    yxstep = xread(3) - xread(1);
    yystep = yread(3) - yread(1);
    yzstep = zread(3) - zread(1);

    XStar = xread(1) + PTX*xxstep + PTY*yxstep;
    YStar = yread(1) + PTX*xystep + PTY*yystep;
    ZStar = zread(1) + PTX*xzstep + PTY*yzstep;
else
    XStar = xread(1) + PTX*xxstep;
    YStar = yread(1) + PTX*xystep;
    ZStar = zread(1) + PTX*xzstep;
end