function [crosscor] = CalcCross(PC,I0,params2,lattice,a1,b1,c1,axs,g,F,X,ImageInd,Settings)

params2{1} = PC(1);
params2{2} = PC(2);
params2{3} = PC(3);

clear global rs cs Gs

% I2 = genEBSDPatternHybrid(g,params2,F,lattice,a1,b1,c1,axs);
switch Settings.HROIMMethod
    
    case 'Dynamic Simulated'
        xstar=PC(1);
        ystar=PC(2);
        zstar=PC(3);
        pixsize=cell2mat(params2(4));
        Av=cell2mat(params2(5));
        elevang=cell2mat(params2(7));
        mperpix = Settings.mperpix;
        curMaterial=cell2mat(Settings.Phase(ImageInd)); %****may need updating for material of this point - where is that info?
        I1 = genEBSDPatternHybrid_fromEMSoft(g,xstar,ystar,zstar,pixsize,mperpix,elevang,curMaterial,Av);

        %Calculate Cross-Correlation Coefficient
        % crop image ********optimize this later
        [xs ys]=size(I1);
        I0=I0(round(xs/4):round(3*xs/4),round(ys/4):round(3*ys/4));
        I1=I1(round(xs/4):round(3*xs/4),round(ys/4):round(3*ys/4));
    
        I0 = I0 - mean(I0(:));
        I1 = I1 - mean(I1(:));
        crosscor = -sum(sum(I0.*I1/(std(I0(:))*std(I1))))/numel(I0);
        
    otherwise

        I1 = genEBSDPatternHybrid(g,params2,F,lattice,a1,b1,c1,axs);
        I1 = custimfilt(I1,X(1),Settings.PixelSize,X(3),X(4));
        I0 = I0 - mean(I0(:));
        I1 = I1 - mean(I1(:));
        crosscor = -sum(sum(I0.*I1/(std(I0(:))*std(I1))))/numel(I0); % negative for minimization of max

end
return
%****** delete from here forward***
DoShowPlot=1;
if DoShowPlot
    try
        set(0,'currentfigure',100);
    catch
        figure(100);
    end
    imagesc(I0);
    axis image
    colormap gray

    title(['Image ' num2str(ImageInd)])
    
    try
        set(0,'currentfigure',101);
    catch
        figure(101);
    end
    imagesc(I1);
    axis image
    colormap gray
    
end
disp(crosscor);
keyboard