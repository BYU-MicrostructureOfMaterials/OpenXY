function [angle,Axis] = MisoCalc(A,B)
%MISOCALC
%Calculates the angle and axis of orientation difference between 2 crystal
%   orientations. Doesn't take symmetries into account.
%Written by Brian Jackson

%Convert from euler to gmat if necessary
if all(size(A)==[1,3]) && all(size(B)==[1,3])
    A = euler2gmat(A(1),A(2),A(3));
    B = euler2gmat(B(1),B(2),B(3));
end

%Get rotation Matrix
R = A*B';

%Calculate angle and axis
angle = acos((trace(R)-1)/2)*180/pi;
Axis(1) = R(3,2) - R(2,3);
Axis(2) = R(1,3) - R(3,1);
Axis(3) = R(2,1) - R(1,2);
Axis = Axis/norm(Axis);