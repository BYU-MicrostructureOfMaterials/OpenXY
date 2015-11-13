close all

strain = cellfun(@(x) CalcStrain(x),Settings.Iterations.F,'UniformOutput',false);
strain = cell2mat(strain);
strain = reshape(strain,Settings.ScanLength,3,'');
u11 = squeeze(strain(:,1,:));
u22 = squeeze(strain(:,2,:));
u33 = squeeze(strain(:,3,:));
tet = u33-(u11+u22)/2;
SSE = Settings.Iterations.SSE;
XX = cellfun(@(x) mean(x(:,1)),Settings.Iterations.XX);
CS = cellfun(@(x) mean(x(:,2)),Settings.Iterations.XX);
MI = cellfun(@(x) mean(x(:,3)),Settings.Iterations.XX);

col = hsv(9);
fig1 = figure;
s11 = subplot(2,1,1);
s12 = subplot(2,1,2);
fig2 = figure;
s21 = subplot(4,1,1);
s22 = subplot(4,1,2);
s23 = subplot(4,1,3);
s24 = subplot(4,1,4);
iptwindowalign(fig1,'right',fig2,'left')
iptwindowalign(fig2,'top',fig1,'top')

for i = 1:9
    cla(s11)
    ylim(s11,[-0.03, 0.03])
    hold(s11,'on')
    plot(s11,u11(:,1:i-1),'r:')
    plot(s11,u11(:,i),'r')
    plot(s11,u22(:,1:i-1),'g:')
    plot(s11,u22(:,i),'g')
    plot(s11,u33(:,1:i-1),'b:')
    plot(s11,u33(:,i),'b')
    
    cla(s12)
    ylim(s12,[-0.01, 0.08])
    hold(s12,'on')
    plot(s12,tet(:,1:i-1),'b:')
    plot(s12,tet(:,i),'b')
    pause(0.5)
    
    cla(s21)
    hold(s21,'on')
    plot(s21,SSE(:,1:i-1),'r:')
    plot(s21,SSE(:,i),'r')
    
    cla(s22)
    hold(s22,'on')
    plot(s22,XX(:,1:i-1),'b:')
    plot(s22,XX(:,i),'b')
    
    cla(s23)
    hold(s23,'on')
    plot(s23,CS(:,1:i-1),'g:')
    plot(s23,CS(:,i),'g')
    
    cla(s24)
    hold(s24,'on')
    plot(s24,MI(:,1:i-1),'c:')
    plot(s24,MI(:,i),'c')
end

