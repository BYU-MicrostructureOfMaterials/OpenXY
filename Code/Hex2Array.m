function array = Hex2Array (vector, NColsOdd, extrarow)
% HEX2ARRAY Converts a vector from a Hexagonal scan to a rectangular map
% 
% array = Hex2Array(vector,NColsOdd,extrarow)
%   INPUTS: 
%       vector - matrix of values. First dimension must correspond to the
%       length of the scan. Up to 2 additional dimensions can be included
%       for multi-dimensional values. (i.e. for a 3x3 matrix value,
%       size(vector) = [N 3 3], where N is the length of the scan)
%
%       NColsOdd - number of points in the first row of the scan
%
%       extrarow (optional) - To convert a hexagonal scan to a rectangular
%       matrix the last column will either be truncated or supplemented
%       with zeros. If "extrarow" in false or excluded the matrix will
%       truncate the matrix such that the size of the output is
%       [NRows,NColsEven]. If "extrarow" is set to true the output array
%       will be of size [NRows,NColsOdd] and the even entries of the last
%       column will be filled in with zeros.
%
%   OUTPUT:
%       array - data from "vector" input formatted to be in an array that
%       matches the formatting of EBSD scans (size = [Ny Nx]).
%
% Written by: Brian Jackson
% May 2016

% Handle inputs
if nargin<3
    extrarow = false;
end
if size(vector,1)<size(vector,2)
    vector = permute(vector,[2 1 3 4]);
end

% Get dimensions
NColsEven = NColsOdd-1;
ScanLength = size(vector,1);
permute_dims = [1 ndims(vector)+1 2:ndims(vector)];

% Extract last column of data
oddends = NColsOdd:NColsOdd+NColsEven:ScanLength;
lostdata = vector(oddends,:,:);
vector(oddends,:,:) = [];

% Reshape to be an array
array = permute(vector,permute_dims);
array = permute(reshape(array,NColsEven,[],size(vector,2),size(vector,3)),[2 1 3 4]);

% Append on extra row
if extrarow
    if size(vector,2)>1
        temp = [lostdata zeros(size(lostdata))];
        temp = permute(reshape(permute(temp,[2 1 3 4]),size(lostdata,2),size(lostdata,1)*2,size(lostdata,3)),[2 1 3 4]);
        if size(temp,1)==size(array,1)+1
            temp(end,:,:) = [];
        end
        temp = permute(temp,permute_dims);
        array = [array temp];
    else
        array(1:2:size(array,1),NColsOdd,:) = lostdata;
    end
end
            