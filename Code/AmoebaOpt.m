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

function [bestx, bestFval, numfcalls] = AmoebaOpt(funtomin, amoebaoptions)
%An implementatin of Nelder-Mead optimization

amoebaoptions = FillInBlankOptions(amoebaoptions);

S = GetStartingSimplex(amoebaoptions);
N = size(S,1);
F = zeros(1,N+1);
for i=1:N+1
    x = squeeze(S(:,i));
    F(i) = funtomin(x);
end
[S,F] = OrderSimplex(S,F);


termcond = 0;
numfcalls = N + 1;

% disp([num2str(numfcalls) ' Initial ' num2str(std(F)) ' ' num2str(F(1))])

while termcond == 0
    xo = mean(S(:,1:N),2);
    xr = xo + amoebaoptions.alpha*(xo - squeeze(S(:,N+1)));
    Fr = funtomin(xr);
    numfcalls = numfcalls + 1;
    if (Fr < F(N)) && (Fr >= F(1)) %Reflect
        S(:,N+1) = xr;
        F(N+1) = Fr;
%         disp([num2str(numfcalls) ' Reflect ' num2str(std(F)) ' ' num2str(F(1))])
    elseif Fr < F(1) %Expand
        xe = xo + amoebaoptions.gamma*(xr - xo);
        Fe = funtomin(xe);
        numfcalls = numfcalls + 1;
        if Fe <= Fr
            S(:,N+1) = xe;
            F(N+1) = Fe;
%             disp([num2str(numfcalls) ' Expand ' num2str(std(F)) ' ' num2str(F(1))])
        else
            S(:,N+1) = xr;
            F(N+1) = Fr;
%             disp([num2str(numfcalls) ' Reflect (E) ' num2str(std(F)) ' ' num2str(F(1))])
        end
    else %Contract
        xc = xo + amoebaoptions.rho*(squeeze(S(:,N+1)) - xo);
        Fc = funtomin(xc);
        numfcalls = numfcalls + 1;
        if Fc < F(N+1)
            S(:,N+1) = xc;
            F(N+1) = Fc;
%             disp([num2str(numfcalls) ' Contract ' num2str(std(F)) ' ' num2str(F(1))])
        else %Shrink
            [S,F] = ShrinkSimplex(S,F(1),amoebaoptions.sigma, funtomin);
            numfcalls = numfcalls + N;
%             disp([num2str(numfcalls) ' Shrink ' num2str(std(F)) ' ' num2str(F(1))])
        end
    end
    [S,F] = OrderSimplex(S,F);
    if std(F) < amoebaoptions.TerminationCondition
        termcond = 1;
    end
    if numfcalls > amoebaoptions.maxfcalls
        termcond = 1;
    end
end

bestx = squeeze(S(:,1));
bestFval = F(1);

end

function S = GetStartingSimplex(amoebaoptions)
if isfield(amoebaoptions,'StartingSimplex')
    S = amoebaoptions.StartingSimplex;
else
    startpnt = amoebaoptions.StartingPoint;
    step = amoebaoptions.StartingStep;
    N = length(startpnt);
    S = zeros(N,N+1);
    S(:,1) = startpnt;
    for j=2:N+1
        stepvec = zeros(size(startpnt));
        stepvec(j-1) = step;
        S(:,j) = startpnt + stepvec;
    end
end
end

function [Sout,Fout] = OrderSimplex(Sin,Fin)
[Fout, SortOrder] = sort(Fin);
Sout = Sin(:,SortOrder);
end

function [S,F] = ShrinkSimplex(Sin,F1,sigma, funtomin)
N = size(Sin,1);
F = zeros(1,N+1);
S1 = squeeze(Sin(:,1));
F(1) = F1;
S(:,1) = S1;
for k=2:N+1
    S(:,k) = S1 + sigma*(squeeze(Sin(:,k))-S1);
    F(k) = funtomin(squeeze(S(:,k)));
end
end

function amoebaoptions = FillInBlankOptions(amoebaoptions)
if ~isfield(amoebaoptions,'alpha')
    amoebaoptions.alpha = 1;
end
if ~isfield(amoebaoptions,'gamma')
    amoebaoptions.gamma = 2;
end
if ~isfield(amoebaoptions,'rho')
    amoebaoptions.rho = .5;
end
if ~isfield(amoebaoptions,'sigma')
    amoebaoptions.sigma = .5;
end
if ~isfield(amoebaoptions,'StartingStep')
    amoebaoptions.StartingStep = 1;
end
if ~isfield(amoebaoptions,'TerminationCondition')
    amoebaoptions.TerminationCondition = 1e-10;
end
if ~isfield(amoebaoptions,'maxfcalls')
    amoebaoptions.maxfcalls = 1000;
end
end