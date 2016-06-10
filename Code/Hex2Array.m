function array = Hex2Array (vector, NColsOdd)
NColsEven = NColsOdd-1;
[ScanLength,width] = size(vector);
vector(NColsOdd:NColsOdd+NColsEven:ScanLength,:) = [];
array = permute(reshape(vector,NColsEven,width,[]),[3 1 2]);
            