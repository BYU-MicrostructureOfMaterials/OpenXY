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

clc
clear
close all

Pattern = imread('Si000Pat.png');
% Pattern = ReadEBSDImage('Si000Pat.png',[9 90 0 0]);
PC_actual = [.5 .5 .6]';
elevang = 10;
mperpix = 25;
phase = 'silicon';
alphaRotation=pi/2-70*pi/180+10*pi/180;
Qps=[0 -cos(alphaRotation) -sin(alphaRotation);...
    -1     0            0;...
    0   sin(alphaRotation) -cos(alphaRotation)];

g_actual = euler2gmat(.5,.2,.08);

g_initial = g_actual;%euler2gmat(-.1*pi/180,0,0)*

PC_initial = PC_actual + [0;0;0];

Pattern = genEBSDPatternHybrid_fromEMSoft(g_actual,PC_actual(1),PC_actual(2),PC_actual(3),...
    size(Pattern,1),mperpix,elevang*pi/180,70*pi/180,phase,20000);


yesloop = true;
numit = 0;

thisPC = PC_initial;
thisg = g_initial;

while yesloop
    numit = numit + 1;
    tic
    [F_crystal, PC_final] = CalcF_KBS2(Pattern, thisg, eye(3), thisPC, phase, Qps, elevang, mperpix);
    toc
    
    PCerror = 1e6*(PC_final - PC_actual)/.6

    
    
    if numit > 0
        yesloop = false;
        g_final = thisg;
    end
    
    thisPC = PC_final;
    [rr,~]=poldec(F_crystal);
    thisg = (rr')*thisg;

end



% tic
% [F_crystal, PC_final] = CalcF_BandletStrain(Pattern, g_initial, PC_initial, phase, Qps, elevang, mperpix);
% toc

% 1.570796326794897   0.261799387799149