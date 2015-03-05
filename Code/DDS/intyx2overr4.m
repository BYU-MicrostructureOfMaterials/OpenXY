% Integration of (y-y0)*(x-x0)^2/((y-y0)^2+(x-x0)^2)^2 dy dx for y from p to q and x
% from r to s
% For edge dislocations from Gutkin 1999
% dtf 6/7/11
function res=intyx2overr4(y0,x0,p,q,r,s)

res=subintyx2overr4(y0,x0,q,s)-subintyx2overr4(y0,x0,q,r)-subintyx2overr4(y0,x0,p,s)+subintyx2overr4(y0,x0,p,r);

function res0=subintyx2overr4(y00,x00,p0,r0)

res0=-(r0+(p0-y00)*atan((r0-x00)/(y00-p0)))/2;