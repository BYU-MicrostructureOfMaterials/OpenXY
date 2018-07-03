function I = custimfilt(I, lc,uc,smoothl,smoothu)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function applies a bandpass filter to a given EBSP.  The user can
% set the size of the filter an enable smoothing.
%
% INPUTS
% ------
% I = EBSP (pattern)
% lc = size of lower radius applied in bandpass filter (size of high-pass)
% uc = size of upper radius applied in bandpass filter (size of low-pass)
% smoothl = set to 1 to enable smoothing on the lower radius in the filter
% smoohtu = set to 1 to enable smoothing on the upper radius in the filter
%
% OUTPUTS
% -------
% I = Filtered EBSP
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Interpret user inputs
% ///////////////////////
% Filter Sizes
% -------------
if nargin < 3
    % Set size of low-pass and high-pass filters if it is not specified by
    % the user (default values)
    lowerrad = 7;
    upperrad = 256;
else
    % Store user inputs for filter sizes
    lowerrad = lc;
    upperrad = uc;
end

% Smoothing
% ----------
if nargin < 4
    % Default option for smoothing is zero
    smoothu = 0;
    smoothl = 0;
end

%% Prepare Image
% Ensure image is square for filtering
L=length(I(:,1))+1;
xc=round(L/2);
yc=round(L/2);
filt=zeros(L-1,L-1);

% Define filter from image size and radii
% ----------------------------------------
% Preallocate variables for dist
i = 1:L-1 ; j = 1:L-1 ; ny = length(j) ; IJ = i(ones(ny, 1),:) ; % IJ=meshgrid(i,j);
% Create meshgrid of the distance from the image center for filt
dist = sqrt((IJ-ones(size(IJ)).*xc).^2+(IJ'-ones(size(IJ)).*yc).^2);
filt(dist<lowerrad | dist>upperrad) = 1;

% Apply smoothing on high-pass and low-pass filters
if smoothu==1
    filt(dist>upperrad & dist<upperrad+25)=erf((dist(dist>upperrad & dist<upperrad+25)-upperrad)/25*pi);
end
if smoothl==1
    filt(dist<lowerrad & dist>lowerrad-25)=erf(-(dist(dist<lowerrad & dist>lowerrad-25)-lowerrad)/25*pi);
end
% F=fftn(single(I));

%% Convert Image to Fourier Space and Apply Filter
try
    F = fftn(I);
catch
    F = fftn(double(I));
end
F  = fftshift(F);     % Shift transform for filtering (high frequencies in center, low frequencies on edges)
F1 = F.*(1-filt);     % Apply filter
F1 = ifftshift(F1);   % Invert shift in fourier space
I  = real(ifftn(F1)); % Invert image from fourier space
% I=I.*zeros(size(I))*sqrt(-1);
I=single(I-(mean(I(:)))); % Bring mean to zero
end
