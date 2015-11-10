function [strain] = CalcStrain(F)
tempF(:,:)=F;
[~, tempU]=poldec(tempF);
tempU=tempU-eye(3);
u33=tempU(3,3); 
u22=tempU(2,2);
u11=tempU(1,1);
strain = [u11,u22,u33];
