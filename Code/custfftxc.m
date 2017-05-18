function [r,qx,qy]=custfftxc(f,g,showfig,bigF,rc,cc,custfilt,windowfunc)

%     global custfilt windowfunc filt

%filter image and find cross correlation
% Multiply by windowing function 
if ~isempty(custfilt)
    f=f-mean(f(:));
    
    f=windowfunc.*f;
end

global rs cs Gs
ind=find(rs==rc(1) & cs==cc(1));
if isempty(ind)
    method=1;
    if method==1
        if ~isempty(custfilt)
            g=g-mean(g(:));
            g=windowfunc.*g;
            
            G=conj(custfilt.*fftn(g));
            
            r1=fftshift(ifftn((custfilt.*fftn(f).*G)));
        else
            G=conj(fftn(g));
            
            r1=fftshift(ifftn((fftn(f).*G)));
            
        end
        [qx1,qy1]=subpixshift(real(r1));
        l=length(rs);
        rs(l+1)=rc(1);
        cs(l+1)=cc(1);
        Gs{l+1}=G;
    else
%         r1=normxcorr2_mex((double(g)),(double(bigF)));
%         r1=r1(rc+127-128:rc+127+127,cc+127-128:cc+127+127);
%         [qx1 qy1]=subpixshift(real(r1));
        [output,~] = dftregistration(fft2(f),fft2(g),100);
        %            [error,diffphase,net_row_shift,net_col_shift]
        qx1 = output.net_row_shift;
        qy1 = output.net_col_shift;
        r1 = -1;
    end
    
else
    if ~isempty(custfilt)
        r1=fftshift(ifftn((custfilt.*fftn(f).*Gs{ind})));
    else
        r1=fftshift(ifftn((fftn(f).*Gs{ind})));
    end
    [qx1 qy1]=subpixshift(real(r1));
end

r=r1;
qx=qx1;
qy=qy1;