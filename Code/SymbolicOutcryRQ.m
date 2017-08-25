clc
clear
close all

beta = zeros(3,3);

g = eye(3);

beta = g*beta*g';

syms o1 o2 o3 p1 p2 p3

O = [o1;o2;o3];
P = [p1;p2;p3];
D = P - O;

xbox = zeros(5,3);
xbox(1,1) = .27;
xbox(1,2) = .24;
xbox(1,3) = 0;
xbox(2,1) = .25;
xbox(2,2) = .75;
xbox(2,3) = 0;
xbox(3,1) = .78;
xbox(3,2) = .25;
xbox(3,3) = 0;
xbox(4,1) = .79;
xbox(4,2) = .70;
xbox(4,3) = 0;
xbox(5,1) = .5;
xbox(5,2) = .5;
xbox(5,3) = 0;

F = beta + eye(3);
ddratio = o3/p3;
for i=1:length(xbox)
    x = squeeze(xbox(i,:));
    r = x-O;
    rp = F*r*(dot(P,[0;0;-1]))/dot(F*r,[0;0;1]);
    q = P + rp - O - r;
    qs(i,:) = q(:);
    
    qstars(i,:) = (q - D)*ddratio - r*(1-ddratio);
end


for i=1:length(xbox)
    x = shiftdim(xbox(i,:));
    r = x-O;
    q = qs(i,:).';
    rp = q + r;
    
    W(2*i-1,:) = [r(1) r(2) r(3) 0 0 0 (-rp(1)/r(3))*[r(1) r(2) r(3)]];
    W(2*i,:)   = [0 0 0 r(1) r(2) r(3) (-rp(2)/r(3))*[r(1) r(2) r(3)]];
    
    w(2*i-1) = q(1);
    w(2*i)   = q(2);

end

