function Ind = sub2ind2(mapsize,X,Y,type)
switch type
    case 'Square'
        Ind = sub2ind(mapsize,X,Y);
    case 'Hexagonal'
        %Mapsize is [NColsOdd NRows]
        Ind = sub2ind([mapsize(1)-1 mapsize(2)],X,Y);
        Ind = Ind + floor(Y/2); %Account for missing points
end