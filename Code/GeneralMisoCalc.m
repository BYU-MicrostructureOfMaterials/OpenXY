function [angle,Axis,deltaG]=GeneralMisoCalc(A,B,lattice)
% GENERALMISOCALC - calculates the minimum misorientation for two given
%   g-matrices created by Bunge's G-Matrix.  
%   This function returns the minimum angle of rotation about a given axis
%   along with the matrix representing the misorientation.
%
%

%Convert from euler to gmat if necessary
if all(size(A)==[1,3]) && all(size(B)==[1,3])
    A = euler2gmat(A(1),A(2),A(3));
    B = euler2gmat(B(1),B(2),B(3));
end
    

if strcmp(lattice,'cubic')
    
    SymOps=gensymops;
    
elseif strcmp(lattice,'hexagonal')
    
    SymOps=gensymopsHex;
    
elseif strcmp(lattice,'tetragonal') % requires axis input
    
    SymOps=gensymopsTet(3);
    
else
    disp('no lattice type declared (cubic, hexagonal or tetragonal) for GeneralMisoCalc, assuming cubic');
      SymOps=gensymops;
end

maxtrace = -1;

deltaG = A*B';

Axis(1) = 0;
Axis(2) = 0;
Axis(3) = 0;

for i = 1:length(SymOps(:,1,1))
    sym(:,:) = SymOps(i,:,:);
    Bdg = sym*deltaG;
    trace = Bdg(1,1) + Bdg(2,2) + Bdg(3,3);
    if (trace >= 3)
        angle=0;
        return;
    elseif (trace > maxtrace)
        maxtrace = trace;
        gMx = Bdg;
    end
end

temp = 0.5*(maxtrace-1);
if temp > 1
    temp = 1;
elseif temp < -1
    temp = -1;
end

angle = acos(temp)*180/pi;
Axis(1) = gMx(3,2) - gMx(2,3);
Axis(2) = gMx(1,3) - gMx(3,1);
Axis(3) = gMx(2,1) - gMx(1,2);
Axis = Axis/norm(Axis);
