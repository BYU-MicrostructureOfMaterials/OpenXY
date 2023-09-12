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

% See Ruggles TJ, Deitz JI, Allerman AA, Carter CB, Michael JR (2021)
% Identification of Star Defects in Gallium Nitride with HREBSD and ECCI. Microsc
% Microanal 27, 257–265. doi:10.1017/S143192762100009X

function [b,l, bhat, rhob, ik] = blmap2(alpha)
a13 = squeeze(alpha(1,:,:));
a23 = squeeze(alpha(2,:,:));
a33 = squeeze(alpha(3,:,:));
a12 = squeeze(alpha(4,:,:));
a21 = squeeze(alpha(5,:,:));
a1122 = squeeze(alpha(6,:,:));

nbhat = sqrt(a13.^2 + a23.^2 + a33.^2);
bhat(1,:,:) = a13./nbhat;
bhat(2,:,:) = a23./nbhat;
bhat(3,:,:) = a33./nbhat;

l = zeros(size(bhat));
[m,n] = size(a13);
rhob = zeros(m,n);
ik = zeros(m,n);
for i=1:m
    for j=1:n
        A = [bhat(1,i,j) -bhat(2,i,j) 0;
            bhat(2,i,j) 0 0;
            0 bhat(1,i,j) 0;
            0 0 bhat(3,i,j);
            0 0 bhat(2,i,j);
            0 0 bhat(1,i,j)];
        rhs = [a1122(i,j);a21(i,j);a12(i,j);a33(i,j);a23(i,j);a13(i,j)];
        thisv = A\rhs; % Eq 7 in Ruggles paper
        l(:,i,j) = thisv/norm(thisv); % Eq 8
        rhob(i,j) = norm(thisv); % Eq 9
        ik(i,j) = 1/cond([A rhs]); % this is 1/k in Ruggles paper cited above - zero means good solution; large means poor
    end
end

b(1,:,:) = squeeze(bhat(1,:,:)).*rhob;
b(2,:,:) = squeeze(bhat(2,:,:)).*rhob;
b(3,:,:) = squeeze(bhat(3,:,:)).*rhob;
end

