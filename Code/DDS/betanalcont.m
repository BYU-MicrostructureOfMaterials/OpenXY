% work out beta from continuous version of analytical calcs (Gutkin 1999)
% and rotate back into correct frame
% See Lazar 2003 (Eq 52 for edge beta) for corrections from Gutkin
% dtf 6/7/11
% inputs are burgers vector, line vector and distance between dislocations
% / side of area assumed to relate to a single dislocation
% edge is 1 if edge dislocation, else it is 0
function beta=betanalcont(b,l,a,edge,v,x);

beta=zeros(3,3);
bnorm=norm(b); % burger's vector
if edge==0  % for screw dislocation
    if abs(abs(l(1))-1)>1e-6
        yvec=cross(l,[1;0;0]);   % arbitrary y direction in dislocation frame ****is there some non-arbitrary choice??????
    else
        yvec=cross(l,[0;1;0]);
    end
    yvec=yvec/norm(yvec);
    xvec=cross(yvec,l);
    xvec=xvec/norm(xvec);
    g=[xvec yvec l];
    xnew=g'*x; % transform x vector into dislocation frame
    x0=xnew(1);
    y0=xnew(2);
    beta(3,1)=-bnorm/2/pi/a^2*intyoverr2(y0,x0,-a/2,a/2,-a/2,a/2);
    beta(3,2)=bnorm/2/pi/a^2*intyoverr2(x0,y0,-a/2,a/2,-a/2,a/2);
else
    g=[b/bnorm cross(l,b/bnorm) l]; % transformation matrix to get back to sample frame
    xnew=g'*x; % transform x vector into dislocation frame
    x0=xnew(1);
    y0=xnew(2);
    beta(1,1)=bnorm/4/pi/a^2/(1-v)*((-(1-2*v))*intyoverr2(y0,x0,-a/2,a/2,-a/2,a/2)-2*intyx2overr4(y0,x0,-a/2,a/2,-a/2,a/2));
    beta(2,2)=bnorm/4/pi/a^2/(1-v)*((-(1-2*v))*intyoverr2(y0,x0,-a/2,a/2,-a/2,a/2)+2*intyx2overr4(y0,x0,-a/2,a/2,-a/2,a/2));
    beta(1,2)=bnorm/4/pi/a^2/(1-v)*((3-2*v)*intyoverr2(x0,y0,-a/2,a/2,-a/2,a/2)-2*intyx2overr4(x0,y0,-a/2,a/2,-a/2,a/2)); % need to go to Lazar for this - also checked by hand
    beta(2,1)=bnorm/4/pi/a^2/(1-v)*(-(1-2*v)*intyoverr2(x0,y0,-a/2,a/2,-a/2,a/2)-2*intyx2overr4(x0,y0,-a/2,a/2,-a/2,a/2)); % Eq 14 in Gutkin must have some error since it does not lead to this - see Lazar instead
end

betatemp=beta;
beta=g*beta*g'; % return beta to sample frame
% keyboard