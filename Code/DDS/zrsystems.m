% dislocation systems of Zr
% dtf 18-2-2019
function [bedge,ledge, bscrew,lscrew,v,normals,crssfactor,type]=zrsystems;
% a-type slip systems after Shahi thesis (McGill 2008), table 3.1
ctoa = 1.593; % Shahi quotes Roberts as stating 1.624 at room temperature 
a = 3.23e-10; % lattice parameter for Zr
c=ctoa*a;
v=0.35; %Poisson's ratio
crsspris = 0.92; %factor for crss prismatic times that for basal% T.O. Erinosho, F.P.E. Dunne / International Journal of Plasticity 71 (2015) 170e194
crsspyram =7.69; % is pyram a equal to pyramid ca?
crsscapyram = 1.23;
%crssfactor=[ones(3,1);ones(3,1)*crsspris;ones(6,1)*crsspyram;ones(12,1)*crsscapyram]; %does pyramidal-a have same CRSS as pyramidal-ca??****
crssfactor=[ones(3,1);ones(3,1)*crsspris;ones(12,1)*crsscapyram];
twos=zeros(1,3);
twos(1,:)=2; %Prismatic type
threes=zeros(1,6);
threes(1,:)=3;
type=[ones(1,3),twos,zeros(1,12) ];   %one for basal-type, two for prismatic-type, three for pyramidal with a direction and zero for ca-type pyramidal



norma=[0 0 0 1; 0 0 0 1; 0 0 0 1;   % basal
    1 0 -1 0; -1 1 0 0; 0 -1 1 0];   % prismatic
    %1 0 -1 1; -1 0 1 1; -1 1 0 1; 1 -1 0 1; 0 -1 1 1; 0 1 -1 1];    %pyramidal
slipa=[-1 2 -1 0; -1 2 -1 0; 2 -1 -1 0;  % basal
    -1 2 -1 0; -1 -1 2 0; 2 -1 -1 0];  % prismatic
   % -1 2 -1 0; -1 2 -1 0; -1 -1 2 0; -1 -1 2 0; 2 -1 -1 0; 2 -1 -1 0];    %pyramidal
normca=[1 0 -1 1; 1 0 -1 1; -1 1 0 1; -1 1 0 1; -1 1 0 1; -1 1 0 1; 1 -1 0 1; 1 -1 0 1; 0 -1 1 1; 0 -1 1 1; 0 1 -1 1; 0 1 -1 1];   %pyramidal c+a
slipca=[-2 1 1 3; -1 -1 2 3; 2 -1 -1 3; 1 1 -2 3; 2 -1 -1 3; 1 -2 1 3; -2 1 1 3; -1 2 -1 3; -1 2 -1 3; 1 1 -2 3; 1 -2 1 3; -1 -1 2 3];   %pyramidal c+a

norma3=[3*norma(:,1)/2,sqrt(3)*(norma(:,1)+2*norma(:,2))/2, 1.5*norma(:,4)./ctoa];  % cartesian coordinates as per Martin (McGill) thesis II-8 to II-10 using TSL notation
slipa3=[3*slipa(:,1)/2*a,sqrt(3)*(slipa(:,1)+2*slipa(:,2))/2*a , ctoa*slipa(:,4)*a]/3; % slip systems with correct burger's size
normca3=[3*normca(:,1)/2,sqrt(3)*(normca(:,1)+2*normca(:,2))/2, 1.5*normca(:,4)./ctoa];  % cartesian coordinates as per Martin (McGill) thesis II-8 to II-10 using TSL notation
slipca3=[3*slipca(:,1)/2*a,sqrt(3)*(slipca(:,1)+2*slipca(:,2))/2*a , ctoa*slipca(:,4)*a]/3;

ba=slipa3; % a-type burgers vectors 
bca=slipca3; % c-a type burgers
na=norma3; % a-type normals we are going to use
nca=normca3;
normals=[na;nca];



lscrewa=ba; % line vectors for screw dislocations
ledgea=cross(ba,na);    % line vectors for edge dislocations
lscrewca=bca; % line vectors for screw dislocations
ledgeca=cross(bca,nca);    % line vectors for edge dislocations
% ldirections=[lscrewa;ledgea;lscrewca;ledgeca];
ledge=[ledgea;ledgeca];
lscrew=[lscrewa;lscrewca];
bedge=[ba;bca];
bscrew=[ba;bca];

for i=1:length(ledge(:,1))
    ledge(i,:)=ledge(i,:)/norm(ledge(i,:));  %normalize
    normals(i,:) = normals(i,:)/norm(normals(i,:));
end
for i=1:length(lscrew(:,1))
    lscrew(i,:)=lscrew(i,:)/norm(lscrew(i,:));  %normalize
end