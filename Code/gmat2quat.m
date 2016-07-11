%Create quaternion from 3x3 rotation matrix

%Input: gmat - 3x3 rotation matrix

%Output: quat - 4x1 quaternion of the form (ai + bj + ck + w) with real
%               term as fourth element of the vector

function quat = gmat2quat(gmat)

tol = 1e-12;

[r,c] = size( gmat );
if( r ~= 3 || c ~= 3 )
    error( 'g matrix must be 3x3 matrix' );
elseif abs(det(gmat)-1)> tol
    error('Determinant of input matrix must be equal to 1');
end


xx = gmat(1,1); 
xy = gmat(1,2); 
xz = gmat(1,3);
yx = gmat(2,1); 
yy = gmat(2,2); 
yz = gmat(2,3);
zx = gmat(3,1); 
zy = gmat(3,2); 
zz = gmat(3,3);

w = sqrt(trace(gmat)+1)/2;

% Zero w if not real (minimum trace of rotation matrix is -1)
if ~isreal(w), w = 0; end

x = sqrt(1+xx-yy-zz)/2;
y = sqrt(1+yy-xx-zz)/2;
z = sqrt(1+zz-yy-xx)/2;

[val,i] = max([x,y,z,w]);

if i==1 
    w = (zy-yz)/(4*x);
    y = (xy+yx)/(4*x);
    z = (zx+xz)/(4*x);
elseif i==2
    w = (xz-zx)/(4*y);
    x = (xy+yx)/(4*y);
    z = (yz+zy)/(4*y);
elseif i==3
    w = (yx-xy)/(4*z);
    x = (zx+xz)/(4*z);
    y = (yz+zy)/(4*z);
elseif i==4
    x = (zy-yz)/(4*w);
    y = (xz-zx)/(4*w);
    z = (yx-xy)/(4*w);
end

if w>=0
    quat = [x; y; z; w];
elseif w<0
    quat = -1*[x; y; z; w];
end

%Must return unit quaternion
quat = quat/norm(quat);

end