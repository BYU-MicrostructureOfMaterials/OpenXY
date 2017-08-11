function alphacompplot( alphafield, mask, cmax, cmin )


figure
count = 0;
for i=1:3
    for j=1:3
%         figure
%         imagesc(shiftdim(alphafield(i,j,:,:)),[cmin cmax])
%         title(['Alpha',num2str(i),num2str(j)])
%         axis off
        count = count+1;
        toplot = shiftdim(alphafield(i,j,:,:));
        toplot(mask) = 0/0;
        toplot = flipud(toplot);
        subplot(4,3,count),surf(toplot); caxis([cmin cmax])
        view(2)
        shading flat
        axis off
        axis image
    end
end

subplot(4,3,[10,11])
axis off
caxis([cmin cmax])
cb = colorbar;
set(cb,'FontSize', 12, 'FontName','Times New Roman', 'Location','north')

