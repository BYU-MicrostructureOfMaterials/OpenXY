% dislocation systems of CP-Ti
% dtf Sep 22, 2023
function [bedge,ledge, bscrew,lscrew,v,normals,crssfactor,type] = tisystems
c = 4.68e-10; % lattice parameter
a = 2.95e-10; % lattice parameter
ctoa = c / a; % ratio of c lattice parameter to a
v = 0.34; % Poisson's ratio

% Relative CRSS values - J. Wang et al: http://dx.doi.org/10.1016/j.actamat.2017.05.015
crsspris = 1 / 1.9; % factor for crss prismatic times that for basal
crsspyram = mean([1.2 1.4 1.8 1.6]) / 1.9;
crsscapyram = 2.4 / 1.9;
crssfactor = [ones(3,1);ones(3,1)*crsspris;ones(6,1)*crsspyram;ones(6,1)*crsscapyram]; %does pyramidal-a have same CRSS as pyramidal-ca??****
type = [ones(1,12) zeros(1,6)];   % one for a-type, zero for ca-type

norma=[0 0 0 1; 0 0 0 1; 0 0 0 1;   % basal
    1 0 -1 0; 0 1 -1 0; -1 1 0 0;   % prismatic
    1 0 -1 1; 0 1 -1 1; -1 1 0 1; -1 0 1 1; 0 -1 1 1; 1 -1 0 1];    %pyramidal
slipa=[1 1 -2 0; -2 1 1 0; 1 -2 1 0;  % basal
    1 -2 1 0; 2 -1 -1 0; 1 1 -2 0;  % prismatic
    1 -2 1 0; -2 1 1 0; -1 -1 2 0; -1 2 -1 0; 2 -1 -1 0; 1 1 -2 0];    %pyramidal
normca=[1 1 -2 2; -1 2 -1 2; -2 1 1 2; -1 -1 2 2; 1 -2 1 2; 2 -1 -1 2];   %pyramidal c+a
slipca=[-1 -1 2 3; 1 -2 1 3; 2 -1 -1 3; 1 1 -2 3; -1 2 -1 3; -2 1 1 3];   %pyramidal c+a

norma3 = [3*norma(:,1)/2,sqrt(3)*(norma(:,1)+2*norma(:,2))/2, 1.5*norma(:,4)./ctoa];  % cartesian coordinates as per Martin (McGill) thesis II-8 to II-10 using TSL notation
slipa3 = [3*slipa(:,1)/2*a,sqrt(3)*(slipa(:,1)+2*slipa(:,2))/2*a , ctoa*slipa(:,4)*a]/3; % slip systems with correct burger's size
normca3 = [3*normca(:,1)/2,sqrt(3)*(normca(:,1)+2*normca(:,2))/2, 1.5*normca(:,4)./ctoa];  % cartesian coordinates as per Martin (McGill) thesis II-8 to II-10 using TSL notation
slipca3 = [3*slipca(:,1)/2*a,sqrt(3)*(slipca(:,1)+2*slipca(:,2))/2*a , ctoa*slipca(:,4)*a]/3;

ba = slipa3; % a-type burgers vectors 
bca = slipca3; % c-a type burgers
na = norma3; % a-type normals we are going to use
nca = normca3;
normals = [na;nca];

lscrewa = ba; % line vectors for screw dislocations
ledgea = cross(ba,na);    % line vectors for edge dislocations
lscrewca = bca; % line vectors for screw dislocations
ledgeca = cross(bca,nca);    % line vectors for edge dislocations
% ldirections=[lscrewa;ledgea;lscrewca;ledgeca];
ledge = [ledgea;ledgeca];
lscrew = [lscrewa;lscrewca];
bedge = [ba;bca];
bscrew = [ba;bca];

for i = 1:length(ledge(:,1))
    ledge(i,:) = ledge(i,:)/norm(ledge(i,:));  %normalize
    normals(i,:) = normals(i,:)/norm(normals(i,:));
end
for i = 1:length(lscrew(:,1))
    lscrew(i,:) = lscrew(i,:)/norm(lscrew(i,:));  %normalize
end