function UpdateROIDisplay(handles,ImageFilt)

Settings=handles.Settings;
axes(handles.FilteredImage);
cla
% disp(handles.ImageFilterType)
ImageFilterTypeList=get(handles.ImageFilterType,'String');
Ind=get(handles.ImageFilterType,'Value');

if strcmp(ImageFilterTypeList(Ind),'standard')
    I1=ReadEBSDImage(Settings.FirstImagePath,ImageFilt);
else
    I1=localthresh(Settings.FirstImagePath);
end

% Display updated image



axes(handles.FilteredImage);
cla
% ahI1=histeq(I1);
imagesc(I1); colormap gray;
set(gca,'xcolor',get(gcf,'color'));
set(gca,'ycolor',get(gcf,'color'));
set(gca,'ytick',[]);
set(gca,'xtick',[]);
axis equal
% keyboard
%get pixel size
pixsize = size(I1,1);

ROInum = get(handles.NumberROIsPopUp,'Value');

roisize = str2double(get(handles.ROISizeEdit,'String'))/100*pixsize;

ROIStyleList = get(handles.ROIStylePopUp,'String');

Ind = get(handles.ROIStylePopUp,'Value');

ROImethod = ROIStyleList{Ind};

GenImage=handles.GenImage;
% keyboard
if ~strcmp(ROImethod,'Intensity')
    
    [roixc,roiyc]= GetROIs(I1,ROInum,pixsize,roisize,ROImethod);
else % use intensity method
    
%     IMap=single(ReadEBSDImage(Settings.FirstImagePath,[0 0 0 0]));
%     GenImage=GenImage.*IMap;
    [roixc,roiyc]= GetROIs(GenImage,ROInum,pixsize,roisize,ROImethod);
end


for ii = 1:length(roixc)
    
    hold on
    
    DrawROI(roixc(ii),roiyc(ii),roisize);
%     rectangle('Curvature',[0 0],'Position',...
%         [roixc(ii)-roisize/2 roiyc(ii)-roisize/2 roisize roisize],...
%         'EdgeColor','g');
    
end
axes(handles.SimPat)
cla
imagesc(GenImage); colormap gray;
set(gca,'xcolor',get(gcf,'color'));
set(gca,'ycolor',get(gcf,'color'));
set(gca,'ytick',[]);
set(gca,'xtick',[]);
axis equal

if strcmp(ROImethod,'Intensity')
    
    for jj = 1:length(roixc)

        hold on

        DrawROI(roixc(jj),roiyc(jj),roisize);
    %     rectangle('Curvature',[0 0],'Position',...
    %         [roixc(jj)-roisize/2 roiyc(jj)-roisize/2 roisize roisize],...
    %         'EdgeColor','g');

    end
end