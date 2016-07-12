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
        RefIndA = RefIndA';
        
        %Image C
        rightside = mod(Ind,c)==0 | (c-mod(Ind,c))<=skippts;
        RefIndC(rightside) = Ind(rightside)-(skippts+1);
        RefIndC(~rightside) = Ind(~rightside)+(skippts+1);
        RefIndC = RefIndC';
    case 'Hexagonal'
        skippts = skippts + 0.5; %Change to step size
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
        
        if mod(ceil(skippts),2) %Two Ref A's
            spacing = floor(ceil(skippts)/2);
            toprow = Ind<=NColsOdd+c*(spacing);
            oddright = mod(Ind,c)==NColsOdd;
            oddleft = mod(Ind,c)==1;
            
            %Ref A (top left)
            RefIndA(toprow) = Ind(toprow)+NColsEven+c*spacing;
            RefIndA(~toprow) = Ind(~toprow)-NColsOdd-c*spacing;
            %Ref D (middle)
            RefIndAA(toprow) = Ind(toprow)+NColsOdd+c*spacing;
            RefIndAA(~toprow) = Ind(~toprow)-NColsEven-c*spacing;
            %Keep edge inds adjacent
            RefIndAA(oddright) = RefIndA(oddright);
            RefIndA(oddleft) = RefIndAA(oddleft);
            RefIndA = [RefIndA' RefIndAA'];
        else %Single Ref A
            toprow = Ind<=c*(floor(skippts/2)+1);
            RefIndA(toprow) = Ind(toprow)+c*(floor(skippts/2)+1);
            RefIndA(~toprow) = Ind(~toprow)-c*(floor(skippts/2)+1);
            RefIndA = RefIndA';
        end
        
        if mod(skippts,1) > 0 %Two Ref C's
            spacing = floor(skippts);
            toprow = Ind<=NColsOdd;
            bottomrow = ScanLength-Ind<bottomcol;
            idx = mod(Ind,c);
            rightside = idx==NColsOdd | (idx==0 & spacing>0) | ...
                c-idx<spacing | ... %Even rows
                NColsOdd-idx<=spacing & idx <= NColsOdd; %Odd rows
            
            RefIndC(rightside) = Ind(rightside)-NColsOdd-spacing;
            RefIndC(~rightside) = Ind(~rightside)-NColsEven+spacing;
            RefIndCC(rightside) = Ind(rightside)+NColsEven-spacing;
            RefIndCC(~rightside) = Ind(~rightside)+NColsOdd+spacing;
            
            RefIndCC(bottomrow) = RefIndC(bottomrow);
            RefIndC(toprow) = RefIndCC(toprow);
            RefIndC = [RefIndC' RefIndCC'];
        else %Single Ref C
            idx = mod(Ind,c);
            rightside = idx==NColsOdd | idx==0 | ...
                c-idx<=floor(skippts/2) | ...
                NColsOdd-idx<=floor(skippts/2) & idx <= NColsOdd;
            RefIndC(rightside) = Ind(rightside)-(floor(skippts/2)+1);
            RefIndC(~rightside) = Ind(~rightside)+(floor(skippts/2)+1);
            RefIndC = RefIndC';
        end
            
end