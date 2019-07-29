function plotShifts(RefImage, ScanImage, Ind, RefInd, Settings, Qsc,...
    pc, keepInds, Cshift, Rshift, F, fitMetrics)
scaleFactor = 1;
DoPlotROIs = 0;
alpha=pi/2-Settings.SampleTilt+Settings.CameraElevation;

xstar = pc(1);
ystar = pc(2);
zstar = pc(3);

roixc = Settings.roixc;
roiyc = Settings.roiyc;


try
    set(0,'currentfigure',100);
catch
    figure(100);
end
[cx,cy]=Theoretical_Pixel_Shift(Qsc,xstar,ystar,zstar,roixc,roiyc,F,Settings.PixelSize,alpha);
cla
imagesc(RefImage);
axis image
colormap gray
hold on
for i=1:length(Cshift)
    if ~isempty(find(keepInds==i, 1))
        %Should probably make this factor "*10" a variable...
        plot([roixc(i) roixc(i)+scaleFactor*Cshift(i)],[roiyc(i) roiyc(i)+scaleFactor*Rshift(i)],'g.-')
    else
        plot([roixc(i) roixc(i)+scaleFactor*Cshift(i)],[roiyc(i) roiyc(i)+scaleFactor*Rshift(i)],'r.-')
    end
    %         plot([roixc(i) roixc(i)+sf*cx(i)],[roiyc(i) roiyc(i)+sf*cy(i)],'b.-')
    plot(roixc(i),roiyc(i),'y.')
end
drawnow
try
    set(0,'currentfigure',101);
catch
    figure(101);
end
text = get(gca,'title');
if ~isempty(text.String)
    [num,iter] = strtok(text.String{2}(6:end));
    num = str2num(num);
    iter = str2num(iter);
    if num == Ind
        iter = iter + 1;
    else
        iter = 1;
    end
else
    iter = 1;
end
set(0,'currentfigure',100);
if RefInd~=0
    title({'Reference Image';['Image ' num2str(RefInd) ' (' num2str(iter) ')']})
else
    title({'Simulated Reference Image';[' (' num2str(iter) ')']})
end

set(0,'currentfigure',101);
[cx,cy]=Theoretical_Pixel_Shift(Qsc,xstar,ystar,zstar,roixc,roiyc,F,Settings.PixelSize,alpha);
cla
imagesc(ScanImage);
axis image
colormap gray
hold on
if DoPlotROIs
    set(0,'currentfigure',101);
    PlotROIs(Settings,RefImage);
end
for i=1:length(Cshift)
    if ~isempty(find(keepInds==i, 1))
        %Should probably make this factor "*10" a variable...
        plot([roixc(i) roixc(i)+scaleFactor*Cshift(i)],[roiyc(i) roiyc(i)+scaleFactor*Rshift(i)],'g.-')
    else
        plot([roixc(i) roixc(i)+scaleFactor*Cshift(i)],[roiyc(i) roiyc(i)+scaleFactor*Rshift(i)],'r.-')
    end
    plot([roixc(i) roixc(i)+scaleFactor*cx(i)],[roiyc(i) roiyc(i)+scaleFactor*cy(i)],'b.-')
end
drawnow
title({'Experimental Image';['Image ' num2str(Ind) ' (' num2str(iter) ')']})

fprintf(1, [
    '\n'...
    'Point: %u\n'...
    '\tSSE: %f\n'...
    '\tR^2_x: %f\n'...
    '\tR^2_y: %f\n'...
    '\tR^2: %f\n'...
    ],...
    Ind, fitMetrics.SSE, fitMetrics.rsqX, fitMetrics.rsqY, fitMetrics.rsq)


