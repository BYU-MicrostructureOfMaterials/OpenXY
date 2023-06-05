function [array, y] = Hex2Array (vector, NColsOdd, extrarow)
if nargin<3
    extrarow = false;
end
if size(vector,1)<size(vector,2)
    vector = vector';
end
NColsEven = NColsOdd-1;
[ScanLength,width] = size(vector);
oddends = NColsOdd:NColsOdd+NColsEven:ScanLength;
lostdata = vector(oddends);
vector(oddends,:) = [];

y = length(vector)/NColsEven;

array = permute(reshape(vector,NColsEven,width,[]),[3 1 2]);
if extrarow
    array(1:2:size(array,1),NColsOdd) = lostdata;
end
            