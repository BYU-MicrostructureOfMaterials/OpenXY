function rsqA = rSquaredAdjusted(measuredData, fitData, numFitVariables)

rsq = computations.metrics.rSquared(measuredData, fitData);
sampleSize = length(measuredData);
rsqA = 1 - (1 - rsq) * (sampleSize - 1) / (sampleSize - numFitVariables - 1);

end

