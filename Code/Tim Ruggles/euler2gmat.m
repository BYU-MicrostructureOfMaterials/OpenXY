function [g]=euler2gmat(phi1,PHI,phi2)
%euler2gmat - creates a g-matrix according to bunge for phi1,PHI,phi2 in
%   radians
%Accepts vectors of phi1,PHI,and phi2 (6/09/2016 Brian Jackson)
%
if nargin == 1
    phi2 = phi1(:,3);
    PHI = phi1(:,2);
    phi1 = phi1(:,1);
end
g = zeros(3,3,length(phi1));
cp1 = cos(phi1);
sp1 = sin(phi1);
cp2 = cos(phi2);
sp2 = sin(phi2);
cP = cos(PHI);
sP = sin(PHI);

g(1,1,:)= cp1.*cp2-sp1.*sp2.*cP;
g(1,2,:) = sp1.*cp2+cp1.*sp2.*cP;
g(1,3,:) = sp2.*sP;
g(2,1,:)= -cp1.*sp2-sp1.*cp2.*cP;
g(2,2,:)= -sp1.*sp2+cp1.*cp2.*cP;
g(2,3,:)= cp2.*sP;
g(3,1,:)=  sp1.*sP;
g(3,2,:)= -cp1.*sP;
g(3,3,:)=  cP;