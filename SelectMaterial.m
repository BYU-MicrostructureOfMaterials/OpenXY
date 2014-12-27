function  [ Fhkl hkl C11 C12 C44 lattice a1 b1 c1 dhkl axs str C13 C33 C66 Burgers] = SelectMaterial(Material)
%returns material parameters for materials in the "str" list. If the
%Material string is not found

str = {'nickel','silicon','iron-alpha','titanium(alpha)','magnesium','aluminum',...
    'germanium','martensite','copper','tantalum','iron-gamma','boronzirconium_0060610','siliconcarbide6h','siliconcarbon_0020013', 'titaniumaluminum', 'cigs', 'grainfile','titanium(beta)'};
if strcmp(Material,'newphase')
    Material='iron-alpha';
end
if strcmp(Material,'Austenite') || strcmp(Material,'austenite')
    Material='iron-gamma';
end
if strcmp(Material,'Ferrite') || strcmp(Material,'ferrite')
    Material='iron-alpha';
end

% Material
s = find(strcmp(str,Material));
if isempty(s)
   errordlg('String in Material was not found in the list of available choices','Error in SelectMaterial.m');
   return;
end
% [s,v] = listdlg('PromptString','Select a material','SelectionMode','single','ListString',str);
% if v==0
%     return
% end
C11 = []; C12 = []; C44 = []; C13 = []; C33 = []; C66 = []; Burgers = [];
switch s
    case 1 %Nickel
        Fhkl=[11.9; 10.5; 7.5; 6.3; 4.4; 4.3; 3.7; 3.4];
        dhkl=[2.055; 1.780; 1.259; 1.073; 0.817; 0.796; 0.727; 0.685]*1e-10;
        hkl=[1 -1 -1; 0 -2 0; 0 -2 2; 1 -3 -1; 1 -3 -3; 0 -4 2; 2 -4 -2; 1 -5 -1];
        C11=134.6;
        C12=112.1;
        C44=76.8;
        lattice = 'cubic';
        a1 = 1; % 3.524 A
        b1 = 1;
        c1 = 1;
        axs = 3;
        Burgers = 2.4500000000000*10^-10;
        

    case 2 %Silicon
%         Fhkl=[18.4; 14.9; 9.2; 8.5; 6.9; 5.7; 4.5; 3.7];
%         dhkl=[3.135; 1.5675; 1.920; 1.637; 1.357; 1.246; 1.108; 1.045]*1e-10;
%         hkl=[1 -1 -1; 0 -2 2; 0 -4 0; 1 -3 -1 ; 2 -4 -2; 1 -3 -3; 1 -5 -1; 1 -5 -3];
%         C11 = 166;
%         C12 = 64;
%         C44 = 79.6;
%         lattice = 'cubic';
%         a1 = 1;
%         b1 = 1;
%         c1 = 1;
%         axs = 3;
        %strained Si (lattice constant 5.6575 vs 5.4309 angstroms) gives
        %lower SSE even with normal Si
%         Fhkl=[18.4; 14.9; 9.2; 8.5; 6.9; 5.7; 4.5; 3.7];
%         dhkl=[3.266; 2.000; 1.414; 1.706; 1.155; 1.298; 1.089; 0.956]*1e-10;
%         hkl=[1 -1 -1; 0 -2 2; 0 -4 0; 1 -3 -1 ; 2 -4 -2; 1 -3 -3; 1 -5 -1; 1 -5 -3];
%         C11 = 166;
%         C12 = 64;
%         C44 = 79.6;
%         lattice = 'cubic';
%         a1 = 1;
%         b1 = 1;
%         c1 = 1;
%         axs = 3;
% EDAX / TSL Values
 Fhkl=[18.4; 14.9; 9.2; 8.5; 6.9; 5.7; 4.5; 3.7]; % TSL does not have the final 2 planes
        dhkl=[3.136; 1.92; 1.358; 1.638; 1.109; 1.246; 1.108; 1.045]*1e-10;
        hkl=[1 -1 -1; 0 -2 2; 0 -4 0; 1 -3 -1 ; 2 -4 -2; 1 -3 -3; 1 -5 -1; 1 -5 -3];
        C11 = 166;
        C12 = 64;
        C44 = 79.6;
        lattice = 'cubic';
        a1 = 1;
        b1 = 1;
        c1 = 1;
        axs = 3;
        
