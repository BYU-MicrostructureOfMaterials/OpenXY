function [F, fitMetrics, XX, sigma] = theFUN(RefImage, ScanImage, g, Fo, Ind, Settings, curMaterial, RefInd, PC)
disp('I MADE IT INTO MY FUNCTION!!!! ISN''T THAT GREAT!')
%this is from line 276 in GetDefGradientTensor.m
%maybe figure out how to store a bunch of data in a struct and just pass
%the whole struct into it? and then delete the struct later? IDK......

F_file = 'Original'

if nargin > 8
    check = true; % yes PC
else
    check = false; %no PC
end

switch F_file
    case 'Original'
        if check
            disp('PC')
            [F, fitMetrics, XX, sigma] = CalcF(RefImage, ScanImage, g, Fo, Ind, Settings, curMaterial, RefInd, PC);
        else
            disp('NO PC')
            [F, fitMetrics, XX, sigma] = CalcF(RefImage, ScanImage, g, Fo, Ind, Settings, curMaterial, RefInd);
        end
        
    case 'XASGO'
        F = CalcF_XASGO(RefImage, ScanImage, RefINd, Ind, Settings);
end

end

