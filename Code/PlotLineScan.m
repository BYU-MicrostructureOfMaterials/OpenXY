function Results = PlotLineScan(Settings)
% to plot data from analysis parameters - first load mat file
if isfield(Settings,'ScanLength')
    NN = Settings.ScanLength;
else
    NN = length(Settings.ImageNamesList);
    Settings.ScanLength = NN;
end
tempF=zeros(3,3);
for i=1:NN
    tempF(:,:)=Settings.data.F(:,:,i);
    [tempR, tempU]=poldec(tempF);
    tempU=tempU-eye(3);
    u33(i)=tempU(3,3); 
    u22(i)=tempU(2,2);
    u11(i)=tempU(1,1);
end
figure; plot([1:NN],u11*100,'r',[1:NN],u22*100,'g',[1:NN],u33*100)
grid on
set(gca,'fontsize',16)
xlabel('Scan position (\mum)')
ylabel('Strain (%)')
ylim([-1.5 1])
%axis([0 NN -1.5 1]);
legend('\epsilon_1_1','\epsilon_2_2','\epsilon_3_3')

tempF=zeros(3,3);
for i=1:NN 
    tempF(:,:)=Settings.data.F(:,:,i);
    [tempR tempU]=poldec(tempF);
    temptet(i)=tempU(3,3)-(tempU(1,1)+tempU(2,2))/2;
end
figure;plot(temptet*100)
grid on
set(gca,'fontsize',16)
xlabel('Scan position (\mum)')
ylabel('Tetragonality (%)')
ylim([-.5 2])
if isfield(Settings,'ScanData')
    hold on
    ExpTet = ones(1,Settings.ScanLength)*Settings.ScanData.ExpTet;
    plot(ExpTet,'--','Color',[1 1 1]*0.5);
end
    
%axis([0 NN -0.5 2]);

Results = AnalyzeLineScan(Settings);
