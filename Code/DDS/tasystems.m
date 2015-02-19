% dislocation systems of Cu
% TJR 6 july 2011
function [bedge,ledge, bscrew,lscrew,v, normals, crssfactor, type]=tasystems
a = 3.3e-10; % lattice parameter for Ta
v=0.34; %Poisson's ratio and a from the internet
slip=[1 1 1; 1 1 1; 1 1 1;
    1 -1 1; 1 -1 1; 1 -1 1;   
    1 1 -1; 1 1 -1; 1 1 -1; 
    -1 1 1; -1 1 1; -1 1 1];
norm=[-1 1 0; -1 0 1; 0 -1 1;
    1 1 0; 0 1 1; -1 0 1;
    1 0 1; 0 1 1; -1 1 0;
    1 1 0; 1 0 1; 0 -1 1];

%normalizing plane normals and creating correct burgers vectors

norm = norm/(2^.5);

b = .5*a*slip;

slip = slip/(3^.5);

lscrew=slip; % line vectors for screw dislocations
ledge=cross(slip,norm);    % line vectors for edge dislocations

bedge=b;
bscrew=b;

normals = norm;


crssfactor = ones(12,1);

type = ones(1,12);