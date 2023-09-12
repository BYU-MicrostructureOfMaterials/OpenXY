% Copyright 2021 National Technology & Engineering Solutions of Sandia, LLC (NTESS).
% Under the terms of Contract DE-NA0003525 with NTESS, the U.S. Government retains certain rights in this software.
% Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files
% (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge,
% publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do
% so, subject to the following conditions:
% The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
% OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
% LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
% IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


function [F_crystal, PC_final] = CalcF_KBS(Pattern, g_initial, PC_initial, phase, Qps, elevang, mperpix)

% Qps = Qps*[0 1 0;-1 0 0;0 0 1]; %Rotating Qps to align with the natural frame of the matrix
Qps = Qps*[0 -1 0;-1 0 0;0 0 1]; 
%Likely, I need to adjust PC as well

PC_initial(2) = 1 - PC_initial(2);

temp = PC_initial(1);
PC_initial(1) = PC_initial(2);
PC_initial(2) = temp;

hkl = SelectBands(g_initial, PC_initial, phase, Qps);

SimPattern = genEBSDPatternHybrid_fromEMSoft(g_initial,PC_initial(1),PC_initial(2),PC_initial(3),...
    size(Pattern,1),mperpix,elevang*pi/180,70*pi/180,phase,20000);

M = TrainBandletNets(SimPattern, hkl, PC_initial);

TestM(size(Pattern),M,hkl,PC_initial);

% N = 10;
% fitnesses = ProbeSpace(Pattern, M, hkl, PC_initial, N, [1 10], 100/1e6);
% figure; imagesc(fitnesses); axis image; colormap('jet');
% caxis([min(min(fitnesses)) fitnesses(floor(N/2),floor(N/2))+.00001])

drawnow

profile on
[F_p, PC_final] = FitHyperbolas(Pattern, M, hkl, PC_initial);
profile viewer
F_sample = Qps*F_p*(Qps');
F_crystal = g_initial*F_sample*(g_initial');

g_actual = euler2gmat(.5,.2,.08);
F_ideal = (Qps')*(g_actual')*g_initial*Qps;
b = F_ideal - eye(3);
x_ideal = [b(1,1);b(1,2);b(1,3);b(2,1);b(2,2);b(2,3);b(3,1);b(3,2);b(3,3)];
PC_actual = [.5;.5;.6];
PC_actual(2) = 1 - PC_actual(2);
x_ideal = [PC_actual;x_ideal];
actualbest = multibandletfitfun(x_ideal, Pattern, M, hkl);
display(actualbest)

error = 1e6*(F_ideal - F_p)
gerror = 1e6*(F_ideal - poldec(F_p))

end

function fitnesses = ProbeSpace(Pattern, M, hkl, PC_initial, N, varinds, stepsize)
fitnesses = zeros(N);
xi = zeros(12,1);
xi(1:3) = PC_initial(1:3);
for o=1:N
    o
    for p=1:N
        stepvec = zeros(size(xi));
        stepvec(varinds(1)) = (o-floor(N/2))*stepsize*(1*(varinds(1)>3) + PC_initial(3)*(varinds(1)<4));
        stepvec(varinds(2)) = (p-floor(N/2))*stepsize*(1*(varinds(2)>3) + PC_initial(3)*(varinds(2)<4));
        thisx = xi + stepvec;
        fitnesses(o,p) = multibandletfitfun(thisx, Pattern, M, hkl);
    end
end
end

function [F, PC_final] = FitHyperbolasNoPC(Pattern, M, hkl, PC_initial)
xi = zeros(9,1); %no way to add in intitial strains again

bandletfitfun = @(x) multibandletfitfunnoPC(x, Pattern, M, hkl, PC_initial);

% fmuopts = optimoptions('fminunc','StepTolerance', 1e-8, ...
%     'OptimalityTolerance', 1e-10, 'Display', 'iter-detailed');
% xf = fminunc(bandletfitfun,xi, fmuopts);

amoebaoptions.StartingPoint = xi;
amoebaoptions.StartingStep = .005;
amoebaoptions.TerminationCondition = 1e-6;
amoebaoptions.maxfcalls = 1000;
[xf, bestFval, numfcalls] = AmoebaOpt(bandletfitfun, amoebaoptions);

PC_final = PC_initial;
beta = [xf(1) xf(2) xf(3);xf(4) xf(5) xf(6);xf(7) xf(8) xf(9)];
F = beta + eye(3);

end

function corrparam = multibandletfitfunnoPC(x, Pattern, M, hkl, PC)
beta = [x(1) x(2) x(3);x(4) x(5) x(6);x(7) x(8) x(9)];
F = beta + eye(3);
mn = size(Pattern);
numbands = length(hkl);
corrparam = 0;
for j=1:numbands
    
    vhat = F*hkl{j}.vhat;
    nvhat = norm(vhat);
    vhat = vhat/nvhat;
    
    eps = 1/nvhat - 1;%This is an approximation.  Need lambda and a for proper bragg angle matching.  Smarter than me for who band profile matching
    
    psi_band_old = hkl{j}.psi_band;
    psi_min_old = hkl{j}.psi_min;
    psi_max_old = hkl{j}.psi_max;
    
    thmin = hkl{j}.thmin;
    thmax = hkl{j}.thmax;
    
    thispsi = atan2(vhat(2),vhat(1));
    
    psi_min = thispsi - psi_band_old + psi_min_old; %this is wonky, wont work with weird hyperbolae
    psi_max = thispsi - psi_band_old + psi_max_old;
    
    [thetas,dds] = XYtoHyperTheta(mn, PC, vhat);
    mask = (thetas < thmin).*(thetas > thmax);%Switched the inequalities for cos instead of th
    
%     sb = simbandlet(mn,M{j},thetas,dds,eps);%This is prolly too slow
%     rb = extractbandlet(Pattern, psi_min, psi_max);
%     sb = sb.*mask;
%     rb = rb.*mask;

    sb = simbandletvec(M{j},thetas(mask==1),dds(mask==1),eps);
    rb = extractbandlet(Pattern, psi_min, psi_max);
    rb = rb(mask==1);
    rb = rb';

%     figure(100); imagesc(sb); axis image; colormap('jet')
%     figure(101); imagesc(rb); axis image; colormap('jet')
%     drawnow
    
%     sbm = mean(mean(sb));
%     rbm = mean(mean(rb));
%     
%     sb = (sb - sbm)./sqrt(sum(sum((sb - sbm).^2)));
%     rb = (rb - rbm)./sqrt(sum(sum((rb - rbm).^2)));
%     
%     corrparam = corrparam + sum(sum((rb - sb).^2));%Might have a scaling issue with this objective function

    sbm = mean(sb);
    rbm = mean(rb);
    
    sb = (sb - sbm)./sqrt(sum((sb - sbm).^2));
    rb = (rb - rbm)./sqrt(sum((rb - rbm).^2));
    
    figure(100 + j); plot(thetas(mask==1),rb,'r.')
    hold on; plot(thetas(mask==1),sb,'b.')
    hold off
    
    corrparam = corrparam + sum((rb - sb).^2);
    
end
end


function [F, PC_final] = FitHyperbolas(Pattern, M, hkl, PC_initial)
xi = zeros(12,1); %no way to add in intitial strains again
xi(1:3) = PC_initial(1:3);

bandletfitfun = @(x) multibandletfitfun(x, Pattern, M, hkl);

fmuopts = optimoptions('fminunc','StepTolerance', 1e-8, ...
    'OptimalityTolerance', 1e-10, 'Display', 'iter-detailed');
xf = fminunc(bandletfitfun,xi, fmuopts);

% amoebaoptions.StartingPoint = xi;
% amoebaoptions.StartingStep = .03;
% amoebaoptions.TerminationCondition = 1e-10;
% amoebaoptions.maxfcalls = 1000;
% [xf, bestFval, numfcalls] = AmoebaOpt(bandletfitfun, amoebaoptions);

PC_final = xf(1:3);
beta = [xf(4) xf(5) xf(6);xf(7) xf(8) xf(9);xf(10) xf(11) xf(12)];
F = beta + eye(3);

end

function corrparam = multibandletfitfun(x, Pattern, M, hkl)
PC = [x(1);x(2);x(3)];
beta = [x(4) x(5) x(6);x(7) x(8) x(9);x(10) x(11) x(12)];
F = beta + eye(3);
mn = size(Pattern);
numbands = length(hkl);
corrparam = 0;
for j=1:numbands
    
    vhat = F*hkl{j}.vhat;
    nvhat = norm(vhat);
    vhat = vhat/nvhat;
    
    eps = 1/nvhat - 1;%This is an approximation.  Need lambda and a for proper bragg angle matching.  Smarter than me for who band profile matching
    
    psi_band_old = hkl{j}.psi_band;
    psi_min_old = hkl{j}.psi_min;
    psi_max_old = hkl{j}.psi_max;
    
    thmin = hkl{j}.thmin;
    thmax = hkl{j}.thmax;
    
    thispsi = atan2(vhat(2),vhat(1));
    
    psi_min = thispsi - psi_band_old + psi_min_old; %this is wonky, wont work with weird hyperbolae
    psi_max = thispsi - psi_band_old + psi_max_old;
    
    [thetas,dds] = XYtoHyperTheta(mn, PC, vhat);
    mask = (thetas < thmin).*(thetas > thmax);%Switched the inequalities for cos instead of th
    
%     sb = simbandlet(mn,M{j},thetas,dds,eps);%This is prolly too slow
%     rb = extractbandlet(Pattern, psi_min, psi_max);
%     sb = sb.*mask;
%     rb = rb.*mask;

    sb = simbandletvec(M{j},thetas(mask==1),dds(mask==1),eps);
    rb = extractbandlet(Pattern, psi_min, psi_max);
    rb = rb(mask==1);
    rb = rb';

%     figure(100); imagesc(sb); axis image; colormap('jet')
%     figure(101); imagesc(rb); axis image; colormap('jet')
%     drawnow
    
%     sbm = mean(mean(sb));
%     rbm = mean(mean(rb));
%     
%     sb = (sb - sbm)./sqrt(sum(sum((sb - sbm).^2)));
%     rb = (rb - rbm)./sqrt(sum(sum((rb - rbm).^2)));
%     
%     corrparam = corrparam + sum(sum((rb - sb).^2));%Might have a scaling issue with this objective function

    sbm = mean(sb);
    rbm = mean(rb);
    
    sb = (sb - sbm)./sqrt(sum((sb - sbm).^2));
    rb = (rb - rbm)./sqrt(sum((rb - rbm).^2));
    
    figure(100 + j); plot(thetas(mask==1),rb,'r.')
    hold on; plot(thetas(mask==1),sb,'b.')
    hold off
    
    corrparam = corrparam + sum((rb - sb).^2)/length(rb);
    
end
end

function hkl = SelectBands(g, PC, phase, Qps)
hkl{1}.Miller = [1;0;-1];%10-1
hkl{1}.vhat = (Qps')*(g')*hkl{1}.Miller;
hkl{1}.vhat = hkl{1}.vhat/norm(hkl{1}.vhat);
hkl{1}.thmin = cos(1.525);
hkl{1}.thmax = cos(1.625);
psi_band = atan2(hkl{1}.vhat(2),hkl{1}.vhat(1));
psi_tol = 3*pi/180;
hkl{1}.psi_min = psi_band - psi_tol;
hkl{1}.psi_max = psi_band + psi_tol;
hkl{1}.psi_band = psi_band;

hkl{2}.Miller = [1;1;0];
hkl{2}.vhat = (Qps')*(g')*hkl{2}.Miller;
hkl{2}.vhat = hkl{2}.vhat/norm(hkl{2}.vhat);
hkl{2}.thmin = cos(1.525);
hkl{2}.thmax = cos(1.625);
psi_band = atan2(hkl{2}.vhat(2),hkl{2}.vhat(1));
psi_tol = 3*pi/180;
hkl{2}.psi_min = psi_band - psi_tol;
hkl{2}.psi_max = psi_band + psi_tol;
hkl{2}.psi_band = psi_band;

hkl{3}.Miller = [1;-1;0];
hkl{3}.vhat = (Qps')*(g')*hkl{3}.Miller;
hkl{3}.vhat = hkl{3}.vhat/norm(hkl{3}.vhat);
hkl{3}.thmin = cos(1.525);
hkl{3}.thmax = cos(1.625);
psi_band = atan2(hkl{3}.vhat(2),hkl{3}.vhat(1));
psi_tol = 3*pi/180;
hkl{3}.psi_min = psi_band - psi_tol;
hkl{3}.psi_max = psi_band + psi_tol;
hkl{3}.psi_band = psi_band;

% hkl{4}.Miller = [1;1;-1];
% hkl{4}.vhat = (Qps')*(g')*hkl{4}.Miller;
% hkl{4}.vhat = hkl{4}.vhat/norm(hkl{4}.vhat);
% hkl{4}.thmin = cos(87*pi/180);
% hkl{4}.thmax = cos(93*pi/180);
% psi_band = atan2(hkl{4}.vhat(2),hkl{4}.vhat(1));
% psi_tol = 3*pi/180;
% hkl{4}.psi_min = psi_band - psi_tol;
% hkl{4}.psi_max = psi_band + psi_tol;
% hkl{4}.psi_band = psi_band;

% hkl{5}.Miller = [-1;1;1];
% hkl{5}.vhat = (Qps')*(g')*hkl{5}.Miller;
% hkl{5}.vhat = hkl{5}.vhat/norm(hkl{5}.vhat);
% hkl{5}.thmin = cos(87*pi/180);
% hkl{5}.thmax = cos(93*pi/180);
% psi_band = atan2(hkl{5}.vhat(2),hkl{5}.vhat(1));
% psi_tol = 3*pi/180;
% hkl{5}.psi_min = psi_band - psi_tol;
% hkl{5}.psi_max = psi_band + psi_tol;
% hkl{5}.psi_band = psi_band;

end

function M = TrainBandletNets(SimPattern, hkl, PC_initial)
[m,n] = size(SimPattern);
for i=1:length(hkl)
    bandlet = extractbandlet(SimPattern, hkl{i}.psi_min, hkl{i}.psi_max);
    figure(99); imagesc(bandlet); axis image
    
    [thetas,dds] = XYtoHyperTheta(size(SimPattern), PC_initial, hkl{i}.vhat);
    thvec = reshape(thetas,m*n,1);
    ddvec = reshape(dds,m*n,1);

    inputs = [thvec((thvec < hkl{i}.thmin)&(thvec>hkl{i}.thmax)) ddvec((thvec < hkl{i}.thmin)&(thvec>hkl{i}.thmax))]';
    targets = reshape(real(bandlet),m*n,1);
    targets = targets((thvec < hkl{i}.thmin)&(thvec>hkl{i}.thmax))';
    
    figure; plot3(squeeze(inputs(1,:)),squeeze(inputs(2,:)), targets, '.')
    hold on

    hiddenLayerSize = 15;
    net = fitnet(hiddenLayerSize);
    net.divideParam.trainRatio = 70/100;
    net.divideParam.valRatio = 15/100;
    net.divideParam.testRatio = 15/100;
    [net,~] = train(net,inputs,targets);
    
    outputs = simbandletvec(net,squeeze(inputs(1,:))',squeeze(inputs(2,:))',0);
    
    plot3(squeeze(inputs(1,:)),squeeze(inputs(2,:)), outputs, 'r.')
    
    M{i} = net;
end
end

function bandlet = extractbandlet(pat, psi_min, psi_max)

mask = genbandletmask(size(pat), psi_min,psi_max);
Fpat = fftn(pat);
bandlet = real(ifftn(Fpat.*ifftshift(mask)));

end

% function mask = genbandletmask(mn, psi_min,psi_max)
% m = mn(1);
% n = mn(2);
% mask = zeros(m,n);
% tempvec = round(([m,n] + 1)/2);
% cx = tempvec(1);
% cy = tempvec(2);
% maskmax = max(m,n)/2;
% maskmin = 10;
% for i=1:m
%     for j=1:n
%         thispsi = atan2((j - cy),(i - cx));
%         thispsi2 = thispsi + pi;
%         if thispsi2 > pi
%             thispsi2 = thispsi2 - 2*pi;
%         end
%         if (thispsi > psi_min) && (thispsi < psi_max)
%             if sqrt((i-cx)*(i-cx) + (j-cy)*(j-cy)) > maskmin
%                 if sqrt((i-cx)*(i-cx) + (j-cy)*(j-cy)) < maskmax
%                     mask(i,j) = 1;
%                 end
%             end
%         end
%         if (thispsi2 > psi_min) && (thispsi2 < psi_max)
%             if sqrt((i-cx)*(i-cx) + (j-cy)*(j-cy)) > maskmin
%                 if sqrt((i-cx)*(i-cx) + (j-cy)*(j-cy)) < maskmax
%                     mask(i,j) = 1;
%                 end
%             end
%         end
%     end
% end
% end

function mask = genbandletmask(mn, psi_min,psi_max)
m = mn(1);
n = mn(2);
tempvec = round(([m,n] + 1)/2);
cx = tempvec(1);
cy = tempvec(2);
maskmax = (max(m,n)/2)^2;
maskmin = 100;

[Y,X] = meshgrid(1:m,1:n);

minslope = min(tan(psi_min),tan(psi_max));
maxslope = max(tan(psi_min),tan(psi_max));

slopemap = (Y-cy)./(X-cx);
d = ((Y-cy).*(Y-cy) + (X-cx).*(X-cx));

mask = (slopemap > minslope) & (slopemap < maxslope) & (d > maskmin) & (d < maskmax);

kernel = fspecial('gaussian',9,6);%9,4

mask = smearmat(mask,kernel);

end

function bandlet = simbandlet(mn,Mnet,thetas,dds,eps)
m = mn(1);
n = mn(2);
thvec = reshape(thetas,m*n,1); %Should only calculate for thetas in a range
ddvec = reshape(dds,m*n,1);
bandlet = Mnet([(thvec)./(1+eps) ddvec]');%-pi/2
bandlet = reshape(bandlet,m,n);
end

function bandlet = simbandletvec(Mnet,thvec,ddvec,eps)
bandlet = Mnet([(thvec)./(1+eps) ddvec]');%-pi/2
end

function figpointer = TestM(mn,M,hkl,PC)
numbands = length(M);
figpointer = figure;
for i=1:numbands
    Mnet = M{i};
    vhat = hkl{i}.vhat;
    eps = 0;
    [thetas,dds] = XYtoHyperTheta(mn, PC, vhat);
    bandlet = simbandlet(mn,Mnet,thetas,dds,eps);
    subplot(1,numbands,i)
    imagesc(bandlet)
    colormap('gray')
    axis image
    axis off
end
end

% function [thetas, dds] = XYtoHyperTheta(mn, PC, vhat)
% m = mn(1);
% n = mn(2);
% thetas = zeros(m,n);
% dds = thetas;
% for i=1:m %use meshgrid instead of a loop?
%     for j=1:n
%        P = [(i-.5)/m; (j-.5)/m; 0]; %Reference frames will be a nightmare
%        dPC = P - PC;
%        ndPC = sqrt(sum(dPC.*dPC));
%        thetas(i,j) = sum(dPC/ndPC.*vhat);%acos((dot(P-PC,vhat)/norm(P-PC)));
%        dds(i,j) = ndPC;
%     end
% end
% end

function [thetas, dds] = XYtoHyperTheta(mn, PC, vhat)
m = mn(1);
n = mn(2);
[Y,X] = meshgrid(1:m,1:n);
Y = (Y-.5)/m;
X = (X-.5)/m;

dPCx = X - PC(1);
dPCy = Y - PC(2);
dds = sqrt(dPCx.*dPCx + dPCy.*dPCy + PC(3)*PC(3));

thetas = dPCx*vhat(1) + dPCy*vhat(2) - vhat(3)*PC(3);
thetas = thetas./dds;


end