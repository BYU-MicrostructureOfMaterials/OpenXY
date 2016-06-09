%Assign an rgb color to an orientation based on the sample ND inverse pole
%figure

function rgb = IPF_rgbcalc(mat)

DIR = permute(mat(:,3,:),[3,1,2]); %DIR = mat*[0 0 1]';
DIR = DIR./repmat(NORM_MAT(DIR),1,3); %DIR = DIR/norm(DIR);

rset = [1 0 0; -1 0 0; 0 1 0; 0 -1 0; 0 0 1];
gset = (1/sqrt(2))*[1 0 1; -1 0 1; 0 1 1; 0 -1 1; 1 1 0; -1 1 0; 1 -1 0; -1 -1 0];
bset = (1/sqrt(3))*[1 1 1; -1 1 1; -1 -1 1; 1 -1 1];

[~,rvectind] = max(rset*DIR');
rvect = rset(rvectind,:);
[~,gvectind] = max(gset*DIR');
gvect=gset(gvectind,:);
[~,bvectind] = max(bset*DIR');
bvect=bset(bvectind,:);

%Red Component
RDirPlane = cross(DIR,rvect);
GBplane = cross(bvect,gvect);
Rintersect = cross(RDirPlane,GBplane);
NORM = NORM_MAT(Rintersect);
Rintersect(NORM~=0,:) = Rintersect(NORM~=0,:)./repmat(NORM(NORM~=0),1,3);

temp =  acos(dot(DIR,Rintersect,2));
Rintersect(temp>(pi/2),:) = Rintersect(temp>(pi/2),:)*-1;
rgb(:,1) = acos(dot(DIR,Rintersect,2))./acos(dot(rvect,Rintersect,2));

%Green Component
GDirPlane = cross(DIR,gvect);
RBplane = cross(rvect,bvect);
Gintersect = cross(GDirPlane,RBplane);
NORM = NORM_MAT(Gintersect);
Gintersect(NORM~=0,:) = Gintersect(NORM~=0,:)./repmat(NORM(NORM~=0),1,3);

temp = acos(dot(DIR,Gintersect,2));
Gintersect(temp>(pi/2),:) = Gintersect(temp>(pi/2),:)*-1;
rgb(:,2) = acos(dot(DIR,Gintersect,2))./acos(dot(gvect,Gintersect,2));

%Blue Component
BDirPlane = cross(DIR,bvect);
RGplane = cross(gvect,rvect);
Bintersect = cross(BDirPlane,RGplane);
NORM = NORM_MAT(Bintersect);
Bintersect(NORM~=0,:) = Bintersect(NORM~=0,:)./repmat(NORM(NORM~=0),1,3);

temp = acos(dot(DIR,Bintersect,2));
Bintersect(temp>(pi/2),:) = Bintersect(temp>(pi/2),:)*-1;
rgb(:,3) = acos(dot(DIR,Bintersect,2))./acos(dot(bvect,Bintersect,2));

rgb = rgb./repmat(max(rgb,[],2),1,3);

end