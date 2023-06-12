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
cla
imagesc(RefImage);
% 
% RefImage2 = single(RefImage)/255;
% scanNum = 3; %change this too
% scanType = '.jpeg'; %can change this to .tiff or whatever
% folderName = ['Scan_', num2str(scanNum), scanType];
% mkdir(folderName);%make a new folder for every scan
% cd(folderName);%go to the folder to save for all the data
% imageName = ['pattern', num2str(Ind), '.jpeg'];
% imwrite(RefImage2(:, :)', imageName);
% cd('..');



axis image
colormap gray
hold on
for ii=1:length(Cshift)
    if keepInds(ii)
        %Should probably make this factor "*10" a variable...
        plot([roixc(ii) roixc(ii)+scaleFactor*Cshift(ii)],[roiyc(ii) roiyc(ii)+scaleFactor*Rshift(ii)],'g.-')
    else
        plot([roixc(ii) roixc(ii)+scaleFactor*Cshift(ii)],[roiyc(ii) roiyc(ii)+scaleFactor*Rshift(ii)],'r.-')
    end
    %         plot([roixc(i) roixc(i)+sf*cx(i)],[roiyc(i) roiyc(i)+sf*cy(i)],'b.-')
    plot(roixc(ii),roiyc(ii),'y.')
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
for ii=1:length(Cshift)
    if keepInds(ii)
        %Should probably make this factor "*10" a variable...
        plot([roixc(ii) roixc(ii)+scaleFactor*Cshift(ii)],[roiyc(ii) roiyc(ii)+scaleFactor*Rshift(ii)],'g.-')
    else
        plot([roixc(ii) roixc(ii)+scaleFactor*Cshift(ii)],[roiyc(ii) roiyc(ii)+scaleFactor*Rshift(ii)],'r.-')
    end
    plot([roixc(ii) roixc(ii)+scaleFactor*cx(ii)],[roiyc(ii) roiyc(ii)+scaleFactor*cy(ii)],'b.-')
end


% Calculate Effective Strain
% TODO Make this a seperate function
g = euler2rmat(Settings.Angles(Ind, :));
Fsample = g' * F * g;
strain = (Fsample + Fsample') / 2 - eye(3);
exx=(2*strain(1,1,:)-strain(2,2,:)-strain(3,3,:))/3;
eyy=(-strain(1,1,:)+2*strain(2,2,:)-strain(3,3,:))/3;
ezz=(-strain(1,1,:)-strain(2,2,:)+2*strain(3,3,:))/3;
strainEff=2/3*sqrt(3*(exx.^2+eyy.^2+ezz.^2)/2+3*(strain(1,2,:).^2+strain(1,3,:).^2+strain(2,3,:).^2));


drawnow
title({'Experimental Image';['Image ' num2str(Ind) ' (' num2str(iter) ')']})

fprintf(1, [
    '\n'...
    'Point: %u\n'...
    '\tSSE: %f\n'...
    '\tR^2: %f\n'...
    '\tEffective Strain: %f\n'...
    ],...
    Ind, fitMetrics.SSE, fitMetrics.rsq, strainEff)


