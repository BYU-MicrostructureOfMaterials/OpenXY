% find grains and grain boundaries
% input is angles=(nx,ny,3) for phi1, Phi, phi2 at each point
% dtf from OIMnoise.m 12/5/10
function [grains grainsize sizes BOUND]=findgrains(angles, lattice, clean, small,mistol)

[nx,ny]=size(angles(:,:,1));
N=nx*ny;

phi1=angles(:,:,1);
Phi=angles(:,:,2);
phi2=angles(:,:,3);
anglesR=circshift(angles,[0 -1 0]);   % shift matrix left
anglesD=circshift(angles,[-1 0 0]);   % shift matrix up
angles = reshape(angles,[N 3]);
anglesR = reshape(anglesR,[N 3]);
anglesD = reshape(anglesD,[N 3]);

gmat = @(phi1,Phi,phi2) [cos(phi1).*cos(phi2)-sin(phi1).*cos(Phi).*sin(phi2), -cos(phi1).*sin(phi2)-sin(phi1).*cos(Phi).*cos(phi2), sin(phi1).*sin(Phi), ...
    sin(phi1).*cos(phi2)+cos(phi1).*cos(Phi).*sin(phi2), -sin(phi1).*sin(phi2)+cos(phi1).*cos(Phi).*cos(phi2), -cos(phi1).*sin(Phi) , ...
    sin(Phi).*sin(phi2), sin(Phi).*cos(phi2), cos(Phi)];

ind = reshape(1:9,3,3);
indT=ind';
Q = gmat(angles(:,1),angles(:,2),angles(:,3));
QRtemp= gmat(anglesR(:,1),anglesR(:,2),anglesR(:,3));
QDtemp= gmat(anglesD(:,1),anglesD(:,2),anglesD(:,3));
count=0;
for jj = 1:3
    for ii =1:3
        count=count+1;
        QR(:,count) = sum(QRtemp(:,ind(ii,:)).*Q(:,indT(:,jj)),2);
        QD(:,count) = sum(QDtemp(:,ind(ii,:)).*Q(:,indT(:,jj)),2);
    end
end

%clear QRtemp QDtemp
%clear angles gmat


load CrystalRotations.mat

MisOrR = 10000*ones(size(Q,1),1);    % initiate misorientation matrices
MisOrD = 10000*ones(size(Q,1),1);    % initiate misorientation matrices

if lattice==1
    nsym=24;
else
    nsym=12;
end

for kk = 1:nsym
    count = 0;
if lattice==1
    R = repmat(reshape(CubicTriclinicrot(:,:,kk),1,9),size(Q,1),1);
else
    R = repmat(reshape(Hexagonalrot(:,:,kk),1,9),size(Q,1),1);
end  
    for jj = 1:3
        for ii =1:3
            count  =count +1;
            Q_primeR(:,count) = sum(R(:,ind(ii,:)).*QR(:,ind(:,jj)),2);
            Q_primeD(:,count) = sum(R(:,ind(ii,:)).*QD(:,ind(:,jj)),2);
        end
    end

    MisOr_tempR = acos((sum(Q_primeR(:,diag(ind)),2)-1)/2);
    smaller = find(MisOr_tempR < MisOrR );
    MisOrR(smaller) = MisOr_tempR(smaller);
    MisOr_tempD = acos((sum(Q_primeD(:,diag(ind)),2)-1)/2);
    smaller = find(MisOr_tempD < MisOrD );
    MisOrD(smaller) = MisOr_tempD(smaller);

end

%clear Q QD DR
MisOrR=real(reshape(MisOrR,[nx,ny]));
MisOrD=real(reshape(MisOrD,[nx,ny]));
grains=zeros(nx+2,ny+2);
grains(:,1)=1e20;
grains(:,ny+2)=1e20;
grains(1,:)=1e20;
grains(nx+2,:)=1e20;
% make final col of MisOrR large to remove possibility of grains wrapping
% around
MisOrR(:,ny)=1e20;
MisOrD(nx,:)=1e20;
MisOrR=[ones(1,ny)*1e20;MisOrR;ones(1,ny)*1e20];
MisOrR=[ones(nx+2,1)*1e20 MisOrR ones(nx+2,1)*1e20];
MisOrD=[ones(1,ny)*1e20;MisOrD;ones(1,ny)*1e20];
MisOrD=[ones(nx+2,1)*1e20 MisOrD ones(nx+2,1)*1e20];
grains(2,2)=1;
flag=0;
ngrain=1;   %used to enumerate the grains

gsz = 2; %create a window for the smallest grainsize
while flag==0
    flag=1;
    nadds=0;
    for i=2:nx+1
        for j=2:ny+1
            if ((j>1)&&(MisOrR(i,j-1)<mistol)) && ((i>1)&&(MisOrD(i-1,j)<mistol)) && (grains(i,j)~=min(grains(i,j-1),grains(i-1,j)));
                grains(i,j)=min(grains(i,j-1),grains(i-1,j));
                flag=0;
                nadds=nadds+1;
            elseif (i>1)&&(MisOrD(i-1,j)<mistol) && (grains(i,j)~=grains(i-1,j))
                grains(i,j)=grains(i-1,j);
                flag=0;
                nadds=nadds+1;
            elseif (j>1)&&(MisOrR(i,j-1)<mistol) && (grains(i,j)~=grains(i,j-1))
                grains(i,j)=grains(i,j-1);
                flag=0;
                nadds=nadds+1;
            elseif grains(i,j)==0
                ngrain=ngrain+1;
                grains(i,j)=ngrain;
            end
        end
    end
    for i=nx+1:-1:2
        for j=ny+1:-1:2
            if ((j<ny+2)&& (MisOrR(i,j)<mistol)) && ((i<nx+2)&& (MisOrD(i,j)<mistol)) && (grains(i,j)~=min(grains(i,j+1),grains(i+1,j)))
                grains(i,j)=min(grains(i,j+1),grains(i+1,j));
                flag=0;
                nadds=nadds+1;
            elseif (i<nx+2)&& (MisOrD(i,j)<mistol) && (grains(i,j)~=grains(i+1,j))
                grains(i,j)=grains(i+1,j);
                flag=0;
                nadds=nadds+1;
            elseif (j<ny+2)&& (MisOrR(i,j)<mistol) && (grains(i,j)~=grains(i,j+1))
                grains(i,j)=grains(i,j+1);
                flag=0;
                nadds=nadds+1;
            end
        end
    end
    %    nadds
    if nadds<1; flag=1;end

end

grains(:,1)=0;
grains(:,ny+2)=0;
grains(1,:)=0;
grains(nx+2,:)=0;




% for bone example, make bone a high colour:
% grains=reshape(grains,(nx+2)*(ny+2),1);
% q=find(grains==2);
% grains(q)=max(grains+20);
% grains=reshape(grains,nx+2,ny+2);

% now work out grain sizes at each point
grains=grains(2:nx+1,2:ny+1);
%m=m(2:nx+1,2:ny+1);
grains=reshape(grains,(nx)*(ny),1);
grainsize=zeros(1,max(grains));
for i=1:length(grains)
    grainsize(grains(i))=grainsize(grains(i))+1;
end

grains=reshape(grains,(nx),(ny));

if clean==1
    [grains,grainsize] = cleanup(grains,grainsize,small);
end

sizes=grains;
sizes(:,:)=grainsize(grains(:,:));


BOUND=zeros(nx,ny);
temp1=abs(grains-circshift(grains,[1,0]));
temp1(1,:)=0;
temp2=abs(grains-circshift(grains,[0,1]));
temp2(:,1)=0;
BOUND(temp1+temp2>0.01)=1;