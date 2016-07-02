function [dx,dy]=Theoretical_Pixel_Shift(g0,xstar,ystar,zstar,xc,yc,F,pixsize,alpha)

%find r of a point x, y on the phospher scren
%View frame to phospher
Qvp=[-1 0 0; 0 -1 0; 0 0 1];
Dvp=[(xstar)*pixsize;(1-ystar)*pixsize;0];
Qpv=Qvp';
Dpv=[(xstar)*pixsize;(1-ystar)*pixsize;0];
% Sample to Crystal
if length(g0(:))<9
    phi1=g0(1);
    PHI=g0(2);
    phi2=g0(3);
    Qsc=euler2gmat(phi1,PHI,phi2);
else
    Qsc=g0;
end
% [R U]=poldec(Qsc);
% V=R*U*inv(R);
% Qsc=R;
% F=F*Qsc'*V'*inv(Qsc');;
Qcs=Qsc';
% A=Qsc*F'*Qcs;

% Phospher to sample
Qps=[0 -cos(alpha) -sin(alpha);...
    -1     0            0;...
    0   sin(alpha) -cos(alpha)];

Qsp=Qps';

% Translation between frames
Dps=Qps*[0;0;-zstar*pixsize];%in pixels in sample frame
Dsp=[0;0;zstar*pixsize];% described in phsopher frame

%find the direction of the roi centered at xc yc (view frame) and describe
%it in the crystal frame
Xp=Qvp(1,1)*xc+Qvp(1,2)*yc+Dvp(1);
Yp=Qvp(2,1)*xc+Qvp(2,2)*yc+Dvp(2);

%Phospher screen described in sample frame
Xs=Qps(1,1)*Xp+Qps(1,2)*Yp+Dps(1);
Ys=Qps(2,1)*Xp+Qps(2,2)*Yp+Dps(2);
Zs=Qps(3,1)*Xp+Qps(3,2)*Yp+Dps(3);

%Phospher screen described in crystal frame
Xc=Qsc(1,1)*Xs+Qsc(1,2)*Ys+Qsc(1,3)*Zs;
Yc=Qsc(2,1)*Xs+Qsc(2,2)*Ys+Qsc(2,3)*Zs;
Zc=Qsc(3,1)*Xs+Qsc(3,2)*Ys+Qsc(3,3)*Zs;
%Deformed Phospher 
FXc=F(1,1)*Xc+F(1,2)*Yc+F(1,3)*Zc;
FYc=F(2,1)*Xc+F(2,2)*Yc+F(2,3)*Zc;
FZc=F(3,1)*Xc+F(3,2)*Yc+F(3,3)*Zc;

FXs=Qcs(1,1)*FXc+Qcs(1,2)*FYc+Qcs(1,3)*FZc;
FYs=Qcs(2,1)*FXc+Qcs(2,2)*FYc+Qcs(2,3)*FZc;
FZs=Qcs(3,1)*FXc+Qcs(3,2)*FYc+Qcs(3,3)*FZc;

nFXs = FXs./sqrt(FXs.^2+FYs.^2+FZs.^2);
nFYs = FYs./sqrt(FXs.^2+FYs.^2+FZs.^2);
nFZs = FZs./sqrt(FXs.^2+FYs.^2+FZs.^2);
n=Qps*[0,0,-1]';
%shift from sample origin to phospher origin described in sample frame
c=Qps*[0;0;-zstar]*pixsize;
% t=(n'*c)./(n(1)*Xc+n(2)*Yc+n(3)*Zc(3));
ta=(n'*c)./(n(1)*nFXs +n(2)*nFYs +n(3)*nFZs);

FXs=ta.*nFXs;
FYs=ta.*nFYs;
FZs=ta.*nFZs;

FXp=Qsp(1,1)*FXs+Qsp(1,2)*FYs+Qsp(1,3)*FZs+Dsp(1);
FYp=Qsp(2,1)*FXs+Qsp(2,2)*FYs+Qsp(2,3)*FZs+Dsp(2);
FZp=Qsp(3,1)*FXs+Qsp(3,2)*FYs+Qsp(3,3)*FZs+Dsp(3);

FXv=Qpv(1,1)*FXp+Qpv(1,2)*FYp+Qpv(1,3)*FZp+Dpv(1);
FYv=Qpv(2,1)*FXp+Qpv(2,2)*FYp+Qpv(2,3)*FZp+Dpv(2);
FZv=Qpv(3,1)*FXp+Qpv(3,2)*FYp+Qpv(3,3)*FZp+Dpv(3);

dx=FXv-xc;
dy=FYv-yc;