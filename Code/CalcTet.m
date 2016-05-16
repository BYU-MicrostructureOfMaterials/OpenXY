function tet = CalcTet(F,ref_tet)
if nargin == 1
    ref_tet = 0;
else
    ref_tet = ref_tet/100;
end
Fref = zeros(3);
Fref(1,1) = -ref_tet/2;
Fref(2,2) = -ref_tet/2;
Fref(3,3) = ref_tet/2;
Fref = Fref + eye(3);
    
[~,U] = poldec(F*Fref);
tet = U(3,3)-(U(1,1)+U(2,2))/2;