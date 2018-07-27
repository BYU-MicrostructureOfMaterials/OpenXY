function [r,qx,qy]=custfftxc(im1,im2,rowCenter,columnCenter,custfilt,windowfunc)
%CUSTFFTXC Custom fast Fourier transform based cross-correlation.
%   CUSTFFTXC(im1, im2, rowCenter, columnCenter) Computes the cross
%   correlation r and the shifts shifts qx and qy using the fft algorithm.
%
%   CUSTFFTXC(im1, im2, rowCenter, columnCenter, custfilt, windowfunc) Does
%   the same, but with the filter custfilt and windowing function
%   windowfunc


%filter image and find cross correlation
% Multiply by windowing function 
if ~isempty(custfilt)
    im1=im1-mean(im1(:));
    
    im1=windowfunc.*im1;
end

global rs cs Gs
ind=find(rs==rowCenter(1) & cs==columnCenter(1));
if isempty(ind)
    method=1;
    if method==1
        if ~isempty(custfilt)
            im2=im2-mean(im2(:));
            im2=windowfunc.*im2;
            
            IM2=conj(custfilt.*fftn(im2));
            
            r1=fftshift(ifftn((custfilt.*fftn(im1).*IM2)));
        else
            IM2=conj(fftn(im2));
            
            r1=fftshift(ifftn((fftn(im1).*IM2)));
            
        end
        [qx1,qy1]=subpixshift(real(r1));
        l=length(rs);
        rs(l+1)=rowCenter(1);
        cs(l+1)=columnCenter(1);
        Gs{l+1}=IM2;
    else
%         r1=normxcorr2_mex((double(g)),(double(bigF)));
%         r1=r1(rc+127-128:rc+127+127,cc+127-128:cc+127+127);
%         [qx1 qy1]=subpixshift(real(r1));
        [output,~] = dftregistration(fft2(im1),fft2(im2),100);
        %            [error,diffphase,net_row_shift,net_col_shift]
        qx1 = output.net_row_shift;
        qy1 = output.net_col_shift;
        r1 = -1;
    end
    
else
    if ~isempty(custfilt)
        r1=fftshift(ifftn((custfilt.*fftn(im1).*Gs{ind})));
    else
        r1=fftshift(ifftn((fftn(im1).*Gs{ind})));
    end
    [qx1, qy1]=subpixshift(real(r1));
end

r=r1;
qx=qx1;
qy=qy1;