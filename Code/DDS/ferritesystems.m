% dislocation systems of Ferrite
% DTF Mar 24 2016
function [bedge,ledge, bscrew,lscrew,v,normals, crssfactor, type]=ferritesystems
a = 2.87e-10; % lattice parameter for Ferrite: Scripta Materialia 52 (2005) 973?976
v=0.275; %Poisson's ratio: http://www.ductile.org/didata/Section3/3part1.htm#Poisson's Ratio
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

crssfactor = ones(16,1);

type = ones(1,16);