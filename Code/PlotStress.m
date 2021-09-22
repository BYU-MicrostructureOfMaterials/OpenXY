function PlotStress(Settings)

lim = [-12,12];

sigma = CrystaltoSample(Settings.data.sigma,Settings.NewAngles);

% Von Mises Stress
VonMises = sqrt(((sigma(1,1,:)-sigma(2,2,:)).^2 + (sigma(2,2,:)-sigma(3,3,:)).^2 + (sigma(3,3,:)-sigma(1,1,:)).^2 + ...
    6*(sigma(1,2,:).^2 + sigma(2,3,:).^2 + sigma(3,1,:).^2))/2);

% Principal Stresses
p_stress = zeros(3,Settings.ScanLength);
for i = 1:Settings.ScanLength
    p_stress(:,i) = eig(sigma(:,:,i));
end
p_stressmap = vec2map(p_stress',Settings.Nx,Settings.ScanType);
logmap = sign(p_stressmap).*log10(abs(p_stressmap));

% Plots
figure
imagesc(vec2map(log10(VonMises),Settings.Nx,Settings.ScanType));
title('Von Mises Stress')
caxis(lim)
colorbar

% figure
% imagesc(logmap(:,:,1));
% title('Principal Stress - 1')
% caxis(lim)
% colorbar
% 
% figure
% imagesc(logmap(:,:,2));
% title('Principal Stress - 2')
% caxis(lim)
% colorbar
% 
% figure
% imagesc(logmap(:,:,3));
% title('Principal Stress - 3')
% caxis(lim)
% colorbar

%Put Principal Stresses on 1 subplot (if desired).  Uncomment code above if
%individual plots preferred.  

figure
subplot(2,2,1)
imagesc(logmap(:,:,1));
title('1st Principal Stress (Sample Frame)')
caxis(lim)
colorbar
subplot(2,2,2)
imagesc(logmap(:,:,2));
title('2nd Principal Stress (Sample Frame)')
caxis(lim)
colorbar
subplot(2,2,3)
imagesc(logmap(:,:,3));
title('3rd Principal Stress (Sample Frame)')
caxis(lim)
colorbar



