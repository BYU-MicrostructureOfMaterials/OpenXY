function [X Y Z] = FitPCPlaneText(PCData, XData, YData)%output is in fraction of the phosphor screen

xpts = PCData{5};
ypts = PCData{6};
PCVect = [PCData{2} PCData{3} PCData{4}];

%temporary, don't keep 3 lines below
% xpts = xpts(2:end)
% ypts = ypts(2:end)
% PCVect = PCVect(2:end,:)
%% fit points to a plane, interpolate x,y points to regular scan grid

% [P, N] = lsqPlane([PCVect(:,1),PCVect(:,2),PCVect(:,3)]);
[PZ, NZ] = lsqPlane([xpts, ypts, PCVect(:,3)]);
[PX, NX] = lsqPlane([xpts, ypts, PCVect(:,1)]);
[PY, NY] = lsqPlane([xpts, ypts, PCVect(:,2)]);


% xPC = @(c,r) ( N(1)*P(1)-N(2)*c + N(2)*P(2) - N(3)*r + N(3)*P(3)) / N(1);

% yPC = @(c,r) ( -N(1)*c + N(1)*P(1) + N(2)*P(2) - N(3)*r + N(3)*P(3) ) / N(2);

xPC = @(c,r) ( NX(1)*PX(1) + NX(2)*PX(2) + NX(3)*PX(3) - NX(1)*c - NX(2)*r )/ NX(3);
yPC = @(c,r) ( NY(1)*PY(1) + NY(2)*PY(2) + NY(3)*PY(3) - NY(1)*c - NY(2)*r )/ NY(3); %depending on the coordinate system the + NY(1)*c may need to be -
zPC = @(c,r) ( NZ(1)*PZ(1) + NZ(2)*PZ(2) + NZ(3)*PZ(3) - NZ(1)*c - NZ(2)*r )/ NZ(3);

X = zeros(1,length(XData));
Y = zeros(1,length(XData));
Z = zeros(1,length(XData));
for ii = 1:length(XData)
    
% 
    X(ii) = xPC(YData(ii),XData(ii));
    Y(ii) = yPC(YData(ii),XData(ii));
    Z(ii) = zPC(YData(ii),XData(ii));

%     X(ii) = xPC(XData(ii),YData(ii));
%     Y(ii) = yPC(XData(ii),YData(ii));
%     Z(ii) = zPC(XData(ii),YData(ii));
    
end


figure(1);
hold on;
plot3(X,Y,Z,'og')
xlabel('X*'); ylabel('Y*'); zlabel('Z*'); title('PC Fit Plane and original points')
hold on;
plot3(PCVect(:,1),PCVect(:,2),PCVect(:,3),'*r');

h=1;

%% Rotate the points by five degrees about some axis
RX = X-X(round(length(X)/2)); RY = Y-Y(round(length(X)/2)); RZ = Z-Z(round(length(X)/2));
%define rotation matrix about the x direction
theta = 5*pi/180;
r = [1 0 0; 0 cos(theta) -sin(theta); 0 sin(theta) cos(theta)];
bob = [RX' RY' RZ'];
RotatedPCs = zeros(length(bob),3);
for jj = 1:length(bob)
    RotatedPCs(jj,:) = bob(jj,:)*r + [X(round(length(X)/2)) Y(round(length(X)/2)) Z(round(length(X)/2))];
end
'hi'
% RotatedPCs = RotatedPCs + [X(1) + Y(1) + Z(1)];
%  = bsxfun(@times,bob,r);
%assume that this is the single OIM PC calibration
% if size(PCVect,1) == 1
%     %% Make a perfect plane from assumed geometry
% [In1 In2 In3] = sph2cart(.01*180/pi,-(10+20)*pi/180,1);
%
% % zRef = @(x,y) ( In1*PCVect(1,1) + In2*PCVect(1,2) + In3*PCVect(1,3) - In1*x - In2*y )/ In3;
% %
% % yRef = @(x,z) ( -In1*x + In1*PCVect(1,1) + In2*PCVect(1,2) - In3*z + In3*PCVect(1,3) ) / In2;
% %
% % xRef = @(y,z) ( In1*PCVect(1,1) - In2*y + In2*PCVect(1,2) - In3*z + In3*PCVect(1,3) )/ In1;
%
% end