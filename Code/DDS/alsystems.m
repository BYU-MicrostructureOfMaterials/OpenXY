% dislocation systems of Al
% TJR 1 feb 2012
function [bedge,ledge, bscrew,lscrew,v, normals, crssfactor, type]=alsystems
a = 3.52e-10; % lattice parameter for Ni
v=0.31; %Poisson's ratio, both a and v from the internet
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

lscrew= [slip(1:5,:);slip(7,:)]; % line vectors for screw dislocations
ledge=cross(slip,norm);    % line vectors for edge dislocations

bedge=b;
bscrew=[b(1:5,:);b(7,:)];

normals = norm;


crssfactor = ones(12,1);

type = ones(1,12);
