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
array = permute(reshape(vector,NColsEven,width,[]),[3 1 2]);
% height = ScanLength/NColsEven;
% isInt =~ mod(height, 1);
% 
% if ~isInt
%     height = cast(height, 'uint64') - 1;
%     vector = vector(1:height*NColsEven,:);
% end
% 
% array = permute(reshape(vector, NColsEven, width, []),[3 1 2]);
y = length(vector)/NColsEven;

if extrarow
    array(1:2:size(array,1),NColsOdd) = lostdata;
end
            