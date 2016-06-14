function [X,Y] = ind2sub2(mapsize,Ind,type)
switch type
    case 'Square'
        [X,Y] = ind2sub(mapsize,Ind);
    case 'Hexagonal'
        NColsOdd = mapsize(1);
        NColsEven = mapsize(1)-1;
        X = mod(Ind,NColsOdd+NColsEven);
        X(X==0) = NColsOdd+NColsEven;
        Y = (floor((Ind-1)/(NColsOdd+NColsEven))+1)*2-(X<=NColsOdd);
        
        X(X==NColsOdd) = NColsEven;
        X = mod(X,NColsOdd);
end
