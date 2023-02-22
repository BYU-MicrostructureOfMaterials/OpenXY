function [F, fitMetrics, XX, sigma] = SwitchF(RefImage, ScanImage, g, Fo, Ind, Settings, curMaterial, RefInd, PC)
%disp('I MADE IT INTO MY FUNCTION!!!! ISN''T THAT GREAT!')
%this is from line 276 in GetDefGradientTensor.m
%maybe figure out how to store a bunch of data in a struct and just pass
%the whole struct into it? and then delete the struct later? IDK......

%F_file = 'CalcF';

% disp(nargin)
%disp(Settings.calcMethod)
if nargin > 8
    check = true; % yes PC
else
    check = false; %no PC
end

switch Settings.calcMethod 
    case 'CalcF'
        if check
            %disp('PC')
            [F, fitMetrics, XX, sigma] = CalcF(RefImage, ScanImage, g, Fo, Ind, Settings, curMaterial, RefInd, PC);
        else
            %disp('NO PC')
            [F, fitMetrics, XX, sigma] = CalcF(RefImage, ScanImage, g, Fo, Ind, Settings, curMaterial, RefInd);
        end
        
%         disp(fitMetrics)


    case 'XASGO'
        F = CalcF_XASGO(RefImage, ScanImage, RefInd, Ind, Settings);
        fitMetrics.SSE = 999;
        fitMetrics.rsqX = 0;
        fitMetrics.rsqY = 0;
        fitMetrics.rsq = 0;
%         disp(fitMetrics)
        XX = -1 * ones(Settings.NumROIs, 3);
        sigma = -eye(3);
    
    otherwise
        disp('There has been a problem with the calculation method')
end

end

