function array = Hex2Array (vector, NColsOdd, NColsEven)

r = 1;
c = 1;
for i = 1:length(vector)
    
    array(r,c) = vector(i);
    c = c + 1;
    if mod(r,2) == 1 %Odd
        if c > NColsOdd
            c = 1;
            r = r + 1;
        end
    else %Even
        if c > NColsEven
            c = 1;
            r = r + 1;
        end
    end
end
array = array(:,1:end-1);
        
            