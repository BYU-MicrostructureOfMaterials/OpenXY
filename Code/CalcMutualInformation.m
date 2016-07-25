function MI = CalcMutualInformation(ImageA,ImageB)
% Calculates the Mutual Information between two images
% Mutual Information: MI = I_A + I_B - I_AB where
%       I_A is the entropy of image A
%       I_B is the entropy of image B
%       I_AB is the entropy of the combined probability histograms for image A and B

Ia = ConvertToInt8(ImageA);
Ib = ConvertToInt8(ImageB);

%Calculate Normalized Joint Histogram (Probability)
pJ = accumarray([uint16(Ia(:))+1 uint16(Ib(:))+1], 1) / numel(Ia);

%Calculate Joint Entropy
pJ_NZ = pJ;
pJ_NZ(pJ_NZ==0) = [];
eJ = -sum(pJ_NZ.*log2(pJ_NZ));

%Get individual Normalized Histograms (Probability)
pA = sum(pJ,2);
pB = sum(pJ,1);

%Calculate Individual Entropies
pA_NZ = pA;
pB_NZ = pB;
pA_NZ(pA_NZ==0) = [];
pB_NZ(pB_NZ==0) = [];
eA = -sum(pA_NZ.*log2(pA_NZ));
eB = -sum(pB_NZ.*log2(pB_NZ));

MI = eA+eB-eJ;
end

function I = ConvertToInt8(Image)
%Convert to uint8
I = Image;
I = I - min(I(:));
I = 255/max(I(:))*I;
I = uint8(I);
I = uint8(I);

end