%          Fhkl=[18.4; 14.9; 9.2; 8.5; 6.9; 5.7]; % TSL does not have the final 2 planes
%         dhkl=[3.136; 1.92; 1.358; 1.638; 1.109; 1.246]*1e-10;
%         hkl=[1 -1 -1; 0 -2 2; 0 -4 0; 1 -3 -1 ; 2 -4 -2; 1 -3 -3];
%         C11 = 166;
%         C12 = 64;
%         C44 = 79.6;
%         lattice = 'cubic';
%         a1 = 1;
%         b1 = 1;
%         c1 = 1;
%         axs = 3;
%         
        
    case 3 %Iron-Alpha
%         Fhkl=[5.9; 4.2; 3.4; 2.4; 2.1; 1.9];     
%         dhkl=[2.029; 1.435; 1.172; 0.908; .767; .676]*1e-10;
%         hkl=[0 -1 1; 0 -2 0; 1 -2 -1; 0 -3 1; 2 -2 -2; 1 -3 -2];
        Fhkl=[5.9; 4.2; 3.4; 2.4; 2.1; 1.9; 1.6; 1.4; 1.3];     
        dhkl=[2.029; 1.435; 1.172; 0.908; .828; .767; .676; .642; .612]*1e-10;
        hkl=[0 -1 1; 0 -2 0; 1 -2 -1; 0 -3 1; 2 -2 -2; 1 -3 -2; 1 -4 -1; 0 -4 2; 2 -3 -3];
        C11=231.4;%Gpa
        C12=134.7;%Gpa
        C44=116.4; %Gpa
        lattice = 'cubic';
        % 2.8665 A
        a1 = 1;
        b1 = 1;
        c1 = 1;
        axs = 3;
        Burgers = 2.485500000000000*10^-10;
        
    case 4 %Alpha-Titanium
        Fhkl = [1; 1; 1; 1]; %OIM DC has Fhkl as zero for some reason
        dhkl = [2.555;2.340;2.242;1.726]*1e-10;
        hkil = [1 0 -1 0; 0 0 0 2; 1 0 -1 1; 1 0 -1 2];
        C11 = 176.1;
        C12 = 86.9;
        C13 = 68.3;
        C33 = 190.5;
        C44 = 50.8;
        C66 = (C11-C12)/2;
        lattice = 'hexagonal';
        a1 = 2.95;
        b1 = 2.95;
        c1 = 4.68;
        axs = 3;
        
    case 5 %Magnesium
        dhkl = [2.771; 2.6; 2.446; 1.896; 1.6; 1.47; 1.363; 1.339]*1e-10;
        dhkl = [2.7548; 2.586; 2.4314; 1.8854; 1.5905; 1.4614; 1.3548; 1.331; 1.0761; 1.0207]*1e-10; %using a = 3.181 and c = 5.172 for AZ91
        Fhkl=[2.2;1.5;2.3;1.4;2.3;1.8;1.9;1.6;1.3;1.2];
        hkl = [0 sqrt(3) 0; 0 0 2; 0 sqrt(3) 1; 0 sqrt(3) 2; 3/2 3*sqrt(3)/2 0; 0 sqrt(3) 3; 3/2 3*sqrt(3)/2 2; 0 2*sqrt(3) 1; 0 2*sqrt(3) 3; 3/1 2*sqrt(3) 1]; %from OIM DC 4.0
        hkil = [0 1 -1 0; 0 0 0 2; 0 1 -1 1; 0 1 -1 2; 1 1 -2 0; 0 1 -1 3; 1 1 -2 2; 0 2 -2 1; 0 2 -2 3; 1 2 -3 1];
        C11 = 59.7;
        C12 = 26.2;
        C13 = 21.7;
        C33 = 61.7;
        C44 = 16.4;
        C66 = (C11-C12)/2;
        lattice = 'hexagonal';
        a1 = 3.2099; % there was a *3/2
        b1 = 3.2099; % there was a *3/2
        c1 = 5.2116;
        axs = 3;
        Burgers = 3.440000000000000*10^-10;
        % shouldn't the lattice parameter match the Burgers vector
