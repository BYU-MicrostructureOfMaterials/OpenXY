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

function alpha = partialcurl(betaderiv1,betaderiv2)
alpha = zeros(6,size(betaderiv1,3),size(betaderiv1,4));

alpha(1,:,:) = betaderiv2(1,1,:,:) - betaderiv1(1,2,:,:); %13
alpha(2,:,:) = betaderiv2(2,1,:,:) - betaderiv1(2,2,:,:); %23
alpha(3,:,:) = betaderiv2(3,1,:,:) - betaderiv1(3,2,:,:); %33
alpha(4,:,:) = betaderiv1(1,3,:,:); %12
alpha(5,:,:) = -betaderiv2(2,3,:,:); %21
alpha(6,:,:) = -betaderiv2(1,3,:,:) - betaderiv1(2,3,:,:); %11 - 22
end

