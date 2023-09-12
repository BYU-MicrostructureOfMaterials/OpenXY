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

function [b,l, bhat, rhob, ik] = blmap3(alpha)
a13 = squeeze(alpha(1,:,:));
a23 = squeeze(alpha(2,:,:));
a33 = squeeze(alpha(3,:,:));
a12 = squeeze(alpha(4,:,:));
a21 = squeeze(alpha(5,:,:));
a1122 = squeeze(alpha(6,:,:));

nbhat = sqrt(a13.^2 + a23.^2 + a33.^2);
bhati(1,:,:) = a13./nbhat;
bhati(2,:,:) = a23./nbhat;
bhati(3,:,:) = a33./nbhat;

l = zeros(size(bhati));
bhat = zeros(size(bhati));

[m,n] = size(a13);
rhob = zeros(m,n);
ik = zeros(m,n);
for i=1:m
    for j=1:n
        A = [bhati(1,i,j) -bhati(2,i,j) 0;
            bhati(2,i,j) 0 0;
            0 bhati(1,i,j) 0;
            0 0 bhati(3,i,j);
            0 0 bhati(2,i,j);
            0 0 bhati(1,i,j)];
        
        rhs = [a1122(i,j);a21(i,j);a12(i,j);a33(i,j);a23(i,j);a13(i,j)];
        
        thisvguess = A\rhs;
        ik(i,j) = 1/cond([A rhs]);
        
        FFF = @(x) [rhs;1] - [x(1)*x(4)-x(2)*x(5);x(2)*x(4);...
            x(1)*x(5);x(3)*x(6);x(2)*x(6);x(1)*x(6);x(1)*x(1)+x(2)*x(2)+x(3)*x(3)];
        
        x0 = [bhati(:,i,j);thisvguess];
        xans = fsolve(FFF,x0);
        
        bhat(:,i,j) = xans(1:3);
        thisv = xans(4:6);      
        
        
        l(:,i,j) = thisv/norm(thisv);
        rhob(i,j) = norm(thisv);        
        
    end
end

b(1,:,:) = squeeze(bhat(1,:,:)).*rhob;
b(2,:,:) = squeeze(bhat(2,:,:)).*rhob;
b(3,:,:) = squeeze(bhat(3,:,:)).*rhob;


end

