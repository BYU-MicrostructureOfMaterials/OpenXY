function fitMetrics = fitMetrics(cx, cy, Cshift, Rshift, keepInds)

if nargin == 0
    %If no arguments, return defalt 'null' values
    fitMetrics.SSE = inf;
    fitMetrics.rsqX = 0;
    fitMetrics.rsqY = 0;
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

fitMetrics.rsqX = rsq_x;
fitMetrics.rsqY = rsq_y;
end