function [F, g, U, fitMetrics, XX, sigma, PCnew] = SwitchGetDefGrad (ImageInd,Settings,curMaterial)



%convergeMethod = 'Fdelta';
%disp(Settings.convMethod)
switch Settings.convMethod
    case 'Original'
      [F, g, U, fitMetrics, XX, sigma] = GetDefGradientTensor(ImageInd,Settings,curMaterial);
%       disp(fitMetrics)
      PCnew = [Settings.XStar(ImageInd), Settings.YStar(ImageInd),Settings.ZStar(ImageInd)];
    case 'Fdelta'
        isDynamic = strcmp(Settings.HROIMMethod, 'Dynamic Simulated');
        isKinematic = strcmp(Settings.HROIMMethod, 'Simulated');
        if isDynamic || isKinematic
            [F, g, U, fitMetrics, XX, sigma, PCnew] = GetDefGradientTensorNew(ImageInd,Settings,curMaterial);
            %disp('Fdelta case')
%             disp(fitMetrics)
        else
            disp('Non-Simulated Fdelta case not implemented. Using Original case.')
            [F, g, U, fitMetrics, XX, sigma] = GetDefGradientTensor(ImageInd,Settings,curMaterial);
            PCnew = [Settings.XStar(ImageInd), Settings.YStar(ImageInd),Settings.ZStar(ImageInd)];
        end

end
end