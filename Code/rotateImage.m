function im = rotateImage(im,g,xStar,yStar,zStar)

sz = size(im);

%TODO validated images is a 2D n X n matrix

sz = sz(1);

vec = linspace(0,1,sz);

[x,y] = meshgrid(vec);% Should this be from 0:sz-1?

transformedImage = zeros(sz,sz,3);
Qvp = [
   -1  0  0
    0 -1  0
    0  0  1
 ];

for ii = 1:sz
    for jj = 1:sz
        
        rPixel = Qvp*[x(ii,jj);y(ii,jj);0] + [xStar;1-yStar;-zStar];
        
        rprime = transform(rPixel,g,zStar);
        transformedImage(ii,jj,:) = Qvp' * (rprime - [xStar;1-yStar;-zStar]);
    end
end

X = transformedImage(:,:,1);
Y = transformedImage(:,:,2);
Z = im;

Diff = 1/(sz - 1);

% Add buffers to the nodes
xNodes = [- Diff vec 1 + Diff]';
yNodes = [- Diff vec 1 + Diff]';

im = gridfit(X(:),Y(:),Z(:),xNodes,yNodes,'smoothness',0.01,...
    'interp','bilinear','extend','always');

im = im(2:end-1,2:end-1);

end

function rprime = transform(r,R,zStar)
% Algorithm explaned in:
% On solving the orientation gradient dependency of high angular resolution
%   EBSD
% Maurice et. al.
% https://doi.org/10.1016/j.ultramic.2011.10.013
k = [0;0;-1];
R_times_r = (R * r);
denom = dot(R_times_r, k);
rprime = (zStar / denom) * R_times_r;
end


%{
figure;
hold on;
surf(coordPoints(:,:,1),coordPoints(:,:,2),im)
surf(transformedImage(:,:,1),transformedImage(:,:,2),transformedImage(:,:,3))
shading flat
%}


