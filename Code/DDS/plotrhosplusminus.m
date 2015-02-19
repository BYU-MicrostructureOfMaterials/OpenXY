function plotrhosplusminus(Settings, alpha_data)

rhos = alpha_data.rhos;
stepsize = alpha_data.stepsize;
n = Settings.data.cols;
m = Settings.data.rows;

[nd,L] = size(rhos);


for i=1:nd
    ri = reshape(shiftdim(rhos(i,:)),n,m)';
    rip = ri;
    rim = ri;
    
    rip(ri<0) = 0;
    rim(ri>0) = 0;
    rim = -rim;
    
    
    cmin = log10(1/stepsize^2);
    cmax = log10(1/(2.5e-10*stepsize)/nd);
    
    figure;
    subplot(1,3,1)
    imagesc(log10(rip))
    caxis([cmin cmax])
    shading flat
    axis off
    axis equal
    subplot(1,3,2)
    imagesc(log10(rim))
    caxis([cmin cmax])
    shading flat
    axis off
    axis equal
    
    subplot(1,3,3)
    axis off
    caxis([cmin cmax])
    colorbar

end






end

