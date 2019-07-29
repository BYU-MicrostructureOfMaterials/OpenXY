function rsq = rSquared(measuredData, fitData)

totalSumOfSquares = sum((measuredData - mean(measuredData)).^2);
ResidualSumOfSquares = sum((measuredData - fitData).^2);
rsq = 1 - ResidualSumOfSquares / totalSumOfSquares;