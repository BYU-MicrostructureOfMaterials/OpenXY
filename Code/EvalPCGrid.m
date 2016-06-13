function [PCopt,pp] = EvalPCGrid(strainvals,pcvals,plots)
thresh = 5e-3;
if nargin < 3
    plots = 1;
end
[numpats] = size(strainvals);

%Remove bad points
ginds = median(strainvals,1)<thresh;
strainvals_filt = strainvals(:,ginds);
pcvals_filt = pcvals(:,ginds);
numpc_filt = length(strainvals_filt);

numlow = sum(strainvals_filt<thresh,1);
[nlow, indlow] = max(numlow);

%Pick out best patterns
qq = strainvals_filt(:,indlow)<thresh;
nn = 1:numpats;
nn = nn(qq);

%Get Median lines
thismean = zeros(1,numpc_filt);
medianPC = zeros(1,numpc_filt);
for i=1:numpc_filt
    thismean(i)=median(strainvals_filt(qq,i));
    medianPC(i)=median(pcvals_filt(qq,i));
end

%Apply Quadratic Fit
pp=polyfit(medianPC,thismean,2);
PCopt=-pp(2)/2/pp(1);
PCfit = pp(1)*medianPC.^2+pp(2)*medianPC+pp(3);
minstrain = pp(1)*PCopt^2+pp(2)*PCopt+pp(3);

if plots
    hold on
    for i=1:nlow
        plot(pcvals_filt(nn(i),:),strainvals_filt(nn(i),:),'*'); 
    end
    plot(medianPC,thismean); ylim([0 0.01]);
    plot(medianPC,PCfit,'k','LineWidth',1);
    scatter(PCopt,minstrain,'kd','MarkerFaceColor','k');
end









