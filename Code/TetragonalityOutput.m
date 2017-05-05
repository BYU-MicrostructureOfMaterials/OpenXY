function TetragonalityOutput(Settings)
% plots tetragonality relative to cubic, based upon the deformation tensor
% assuming a cubic lattice was chosen
% more functionality (such as plotting average tetragonality in grains - in
% case this helps with phase ID of grains - and filtering out regions with
% low IQ in file that this came from: Rotate_and_Tetragonality_Overlay7_30_14.m
% also the ability to plot c-axis direction, but that needs fixing
% DTF Mar 25 2016 (happy Good Friday!)
n = Settings.data.cols;
m = Settings.data.rows;

% F = reshape((Settings.data.F),n,m)';
F = Settings.data.F;

%these will contain the results
beta = zeros(3,3,m,n);
epstet = zeros(m,n);
axisdirection=zeros(m,n);

%iterate through all points in dataset
for i=1:m
    for j=1:n
%         beta(:,:,i,j) = (cell2mat(F(i,j)) - eye(3));
        beta(:,:,i,j) = (F(:,:,j+n*(i-1)) - eye(3));
        %take the symmetric part--so "beta" is now strain
        beta(:,:,i,j) = .5*(beta(:,:,i,j) + beta(:,:,i,j)');        
        %this will contain the diagonal
        eps = zeros(1,3);
        %put the diagonal in
        eps(1) = beta(1,1,i,j);
        eps(2) = beta(2,2,i,j);
        eps(3) = beta(3,3,i,j);
        %find max value on diagonal
        [mmm,k] = max((eps));
        %tetragonality measurement
        epstet(i,j) = eps(k) - (sum(eps) - eps(k))/2;
        %direction
        axisdirection(i,j)=k;
    end
end

figure; 
imagesc(epstet);
caxis([0 .03]);
axis equal tight
axis off
title('Tetragonality map')
colorbar