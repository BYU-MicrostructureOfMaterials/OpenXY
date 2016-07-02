function MisoCalcImage(g,dims)
figure
IPF_map = PlotIPF(g,dims);

redo = 1;
while redo
    [X,Y,button] = ginput(2);
    hold off
    image(IPF_map)
    if isempty(button)
        return;
    end
    X = round(X);
    Y = round(Y);
    ind1 = sub2ind(dims,X(1),Y(1));
    ind2 = sub2ind(dims,X(2),Y(2));
    
    MisAng = GeneralMisoCalc(g(:,:,ind1),g(:,:,ind2),'tetragonal');
    disp(MisAng)
    
    hold on
    scatter(X,Y,'dk')
    
end