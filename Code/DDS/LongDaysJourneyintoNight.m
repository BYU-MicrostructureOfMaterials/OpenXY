clc
clear
close all

%% User input of paramters
[filename,pathname] = uigetfile('*.mat');

[matchoose,vv] = listdlg('PromptString','Select the material type','SelectionMode','single','ListString',{'Mg','Cu','Mg (a systems only)','Ta','Ta (with 112 planes)','Mg(no a-pyram)','Ni','Ni(18ss)','Al-18ss'});
if vv==0; error('Exited by user'); end

[bedge,ledge, bscrew,lscrew,v, normals, crssfactor, type] = choosemat(matchoose);

if (matchoose==1)||(matchoose==3)||(matchoose==6)
    lattype = 'hexagonal';
else
    lattype = 'cubic';
end

x0type = 2; %1 for Least Squares, 2 for origen

minscheme = 1;

if exist(filename,'file')==0
    path(path,pathname);
end
load(filename)

stepsize = alpha_data.stepsize;