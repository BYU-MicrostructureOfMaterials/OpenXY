% Integration of (y-y0)/((y-y0)^2+(x-x0)^2) dy dx for y from p to q and x
% from r to s
% For edge and screw dislocations from Gutkin 1999
% dtf 6/7/11
function res=intyoverr2(y0,x0,p,q,r,s)

res=subintyoverr2(y0,x0,q,s)-subintyoverr2(y0,x0,q,r)-subintyoverr2(y0,x0,p,s)+subintyoverr2(y0,x0,p,r);

function res0=subintyoverr2(y00,x00,p0,r0)

res0=((r0-x00)*log((p0-y00)^2+(r0-x00)^2)-2*(p0-y00)*atan((r0-x00)/(y00-p0))-2*r0)/2;