function fitMetrics = fitMetrics(cx, cy, Cshift, Rshift, keepInds)

if nargin == 0 || (nargin == 1 && strcmp(cx, 'bad'))
    %If no arguments, return defalt 'null' values
    fitMetrics.SSE = inf;
    fitMetrics.rsqX = 0;
    fitMetrics.rsqY = 0;
    fitMetrics.rsq = 0;
    return;
end

if nargin == 1 && strcmp(cx, 'good')
    fitMetrics.SSE = 0;
    fitMetrics.rsqX = 1;
    fitMetrics.rsqY = 1;
    fitMetrics.rsq = 1;
    return;

end

usedCshift = Cshift(keepInds);
usedRshift = Rshift(keepInds);

usedCx = cx(keepInds);
usedCy = cy(keepInds);

numUsed = length(keepInds);

% Squared Sum of Error
fitMetrics.SSE=sqrt(sum(...
    (usedCx - usedCshift).^2 + ...
    (usedCy - usedRshift).^2 ...
    ) / numUsed);

rsq_x = computations.metrics.rSquared(usedCshift, usedCx);
rsq_y = computations.metrics.rSquared(usedRshift, usedCy);

meanCShift = mean(usedCshift);
meanRshift = mean(usedRshift);
newShift = [(usedCshift - meanCShift) (usedRshift - meanRshift)];
newC = [(usedCx - meanCShift) (usedCy - meanRshift)];

rsq_all = computations.metrics.rSquared(newShift, newC);

fitMetrics.rsqX = rsq_x;
fitMetrics.rsqY = rsq_y;
fitMetrics.rsq = rsq_all;

end

