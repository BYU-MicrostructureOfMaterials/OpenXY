function Sec = SectionLineScan(Strain)

u11 = Strain(:,1);
u22 = Strain(:,2);
u33 = Strain(:,3);

NN = length(u11);
MaxMin_Percent = 0.1;

% u11 = smooth(u11)';
% u22 = smooth(u22)';
% u33 = smooth(u33)';

% u11_sort = sort(u11);a
% u22_sort = sort(u22);
% u33_sort = sort(u33);
% 
% u11_min = mean(u11_sort(1:round(NN*MaxMin_Percent)));
% u22_min = mean(u22_sort(1:round(NN*MaxMin_Percent)));
% u33_min = mean(u33_sort(1:round(NN*MaxMin_Percent)));
% 
% u11_max = mean(u11_sort(round(NN*(1-MaxMin_Percent)):end));
% u22_max = mean(u22_sort(round(NN*(1-MaxMin_Percent)):end));
% u33_max = mean(u33_sort(round(NN*(1-MaxMin_Percent)):end));

u11_diff = u11(2:end) - u11(1:end-1);
u22_diff = u22(2:end) - u22(1:end-1);
u33_diff = u33(2:end) - u33(1:end-1);

u11_out = abs(u11_diff - median(u11_diff)) > 2*std(u11_diff);

u11_diff(~u11_out) = 0;
inds = 1:length(u11_diff);
Sec = [1 inds(u11_diff ~= 0) length(u11_diff)];

%Combine close outliers
i = 2;
while i <= length(Sec)
    if Sec(i) - Sec(i-1) < 10
        Sec(i) = [];
    else
        i = i + 1;
    end
end