%         for hcp there are 2 dominant Burgers vector lengths so a weighted
%         average would be best and other analysis can consider the 2
%         values to get upper and lower bounds on dislocation density

        %         using a = 3.181 and c = 5.17
%         al = 3.181*3/2;
%         bl = 3.181*3/2;
%         cl = 5.17;

    case 6 %Aluminum
        dhkl = [2.332; 2.02; 1.482; 1.218; 0.927; 0.903; 0.825; 0.777]*1e-10;
        hkl = [1 -1 -1; 0 -2 0; 0 -2 2; 1 -3 -1; 1 -3 -3; 0 -4 2; 2 -4 -2; 1 -5 -1];
        Fhkl = [8.5; 7.0; 4.4; 3.6; 2.6; 2.5; 2.2; 2];
        C11 = 108;
        C12 = 62;
        C44 = 28.3;
        lattice = 'cubic';
        a1 = 4.0495;
        b1 = a1;
        c1 = a1;
        axs = 3;
        
    case 7 %Germanium
%         Fhkl = [24.3 25.2 15.2 17.7 11.4 14.2 9.4 8.1];
%         dhkl = [3.268 2.001 1.707 1.415 1.298 1.155 1.089 0.957]*1e-10;
%         hkl = [1 -1 -1; 0 -2 2; 1 -3 -1; 0 -4 0; 1 -3 -3; 2 -4 -2; 1 -5 -1; 1 -5 -3];
%         C11 = 126;
%         C12 = 44;
%         C44 = 67.7;
%         lattice = 'cubic';
%         a1 = 1;
%         b1 = 1;
%         c1 = 1;
%         axs = 3;
        %Josh Mods
        Fhkl = [14.3 15.2 15.2 17.7 11.4 14.2 9.4 8.1 15];
        dhkl = [3.268 2.001 1.707 1.415 1.298 1.155 1.089 0.957 1.6304]*1e-10;
        hkl = [1 -1 -1; 0 -2 2; 1 -3 -1; 0 -4 0; 1 -3 -3; 2 -4 -2; 1 -5 -1; 1 -5 -3; 2 -2 -2];
        C11 = 126;
        C12 = 44;
        C44 = 67.7;
        lattice = 'cubic';
        a1 = 1;
        b1 = 1;
        c1 = 1;
        axs = 3;
        Burgers = 3.99*10^-10;
        
    case 8 % Martensite
        Fhkl = [2 2 1 1 1 1 1 1];
        hkl = [1 0 1; 1 1 0; 0 0 2; 2 0 0; 1 1 2; 2 1 1; 1 0 3; 3 0 1];
        C11=231.4; % Just using iron elastic constants
        C12=134.7;
        C44=116.4;
        lattice = 'tetragonal';
        a1 = 2.847;
        b1 = a1;
        c1 = 3.018;
        dhkl = zeros(1,length(hkl));
        for i = 1:length(hkl)
            dhkl(i) = 1/sqrt(hkl(i,1)^2/a1^2+hkl(i,2)/b1^2+hkl(i,3)^2/c1^2)*1e-10;
        end
        axs = 3;
        Burgers = 2.4855*10^-10;
    case 9 % copper
        Fhkl = [11.5 10.4 7.6 6.5 4.6 4.5 3.9 3.6];
        hkl = [1 -1 -1; 0 -2 0; 0 -2 2; 1 -3 -1; 1 -3 -3; 0 -4 2; 2 -4 -2; 1 -5 -1];
        C11 = 168.4;
        C12 = 121.4;
        C44 = 75.4;
        lattice = 'cubic';
        a1 = 3.61;
        b1 = a1;
        c1 = a1;
        dhkl = zeros(1,length(hkl));
        for i = 1:length(hkl)
            dhkl(i) = a1/sqrt(hkl(i,1)^2+hkl(i,2)^2+hkl(i,3)^2)*1e-10;
        end
        axs = 3;
        Burgers = 2.556000000000000*10^-10;
        
    case 10 %alpha  tantalum
        Fhkl = [12.9 9.6 7.9 6.8 6.0 5.4 5.0 4.6];
        hkl = [0 -1 1; 0 -2 0; 1 -2 -1; 0 -2 2; 0 -3 1; 2 -2 -2; 1 -3 -2; 0 -4 0];
        dhkl = [2.333 1.650 1.347 1.167 1.044 0.953 0.882 0.825]*1e-10; % check these there are too many
        C11 = 261.55;
        C12 = 157.68;
        C44 = 82.24;
        lattice = 'cubic';
        a1 = 3.3013; %3.3058 per wikipedia
        b1 = a1;
        c1 = a1;
        axs = 3;
        Burgers = 2.92000000000000*10^-10; % 3.3013*sqrt(3)/2 = 2.859
        
    case 11 % Iron-gamma
        Fhkl=[12.3; 10.8; 7.5; 6.3; 4.4; 4.2; 3.7];
        dhkl=[2.107; 1.825; 1.29; 1.101; 0.837; 0.816; 0.745]*1e-10;
        hkl=[1 -1 -1; 0 -2 0; 0 -2 2; 1 -3 -1; 1 -3 -3; 0 -4 2; 2 -4 -2];
        C11=134.6;
        C12=112.1;
        C44=76.8;
        lattice = 'cubic';
        a1 = 1;
        b1 = 1;
        c1 = 1;
        axs = 3;
        Burgers=2.485*10^10;
    case 12 % ZrB2
        dhkl = [0.995;2.744;2.167;1.584;1.485;1.279;1.179;3.530]*1e-10; 
        Fhkl=[1.2;21.7;16.7;6.7;3.3;3.0;2.7;45.0];
        hkil = [2 1 -3 1;1 0 -1 0;1 0 -1 1;1 1 -2 0;1 0 -1 2;2 0 -2 1;1 1 -2 2;0 0 0 1];
        C11 = 581;
        C12 = 55;
        C13 = 121;
        C33 = 445;
        C44 = 240;
        C66 = (C11-C12)/2;
        lattice = 'hexagonal';
        a1 = 3.169; 
        b1 = 3.169; 
        c1 = 3.53;
        axs = 3;
        Burgers = 3.1690000000000000*10^-10;
    case 13 % SiC (6H)
        dhkl = [0.887;2.513;2.510;2.352;2.174;1.995;1.674;1.538;1.536;1.312;1.311;2.621]*1e-10; 
        Fhkl=[5.8;19.5;9.8;4.6;4.3;7.1;7.3;7.0;13.2;4.2;8.3;13.3];
        hkil = [0 -3 3 0;0 0 0 -6;0 -1 1 2;0 -1 1 3;0 -1 1 4;0 -1 1 5;0 -1 1 7;0 -1 1 8;1 -2 1 0;0 -1 1 10;1 -2 1 -6;0 -1 1 1];
        C11 = 501;
        C12 = 111;
        C13 = 52;
        C33 = 553;
        C44 = 163;
        C66 = (C11-C12)/2;
        lattice = 'hexagonal';
        a1 = 3.073; 
        b1 = 3.073; 
        c1 = 15.079;
        axs = 3;
        Burgers = 3.0730000000000000*10^-10;
    case 14 % set other SiC to SiC (6H)
        dhkl = [0.887;2.513;2.510;2.352;2.174;1.995;1.674;1.538;1.536;1.312;1.311;2.621]*1e-10; 
        Fhkl=[5.8;19.5;9.8;4.6;4.3;7.1;7.3;7.0;13.2;4.2;8.3;13.3];
        hkil = [0 -3 3 0;0 0 0 -6;0 -1 1 2;0 -1 1 3;0 -1 1 4;0 -1 1 5;0 -1 1 7;0 -1 1 8;1 -2 1 0;0 -1 1 10;1 -2 1 -6;0 -1 1 1];
        C11 = 501;
        C12 = 111;
        C13 = 52;
        C33 = 553;
        C44 = 163;
        C66 = (C11-C12)/2;
        lattice = 'hexagonal';
        a1 = 3.073; 
        b1 = 3.073; 
        c1 = 15.079;
        axs = 3;
        Burgers = 3.0730000000000000*10^-10;    
      case 15 % Ti-Al, pseudo-cubic
        Fhkl=[12.3; 12.0; 7.8; 6.3; 5.4; 4.5; 3.7];
        hkl=[1 -1 -1; 0 -2 0; 0 -2 2; 1 -3 -1; 1 -3 -3; 0 -4 2; 2 -4 -2];
        C11=1; % Just using iron elastic constants
        C12=2;
        C44=3;
        lattice = 'cubic';%'tetragonal';
        a1 = 3.976;
        b1 = a1;
        c1 = a1;
        dhkl = zeros(length(hkl),1);
        for i = 1:length(hkl)
            dhkl(i) = 1/sqrt(hkl(i,1)^2/a1^2+hkl(i,2)^2/b1^2+hkl(i,3)^2/c1^2)*1e-10;
        end
        axs = 3;
      case 16 %CIGS- PseudoCubic
        Fhkl=[18.4; 14.9; 9.2; 8.5; 6.9; 5.7; 4.5; 3.7];
        dhkl=1.046*[3.266; 2.000; 1.414; 1.706; 1.155; 1.298; 1.089; 0.956]*1e-10;
        hkl=[1 -1 -1; 0 -2 2; 0 -4 0; 1 -3 -1 ; 2 -4 -2; 1 -3 -3; 1 -5 -1; 1 -5 -3];
        C11 = 166;
        C12 = 64;
        C44 = 79.6;
        lattice = 'cubic';
        a1 = 1;
        b1 = 1;
        c1 = 1;
        axs = 3;  
      case 17 % Read from Grain File
        Fhkl=[0];
        dhkl=[0];
        hkl=[0 0 0];
        C11=0;
        C12=0;
        C44=0;
        lattice = 'cubic';
        a1 = 0;
        b1 = 0;
        c1 = 0;
        axs = 0;
      case 18 %beta-titanium
        Fhkl = [12.9 9.6 7.9 6.0 5.4 5.0 4.6];
        hkl = [0 -1 1; 0 -2 0; 1 -2 -1; 0 -3 1; 2 -2 -2; 1 -3 -2; 0 -4 0];
        dhkl = [2.348 1.660 1.355 1.050 0.958 0.887 0.830]*1e-10; 
        C11 = 128.5;
        C12 = 115.5;
        C44 = 14.9;
        lattice = 'cubic';
        a1 = 3.320; %3.320 per Google search image
        b1 = a1;
        c1 = a1;
        axs = 3;
        Burgers = 2.92000000000000*10^-10; % 3.320*sqrt(3)/2 = 2.87520
        
end

if strcmp(lattice,'hexagonal')
    for i = 1:length(hkil)
        hkl(i,1) = 3/2*hkil(i,1);
        hkl(i,2) = sqrt(3)/2*(hkil(i,1)+2*hkil(i,2));
        hkl(i,3) = 3/2*1/(c1/a1)*hkil(i,4);
    end
end
