% dislocation systems of Cu
% TJR 6 july 2011
function [bedge,ledge, bscrew,lscrew,v,normals, crssfactor, type]=tasystems2
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
norm112=[1 1 -2; 1 -2 1; -2 1 1;
    -1 1 2; 1 2 1; 2 1 -1;
    1 1 2; -1 2 1; 2 -1 1;
    1 -1 2; 1 2 -1; 2 1 1];
    
%normalizing plane normals and creating correct burgers vectors

norm110 = norm110/(2^.5);
norm112 = norm112/(6^.5);
norm = [norm110;norm112];

b = .5*a*[slip;slip];

slip = [slip;slip]/(3^.5);

lscrew=slip; % line vectors for screw dislocations
ledge=cross(slip,norm);    % line vectors for edge dislocations

bedge=b;
bscrew=b;

normals = norm;

crssfactor = ones(24,1);

type = ones(1,24);