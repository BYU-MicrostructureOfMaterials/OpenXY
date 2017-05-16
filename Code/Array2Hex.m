function vector = Array2Hex(map)
% ARRAY2HEX Converts an array of hexagonal values back to a vector
%
% vector = Array2Hex(map, NColsOdd)
%   INPUTS:
%       map - Map output from Hex2Array with "extrarow" set to true. The
%       original vector cannot be reconstructed with missing data.
%
%   OUTPUT:
%       vector - data from "map" input with the zeros removed and correctly
%       put back into the original vector
%
% Written by: Brian Jackson
% May 2016

NColsOdd = size(map,2);
vector = reshape(permute(map,[2 1 3 4]),[],size(map,3),size(map,4));
vector((NColsOdd*2):(NColsOdd*2):numel(map(:,:,1,1)),:,:) = [];