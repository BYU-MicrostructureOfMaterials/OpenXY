%Assign an rgb color to an orientation based on the sample ND inverse pole
%figure

function rgb = IPF_rgbcalc(mat)

rgb = zeros(1,3);

DIR = mat*[0 0 1]';
DIR = DIR/norm(DIR);

rset = [1 0 0; -1 0 0; 0 1 0; 0 -1 0; 0 0 1];
gset = (1/sqrt(2))*[1 0 1; -1 0 1; 0 1 1; 0 -1 1; 1 1 0; -1 1 0; 1 -1 0; -1 -1 0];
bset = (1/sqrt(3))*[1 1 1; -1 1 1; -1 -1 1; 1 -1 1];

[rdotval,rvectind] = max(rset*DIR);
rvect = rset(rvectind,:);
[gdotval,gvectind] = max(gset*DIR);
gvect=gset(gvectind,:);
[bdotval,bvectind] = max(bset*DIR);
bvect=bset(bvectind,:);

RDirPlane = cross(DIR,rvect);
GBplane = cross(bvect,gvect);
Rintersect = cross(RDirPlane,GBplane);
Rintersect = Rintersect/norm(Rintersect);
if acos(dot(DIR,Rintersect))>(pi/2)
    Rintersect = -1*Rintersect;
end
rgb(1) = (acos(dot(DIR,Rintersect)))/(acos(dot(rvect,Rintersect)));

GDirPlane = cross(DIR,gvect);
RBplane = cross(rvect,bvect);
Gintersect = cross(GDirPlane,RBplane);
Gintersect = Gintersect/norm(Gintersect);
if acos(dot(DIR,Gintersect))>(pi/2)
    Gintersect = -1*Gintersect;
end
rgb(2) = (acos(dot(DIR,Gintersect)))/(acos(dot(gvect,Gintersect)));

BDirPlane = cross(DIR,bvect);
RGplane = cross(gvect,rvect);
Bintersect = cross(BDirPlane,RGplane);
Bintersect = Bintersect/norm(Bintersect);
if acos(dot(DIR,Bintersect))>(pi/2)
    Bintersect = -1*Bintersect;
end
rgb(3) = (acos(dot(DIR,Bintersect)))/(acos(dot(bvect,Bintersect)));

rgb = rgb/max(rgb);

end