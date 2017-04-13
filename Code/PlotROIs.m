function PlotROIs(ROInum, ROISize, ROIStyle, Image,fig)
if nargin == 4
    fig = gca;
end
pixsize = size(Image,1);
% ROInum = Settings.NumROIs;
% ROISize = Settings.ROISizePercent/100*pixsize;
% ROIStyle = Settings.ROIStyle;

[roixc,roiyc]= GetROIs(Image,ROInum,pixsize,ROISize,ROIStyle);

for ii = 1:length(roixc)
    hold on  
    DrawROI(roixc(ii),roiyc(ii),ROISize,fig);
%     rectangle('Curvature',[0 0],'Position',...
%         [roixc(ii)-roisize/2 roiyc(ii)-roisize/2 roisize roisize],...
%         'EdgeColor','g');   
end

end

function DrawROI(roixc,roiyc,ROISize,fig)
%Draw a box around the passed in region of interest in the current figure
hold on
% plot(roiyc,roixc, '*g');

TL = [roiyc - ROISize/2 roixc - ROISize/2 ];
BR = [roiyc + ROISize/2 roixc + ROISize/2];

TopLineC = TL(2):BR(2);
TopLineR(1:length(TopLineC)) = TL(1);
hold on
plot(fig,TopLineC, TopLineR, '-g');

RightLineR = TL(1):BR(1);
RightLineC(1:length(RightLineR)) = BR(2);
hold on
plot(fig,RightLineC, RightLineR, '-g');

BottomLineC = TL(2):BR(2);
BottomLineR(1:length(BottomLineC)) = BR(1);
hold on
plot(fig,BottomLineC, BottomLineR, '-g');

LeftLineR = TL(1):BR(1);
LeftLineC(1:length(LeftLineR)) = TL(2);
hold on
plot(fig,LeftLineC, LeftLineR, '-g');
end