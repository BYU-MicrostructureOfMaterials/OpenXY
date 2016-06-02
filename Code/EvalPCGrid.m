function [PCopt,pp] = EvalPCGrid(strainvals,pcvals,plots)
if nargin < 3
    plots = 1;
end
[numpats,numpc] = size(strainvals);
numlow = sum(strainvals<5e-3,1);
[nlow, indlow] = max(numlow);

%Pick out best patterns
qq = strainvals(:,indlow)<5e-3;
nn = 1:numpats;
nn = nn(qq);

%Get Median lines
thismean = zeros(1,numpc);
medianPC = zeros(1,numpc);
for i=1:numpc
    thismean(i)=median(strainvals(qq,i));
    medianPC(i)=median(pcvals(qq,i));
end

%Apply Quadratic Fit
pp=polyfit(medianPC,thismean,2);
PCopt=-pp(2)/2/pp(1);
PCfit = pp(1)*medianPC.^2+pp(2)*medianPC+pp(3);
minstrain = pp(1)*PCopt^2+pp(2)*PCopt+pp(3);

if plots
    hold on
    for i=1:nlow
        plot(pcvals(nn(i),:),strainvals(nn(i),:),'*'); 
    end
    plot(medianPC,thismean); ylim([0 0.01]);
    plot(medianPC,PCfit,'k','LineWidth',1);
    scatter(PCopt,minstrain,'kd','MarkerFaceColor','k');
end









