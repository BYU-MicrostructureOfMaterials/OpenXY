function plotrhosplusminus(Settings, alpha_data, rhos, DDSettings)


stepsize = alpha_data.stepsize;
n = Settings.data.cols;
m = Settings.data.rows;

[nd,L] = size(rhos);
showtitle = 0;

if nargin == 4
    showtitle = 1;
    matchoice = DDSettings.matchoice;
    [bedge,ledge, bscrew,lscrew] = choosemat(matchoice);
    b=[bscrew;bedge];
    l=[lscrew;ledge];
    nscrew = size(bscrew,1);
    nedge = size(bedge,1);
end

for i=1:nd
    ri = reshape(shiftdim(rhos(i,:)),n,m)';
    rip = ri;
    rim = ri;
    
    rip(ri<0) = 0;
    rim(ri>0) = 0;
    rim = -rim;
    
    if showtitle
        if i <= nscrew
            type = 'Screw:';
        else
            type = 'Edge:';
        end
        bvec = sprintf(' b[%0.2f, %0.2f, %0.2f]',b(i,:)*1e10);
        lvec = sprintf(' l[%0.2f, %0.2f, %0.2f]',l(i,:));
        name = [type bvec char(197) lvec];
    end
    
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
    if showtitle
        title(name);
    end
    
    subplot(1,3,3)
    axis off
    caxis([cmin cmax])
    colorbar

end






end

