function MI = CalcMutualInformation(ImageA,ImageB)
% Calculates the Mutual Information between two images
% Mutual Information: MI = I_A + I_B - I_AB where
%       I_A is the entropy of image A
%       I_B is the entropy of image B
%       I_AB is the entropy of the combined probability histograms for image A and B


Ia = ConvertToInt8(ImageA);
Ib = ConvertToInt8(ImageB);

%Get Image Histograms
Pa = imhist(Ia);
Pb = imhist(Ib);
Pab = Pa+Pb;

%Remove Zero Entries from Probability vector
Pa = Pa(Pa>0);
Pb = Pb(Pb>0);
Pab = Pab(Pab>0);

%Normalize Probabilities
Pa = Pa ./ numel(Ia);
Pb = Pb ./ numel(Ib);
Pab = Pab ./ (numel(Ia)+numel(Ib));

%Calculate Entropies
I_A = -sum(Pa.*log2(Pa));
I_B = -sum(Pb.*log2(Pb));
I_AB = -sum(Pab.*log2(Pab));

MI = I_A+I_B-I_AB;

end

function I = ConvertToInt8(Image)
%Convert to uint8
I = Image;
I = I - min(I(:));
I = 255/max(I(:))*I;
I = uint8(I);
I = uint8(I);

end
