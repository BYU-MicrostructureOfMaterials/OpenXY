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

function rfield = rotatevectorfield(field, Q)
rfield = zeros(size(field));
sv = size(field);

if length(size(Q))==2
    if length(sv)==3
        for i=1:sv(2)
            for j=1:sv(3)
                thisV = squeeze(field(:,i,j));
                rfield(:,i,j) = Q*thisV;
            end
        end
    elseif length(sv)==2
        for i=1:sv(2)
            thisV = squeeze(field(:,i));
            rfield(:,i) = Q*thisV;
        end
    else
        error('rotattetensorfield cannot handle this size or shape of field')
    end
    
elseif length(size(Q))==3
    if length(sv)==3
        for i=1:sv(2)
            for j=1:sv(3)
                thisV = squeeze(field(:,i,j));
                thisQ = euler2gmat(squeeze(Q(:,i,j)));
                rfield(:,i,j) = thisQ*thisV;
            end
        end
    elseif length(sv)==2
        for i=1:sv(2)
            thisV = squeeze(field(:,i));
            thisQ = euler2gmat(squeeze(Q(:,i)));
            rfield(:,i) = thisQ*thisV;
        end
    else
        error('rotattetensorfield cannot handle this size or shape of field')
    end   
    
elseif length(size(Q))==4
    if length(sv)==3
        for i=1:sv(2)
            for j=1:sv(3)
                thisV = squeeze(field(:,i,j));
                thisQ = squeeze(Q(:,:,i,j));
                rfield(:,i,j) = thisQ*thisV;
            end
        end
    elseif length(sv)==2
        for i=1:sv(2)
            thisV = squeeze(field(:,i));
            thisQ = squeeze(Q(:,:,i));
            rfield(:,i) = thisQ*thisV;
        end
    else
        error('rotattetensorfield cannot handle this size or shape of field')
    end    
else
    error('rotattetensorfield cannot handle this size or shape of Q')
end
    
    
end

