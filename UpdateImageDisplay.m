function UpdateImageDisplay(handles,ImageFilt)



% Apply updated filter to displayed image
Settings=handles.Settings;
% keyboard
% disp(Settings.FirstImagePath)
ImageFilterTypeList=get(handles.ImageFilterType,'String');
Ind=get(handles.ImageFilterType,'Value');

if strcmp(ImageFilterTypeList(Ind),'standard')
    I1=ReadEBSDImage(Settings.FirstImagePath,ImageFilt);
else
    I1=localthresh(Settings.FirstImagePath);
end
% keyboard
% Display updated image
axes(handles.FilteredImage);
cla
imagesc(I1); colormap gray;

set(gca,'xcolor',get(gcf,'color'));
set(gca,'ycolor',get(gcf,'color'));
set(gca,'ytick',[]);
set(gca,'xtick',[]);
axis equal
