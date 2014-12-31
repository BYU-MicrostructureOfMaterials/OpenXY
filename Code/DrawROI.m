function DrawROI(roixc,roiyc,ROISize)
%% Draw a box around the passed in region of interest in the current figure

hold on
% plot(roiyc,roixc, '*g');

TL = [roiyc - ROISize/2 roixc - ROISize/2 ];
BR = [roiyc + ROISize/2 roixc + ROISize/2];

TopLineC = TL(2):BR(2);
TopLineR(1:length(TopLineC)) = TL(1);
hold on
plot(TopLineC, TopLineR, '-g');

RightLineR = TL(1):BR(1);
RightLineC(1:length(RightLineR)) = BR(2);
hold on
plot(RightLineC, RightLineR, '-g');

BottomLineC = TL(2):BR(2);
BottomLineR(1:length(BottomLineC)) = BR(1);
hold on
plot(BottomLineC, BottomLineR, '-g');

LeftLineR = TL(1):BR(1);
LeftLineC(1:length(LeftLineR)) = TL(2);
hold on
plot(LeftLineC, LeftLineR, '-g');


