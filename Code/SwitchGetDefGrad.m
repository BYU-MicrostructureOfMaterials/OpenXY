function [F, g, U, fitMetrics, XX, sigma, PCnew] = SwitchGetDefGrad (ImageInd,Settings,curMaterial)



%convergeMethod = 'Fdelta';
%disp(Settings.convMethod)
switch Settings.convMethod
    case 'Original'
      [F, g, U, fitMetrics, XX, sigma] = GetDefGradientTensor(ImageInd,Settings,curMaterial);
    case 'Fdelta'
      [F, g, U, fitMetrics, XX, sigma, PCnew] = GetDefGradientTensorNew(ImageInd,Settings,curMaterial);
      %disp('Fdelta case')

end


end