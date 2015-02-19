function junk = ddplot( rho, cmin, cmax )

figure
I = (log10(abs(rho)));
imagesc(I)
shading flat
colorbar
caxis([cmin cmax])

junk = 0;

end

