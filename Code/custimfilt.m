function I = custimfilt(I, lc,uc,smoothl,smoothu)
if nargin<3
    lowerrad=7;
    upperrad=256;
    
else
    lowerrad=lc;
    upperrad=uc;
end
if nargin<4
    smoothu=0;
    smoothl=0;
end

    
%filters square images
   L=length(I(:,1))+1;
   xc=round(L/2);
   yc=round(L/2);

   filt=zeros(L-1,L-1);
   
   i = 1:L-1;
   j = 1:L-1;
   ny = length(j);
   IJ = i(ones(ny, 1),:);
%    IJ=meshgrid(i,j);
   dist = sqrt((IJ-ones(size(IJ)).*xc).^2+(IJ'-ones(size(IJ)).*yc).^2);
   filt(dist<lowerrad | dist>upperrad) = 1;
   if smoothu==1
   filt(dist>upperrad & dist<upperrad+25)=erf((dist(dist>upperrad & dist<upperrad+25)-upperrad)/25*pi);
end
if smoothl==1;
   filt(dist<lowerrad & dist>lowerrad-25)=erf(-(dist(dist<lowerrad & dist>lowerrad-25)-lowerrad)/25*pi);
end
%    F=fftn(single(I));
try   
F=fftn(I);
catch
    F=fftn(double(I));
end
   F=fftshift(F);

   F1=F.*(1-filt);
   F1=ifftshift(F1);
   I=real(ifftn(F1));
% I=I.*zeros(size(I))*sqrt(-1);
   %bring the mean to zero
   I=single(I-(mean(I(:))));