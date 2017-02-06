function vector = VectorPoints(startpoint,endpoint)
% VECTORPOINTS
% Given two points in a map, returns a vector points that connects the two
% points

% Get vector between points
vec = endpoint-startpoint;

% Generate a scale from 0-1 with about 1 point per pixel
len = norm(vec);
scale = linspace(0,1,round(len))';

% Get a list of points for the vector
vector = round([scale*vec(1) scale*vec(2)]);

% Add to the startpoint
vector = vector+startpoint;

% Remove any zeros
vector(any(vector == 0,2),:) = [];

% inds = sub2ind2(mapsize,vector(:,1),vector(:,2),Settings.ScanType);
% plot(vector(:,1),vector(:,2),'kd')
