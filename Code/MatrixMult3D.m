function C = MatrixMult3D(A,B)
% MatrixMult3D Fast 'element-wise' multiplication of 3x3xN matrices
%
% INPUTS
%   A and B must be 3x3xN matrices 
%
% OUTPUT
%   C(:,:,i) is the multiplication of A(:,:,i) and B(:,:,i)
%
% Brian Jackson
% January 2017
% 
% Inspired by algorithm by Dr. Fullwood in findgrains.m

A = reshape(A,9,[])';
B = reshape(B,9,[])';

ind = reshape(1:9,3,3);

count=0;
C = zeros(size(A));
for jj = 1:3
    for ii =1:3
        count=count+1; 
        C(:,count) = sum(A(:,ind(ii,:)).*B(:,ind(:,jj)),2);
    end
end

C = reshape(C',3,3,[]);