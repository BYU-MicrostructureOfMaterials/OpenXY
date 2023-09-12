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

function h = rhoplot(rhos, mpsettings)

ntypes = size(rhos,1);

b = floor(sqrt(ntypes));
a = ceil((ntypes+2)/b);


h = figure;

if isfield(mpsettings,'cmap')
    colormap(mpsettings.cmap);
end

count = 0;
for i=1:a
    for j=1:b
        count = count + 1;
        if count <= ntypes
            subplot(a,b,j + b*(i-1))
            imagesc(squeeze(rhos(count,:,:)))
            caxis(mpsettings.clims);
            axis image
            axis off
            xh = xlabel(mpsettings.labels{count});
            set(xh, 'Visible', 'on')
        else
            break;
        end
    end
end
subplot(a,b,[a*b-1,a*b])
caxis(mpsettings.clims)
cbh = colorbar;
set(cbh, 'Location', 'north')
axis off

end

