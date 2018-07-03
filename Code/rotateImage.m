function rotIm = rotateImage(im, gCurrent, gDestination, patternCenter,...
    lattice, sampleTilt, elevationAngle)
%ROTATEIMAGE Rotate an EBSD image from its current oreintation to another.
%   Given an EBSP and its oreintation, ROTATEIMAGE rotates the image so
%   that it apears in the same oreintation as another image.
%
%   Params:
%   im:             Then image to be rotated, a 2D real matrix.
%   gCurrent:       The g matrix that describes the oreintation of the
%                       crystal shown in im.
%   gDestination:   The g matrix that describes the oreintation that the
%                       crystal will be rotated to.
%   patternCenter:  The pattern center of the current point.
%   lattice:        The lattice of the cristal at the current point, either
%                   'Square' or 'Hexagonal'.
%   sampleTilt:     The tilt of the sample in the microscope.
%   elevationAngle: The elevation of EBSD camera, relative to the sample.
%
%   Written by Zach Clayburn & David Fullwood, June 2018




sz = size(im);

% Convert image to double to work with griddata
im = double(im);
xStar = patternCenter(1);
yStar = patternCenter(2);
zStar = patternCenter(3);

sz = sz(1);

[angle, axis] = GeneralMisoCalc(gCurrent, gDestination, lattice, true);

% axis = abs(axis);
u = gCurrent' * axis';
ubox = [
    0 -u(3) u(2)
    u(3) 0 -u(1)
    -u(2) u(1) 0
];
uxu = u*u';

R1 = cosd(angle)*eye(3) + sind(angle)*ubox + (1 - cosd(angle)) * uxu;

% Transformation from sample to phospher frame
Qes = [
    0 1 0
    1 0 0
    0 0 1
];
R = Qes*R1*Qes';

% Get X and Y coordinates of each pixel
vec = linspace(0,1,sz);
[y,x] = meshgrid(vec);
ang = pi/2 - sampleTilt + elevationAngle;
transformedImage = zeros(sz,sz,2);

Qps=[0      -1    0
    -cos(ang) 0 sin(ang);...
    sin(ang) 0 cos(ang)];

for ii = 1:sz
    for jj = 1:sz
        rc=[x(ii,jj);y(ii,jj);0]; % camera / image frame
        rp = rc+[-(1-yStar);-xStar;-zStar]; % position in phosphor frame relative to PC ***WHAT FRAME IS xstar IN???****
        rs = Qps*rp; % position in sample frame
        rsprime = transform(rs, R, zStar, ang); % rprime in sample frame
        rpprime=Qps'*rsprime; % rprime in phosphor frame (relative to PC)
        rcprime=[rpprime(1); rpprime(2)]+ [1-yStar;xStar]; % rprime in camera / image frame
        transformedImage(ii,jj,:) = rcprime;
    end
end

X = transformedImage(:,:,1);
Y = transformedImage(:,:,2);
Z = im;

% Interpolate new image from rotated data
rotIm = griddata(Y(:), X(:), Z(:), y, x, 'cubic');
% Remove NaN values from outside the original image
rotIm(isnan(rotIm)) = min(im(:));
end

function rprime = transform(r, R, zStar, ang)
% Algorithm explaned in:
% On solving the orientation gradient dependency of high angular resolution
%   EBSD
% Maurice et. al.
% https://doi.org/10.1016/j.ultramic.2011.10.013
k = [0;-sin(ang);-cos(ang)];
k=k/norm(k);
R_times_r = (R * r);
denom = dot(R_times_r, k);
rprime = (zStar / denom) * R_times_r;
end
