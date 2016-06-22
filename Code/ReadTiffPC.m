function [XStar,YStar,ZStar] = ReadTiffPC(ImageNamesList,VHRatio)
len = length(ImageNamesList);
XStar=zeros(len,1);YStar=zeros(len,1);ZStar=zeros(len,1);

h = waitbar(0,'Reading Tiff PC');
for i = 1:len
    file = ImageNamesList{i};
    if exist(file,'file')
        info = imfinfo(ImageNamesList{i});
        xistart = strfind(info.UnknownTags.Value,'<pattern-center-x-pu>');
        xifinish = strfind(info.UnknownTags.Value,'</pattern-center-x-pu>');

        thisx = str2double(info.UnknownTags.Value(xistart+length('<pattern-center-x-pu>'):xifinish-1));
        XStar(i) = (thisx - (1-VHRatio)/2)/VHRatio;

        yistart = strfind(info.UnknownTags.Value,'<pattern-center-y-pu>');
        yifinish = strfind(info.UnknownTags.Value,'</pattern-center-y-pu>');

        thisy = str2double(info.UnknownTags.Value(yistart+length('<pattern-center-y-pu>'):yifinish-1));
        YStar(i) = thisy/VHRatio;

        zistart = strfind(info.UnknownTags.Value,'<detector-distance-pu>');
        zifinish = strfind(info.UnknownTags.Value,'</detector-distance-pu>');

        thisz = str2double(info.UnknownTags.Value(zistart+length('<detector-distance-pu>'):zifinish-1));
        ZStar(i) = thisz/VHRatio;
        waitbar(i/length(ImageNamesList),h)
    end
end
close(h)