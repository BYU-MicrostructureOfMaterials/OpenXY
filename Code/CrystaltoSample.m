function C = CrystaltoSample(A,g)
% CRYSTALTOSAMPLE Converts a 3x3xN array from the crystal frame to the
% sample frame
%
%   INPUTS
%       A: 3x3xN array of data to be transformed
%       g: 3x3xN array of orientations in rotation matrix form 
%           OR Nx3 array of bunge euler angles
%
%   OUTPUT
%       C: A array in the sample frame according to the conversion C = g'*A*G
%
% Brian Jackson
% January 2017

% Check size of input array
if ~(size(A,1)==3 && size(A,2)==3)
    error('A must be a 3x3xN matrix')
end

% Accept Angles as an input
if all([size(g,1) size(g,2)]==[size(A,3),3])
    g = euler2gmat(g);
end

% Perform Conversion
C = MatrixMult3D(permute(g,[2 1 3]),A);
C = MatrixMult3D(C,g);