function alphacompplotlabels( alphafield, mask, cmax, cmin, labels, fs )


figure('units','inches','position',[3 3 6 6])
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
        set(gca,'FontName','Times New Roman', 'FontSize', 2)
        axis off
        axis image
        xlabel(labels(count), 'interpreter', 'latex','visible', 'on', 'fontsize', fs, 'fontname', 'Times New Roman');
    end
end

subplot(4,3,[10,11])
axis off
caxis([cmin cmax])
cb = colorbar;
set(cb,'FontSize', 12, 'FontName','Times New Roman', 'Location','north')

