function XX = CrossCorrelationCoefficient(RefImage,ScanImage)
XX = sum(sum(RefImage.*ScanImage/(std(RefImage(:))*std(ScanImage))))/numel(RefImage);