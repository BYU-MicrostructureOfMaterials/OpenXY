% Copyright 2021 National Technology & Engineering Solutions of Sandia, LLC (NTESS).
% Under the terms of Contract DE-NA0003525 with NTESS, the U.S. Government retains certain rights in this software.
% Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files
% (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge,
% publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do
% so, subject to the following conditions:
% The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
% OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
% LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
% IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

function S = smearmat(A,kernel)

sv = size(A);
% sk = size(kernel);
S = zeros(size(A));
if length(sv) == 2
    S = conv2(A,kernel,'same');
elseif length(sv) == 3
%     S = zeros(sv(1),sv(2)+sk(1)-1,sv(2)+sk(2)-1);
    for i=1:size(A,1)
        S(i,:,:) = conv2(squeeze(A(i,:,:)),kernel,'same');
    end
elseif length(sv)==4
%     S = zeros(sv(1),sv(2),sv(3)+sk(1)-1,sv(4)+sk(2)-1);
    for i=1:size(A,1)
        for j=1:size(A,2)
            S(i,j,:,:) = conv2(squeeze(A(i,j,:,:)),kernel,'same');
        end
    end
else
    error('Too many or too few dimensions for smearmat')
end
end

