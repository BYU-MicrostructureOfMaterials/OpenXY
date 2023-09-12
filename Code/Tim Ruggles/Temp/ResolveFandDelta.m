% Copyright 2021 National Technology & Engineering Solutions of Sandia, LLC (NTESS).
% Under the terms of Contract DE-NA0003525 with NTESS, the U.S. Government retains certain rights in this software.
% Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files
% (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge,
% publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do
% so, subject to the following conditions:
% The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
% OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
% LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
% IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

function [F_new,Delta] = ResolveFandDelta(F, g, Qps, C_crystal)
    betaM = (Qps')*(g')*F*g*Qps - eye(3);
    options = optimoptions('fsolve', 'Algorithm', ...
        'Levenberg-Marquardt', 'display', 'off',...
        'FunctionTolerance', 1e-12, 'StepTolerance', 1e-8);
    X = fsolve(@(Y) tempfun(Y,betaM, g, Qps, C_crystal),zeros(12,1), options);
    beta = [X(1) X(2) X(3);X(4) X(5) X(6);X(7) X(8) X(9)];
%     1e6*beta
    Delta = [X(10); X(11); X(12)];
%     1e6*Delta
    F_new = g*Qps*beta*(Qps')*(g') + eye(3);
end

function Z = tempfun(X,betaM, g, Qps, C_crystal)
    beta = [X(1) X(2) X(3);X(4) X(5) X(6);X(7) X(8) X(9)];
    Delta = [X(10); X(11); X(12)];
    M = measuredbeta(beta,Delta);
    traction = traccalc(beta, g, Qps, C_crystal);    
    Z = zeros(13,1);
    Z(1:9) = reshape(betaM - M,9,1);
    Z(10) = trace(beta);
    Z(11:13) = traction/C_crystal(1,1,1,1);
    
%     Z(6) = Z(6)/10;
%     Z(3) = Z(3)/10;
end

function M = measuredbeta(beta,Delta)
    b11 = beta(1,1);
    b12 = beta(1,2);
    b13 = beta(1,3);
    b21 = beta(2,1);
    b22 = beta(2,2);
    b23 = beta(2,3);
    b31 = beta(3,1);
    b32 = beta(3,2);
    b33 = beta(3,3);
    e1 = Delta(1);
    e2 = Delta(2);
    e3 = Delta(3);
    H = [ e3 + b11*e3 - b31*e1,      b12*e3 - b32*e1, b13*e3 - e1 - b33*e1;
        b21*e3 - b31*e2, e3 + b22*e3 - b32*e2, b23*e3 - e2 - b33*e2;
                      0,                    0,                    0];
    wd = b11/3 + b22/3 + b33/3 + (2*e3)/3 + (b11*e3)/3 + (b22*e3)/3 - (b31*e1)/3 - (b32*e2)/3;
    M = (1/(1+wd))*(beta + H - eye(3)*wd);
end

function traction = traccalc(beta, g, Qps, C_crystal)
    [R, U] = poldec(Qps*beta*(Qps') + eye(3));
    V = R*U*(R');
    epsilon_sample = V - eye(3);
    gact = g*(R');%(g*R*(g'))'*g;  %Could this possibly be right?  Has it ever?
    C_sample = rotate4thorder(C_crystal,gact');
    sigma_sample = fourthbysecond(C_sample, epsilon_sample);
    traction = sigma_sample*[0;0;1];
end

function A_prime = rotate4thorder(A,q)
    A_prime = zeros(3,3,3,3);
    for i=1:3
        for j=1:3
            for k=1:3
                for l=1:3
                    for m=1:3
                        for n=1:3
                            for o=1:3
                                for p=1:3
                                    A_prime(i,j,k,l) = A_prime(i,j,k,l) + A(m,n,o,p)*q(i,m)*q(j,n)*q(k,o)*q(l,p);
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function sigma = fourthbysecond(C,epsilon)
    sigma = zeros(3,3);
    for i=1:3
        for j=1:3
            for k=1:3
                for l=1:3
                    sigma(i,j) = sigma(i,j) + C(i,j,k,l)*epsilon(k,l);
                end
            end
        end
    end
end

