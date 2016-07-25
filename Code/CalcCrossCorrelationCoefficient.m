function XX = CalcCrossCorrelationCoefficient(A,B)
XX = sum(sum(A.*B/(std(A(:))*std(B))))/numel(A);