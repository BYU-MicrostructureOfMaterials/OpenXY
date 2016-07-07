function [RefIndA,RefIndC] = GetAdjacentInds(scansize,Ind,skippts,ScanType)
switch ScanType
    case 'Square'
        c = scansize(1);
        r = scansize(2);
        %Image A
        if r > 1 %No image_a for line scans
            toprow = Ind<=c*(skippts+1);
            RefIndA(toprow) = Ind(toprow)+c*(skippts+1);
            RefIndA(~toprow) = Ind(~toprow)-c*(skippts+1);
        elseif r == 1
            RefIndA = Ind;
        end 
        
        %Image C
        rightside = mod(Ind,c)==0 | (c-mod(Ind,c))<=skippts;
        RefIndC(rightside) = Ind(rightside)-(skippts+1);
        RefIndC(~rightside) = Ind(~rightside)+(skippts+1);
    case 'Hexagonal'
        c = scansize(1);
        r = scansize(2);
        NColsOdd = c;
        NColsEven = c-1;
        c = NColsOdd+NColsEven;
        ScanLength = NColsOdd*r - floor(r/2);
        if mod(r,2)
            bottomcol = NColsOdd;
        else
            bottomcol = NColsEven;
        end
        
        if mod(skippts,2) %Odd, single point in each direction
            toprow = Ind<=c*(floor(skippts/2)+1);
            RefIndA(toprow) = Ind(toprow)+c*(floor(skippts/2)+1);
            RefIndA(~toprow) = Ind(~toprow)-c*(floor(skippts/2)+1);
            
            idx = mod(Ind,c);
            rightside = idx==NColsOdd | idx==0 | ...
                c-idx<=floor(skippts/2) | ...
                NColsOdd-idx<=floor(skippts/2) & idx <= NColsOdd;
            RefIndC(rightside) = Ind(rightside)-(floor(skippts/2)+1);
            RefIndC(~rightside) = Ind(~rightside)+(floor(skippts/2)+1);
        else %Even, two points in each direction
            toprow = Ind<=NColsOdd*(floor(skippts/2)+1);
            bottomrow = ScanLength-Ind<bottomcol+c*(floor(skippts/2));
            oddright = mod(Ind,c)==NColsOdd;
            oddleft = mod(Ind,c)==1;
            
            %Ref A (top left)
            RefIndA(toprow) = Ind(toprow)+NColsEven;
            RefIndA(~toprow) = Ind(~toprow)-NColsOdd;
            %Ref D (middle)
            RefIndD(toprow) = Ind(toprow)+NColsOdd;
            RefIndD(~toprow) = Ind(~toprow)-NColsEven;
            %Keep edge inds adjacent
            RefIndD(oddright) = RefIndA(oddright);
            RefIndA(oddleft) = RefIndD(oddleft);
            
            %Ref C (bottom right)
            RefIndC(bottomrow) = RefIndD(bottomrow);
            RefIndC(~bottomrow) = Ind(~bottomrow)+NColsOdd;
            RefIndC(oddright & ~bottomrow) = Ind(oddright & ~bottomrow)+NColsEven;
            
            
        end
    otherwise
        
        
end