% dislocation systems of Cu
% TJR 6 july 2011
function [bedge,ledge, bscrew,lscrew,v,normals, crssfactor, type]=tasystems4
a = 3.3e-10; % lattice parameter for Ta
v=0.34; %Poisson's ratio and a from the internet
slip=[1 1 1; 1 1 1; 1 1 1;
    1 -1 1; 1 -1 1; 1 -1 1;   
    1 1 -1; 1 1 -1; 1 1 -1; 
    -1 1 1; -1 1 1; -1 1 1];
norm110=[-1 1 0; -1 0 1; 0 -1 1;
    1 1 0; 0 1 1; -1 0 1;
    1 0 1; 0 1 1; -1 1 0;
    1 1 0; 1 0 1; 0 -1 1];

    
%normalizing plane normals and creating correct burgers vectors

norm110 = norm110/(2^.5);
norm = norm110;

b = .5*a*slip;

slip = slip/(3^.5);

ledge=cross(slip,norm);    % line vectors for edge dislocations
bedge=b;

lscrew=[1 1 1; 1 -1 1; 1 1 -1; -1 1 1;]/(3^.5); % line vectors for screw dislocations
bscrew=[1 1 1; 1 -1 1; 1 1 -1; -1 1 1;]*.5*a;

normals = norm;

crssfactor = ones(24,1);

type = ones(1,24);