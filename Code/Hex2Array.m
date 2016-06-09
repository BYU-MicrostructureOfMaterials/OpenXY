function array = Hex2Array (vector, NColsOdd)
NColsEven = NColsOdd-1;
ScanLength = length(vector);
vector(NColsOdd:NColsOdd+NColsEven:ScanLength) = [];
array = reshape(vector,NColsEven,[])';
            