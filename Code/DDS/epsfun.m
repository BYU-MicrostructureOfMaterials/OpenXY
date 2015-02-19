% delta function for taking curl
% dtf may 4 2011
function epsans=epsfun(i,j,k)
if (i==1 && j==2 && k==3) | (i==2 && j==3 && k==1) | (i==3 && j==1 && k==2)
    epsans=1;
elseif (i==1 && j==3 && k==2) | (i==2 && j==1 && k==3) | (i==3 && j==2 && k==1)
    epsans=-1;
else
    epsans=0;
end