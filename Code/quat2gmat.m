%Convert unit quaternion into rotation matrix

%Input: quat - Vector with 4 elements, representing quaternion of form
%              (ai + bj + ck + w). Fourth element of vector contains real
%              term

%Output: gmat - 3x3 rotation matrix

function gmat = quat2gmat(quat)

tol = 1e-12;

quat = quat/norm(quat);

qx = quat(1);
qy = quat(2);
qz = quat(3);
qw = quat(4);

xx = 1 - 2*(qy^2 + qz^2);
xy = 2*(qx*qy - qz*qw);
xz = 2*(qx*qz + qy*qw);
yx = 2*(qx*qy + qz*qw);
yy = 1 - 2*(qx^2 + qz^2);
yz = 2*(qy*qz - qx*qw );
zx = 2*(qx*qz - qy*qw );
zy = 2*(qy*qz + qx*qw );
zz = 1 - 2*(qx^2 + qy^2);

gmat = [xx xy xz;
        yx yy yz;
        zx zy zz];
   
%Check determinant of output matrix
if abs(det(gmat)-1)>tol
    error('Output gmat is not proper rotation. Det(gmat)=/=1');
end
    
end