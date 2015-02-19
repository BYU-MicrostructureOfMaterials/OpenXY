% dislocation systems of Cu
% TJR 6 july 2011
function [bedge,ledge, bscrew,lscrew,v, normals, crssfactor, type]=cusystems
a = 3.61e-10; % lattice parameter for Cu
v=0.33; %Poisson's ratio, both a and v from the internet
norm=[1 1 1; 1 1 1; 1 1 1;
    1 -1 1; 1 -1 1; 1 -1 1;   
    1 1 -1; 1 1 -1; 1 1 -1; 
    -1 1 1; -1 1 1; -1 1 1];
slip=[-1 1 0; -1 0 1; 0 -1 1;
    1 1 0; 0 1 1; -1 0 1;
    1 0 1; 0 1 1; -1 1 0;
    1 1 0; 1 0 1; 0 -1 1];

%normalizing plane normals and creating correct burgers vectors

norm = norm/(3^.5);

b = .5*a*slip;

slip = slip/(2^.5);

lscrew=slip; % line vectors for screw dislocations
ledge=cross(slip,norm);    % line vectors for edge dislocations

bedge=b;
bscrew=b;

normals = norm;


crssfactor = ones(12,1);

type = ones(1,12);