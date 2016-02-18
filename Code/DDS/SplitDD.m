function [rhos,DDSettings] = SplitDD( Settings, alpha_data, alphaorbeta)
% Written by Tim Ruggles
% Implemented by Brian Jackson March 2015
allMaterials = unique(Settings.Phase);
matList = cell(0);
for i = 1:length(allMaterials)
    M = ReadMaterial(allMaterials{i});
    if isfield(M,'SplitDD')
        matList = cat(2,matList,M.SplitDD);
    end
end

if length(matList) > 1
    [matchoose,vv] = listdlg('PromptString','Select the material type','SelectionMode','single','ListString',matList);
    if vv==0
        warndlg('Nothing selected: skipping split dislocation density calculation','Split Dislocation Density'); 
        rhos = [];
        return;
    end
elseif isempty(matList)
    warndlg(['No SplitDD material data for ' allMaterials{1}, ' Exiting SplitDD calculation'],'Split Dislocation Density');
    rhos = [];
    return;
else
    matchoose = 1;
end
matchoice = matList{matchoose};
[bedge,ledge, bscrew,lscrew,v, normals, crssfactor, type] = choosemat(matchoice);

if (matchoose==1)||(matchoose==3)||(matchoose==6)
    lattype = 'hexagonal';
else
    lattype = 'cubic';
end
DDSettings.matchoice = matchoice;

% [alphaorbeta,vv] = listdlg('PromptString','Select the target','SelectionMode','single','ListString',{'Alpha(i,3)','Betas','Pantleon 5'});
% % if 1, use only 3rd column of alpha to resolve; otherwise use all measurable betas
% if vv==0; error('Exited by user'); end

force = 0;
stress = 0;
minscheme_list = {'Min. density','Min. energy','CRSSfactor','Schmid+CRSS', 'CRSS + l'};
[minscheme,vv] = listdlg('PromptString','Select minimization scheme','SelectionMode','single','ListString',minscheme_list);
if vv==0
    warndlg('Nothing selected: skipping split dislocation density calculation','Split Dislocation Density')
    rhos = [];
    return;
end
DDSettings.Minimization_Scheme = minscheme_list{minscheme};
DDSettings.minscheme = minscheme;

op_list = {'Least squares','Origin'};
[x0type,vv] = listdlg('PromptString','Select optimization startpoint','SelectionMode','single','ListString',op_list);
if vv==0
    warndlg('Nothing selected: skipping split dislocation density calculation','Split Dislocation Density')
    rhos = [];
    return;
end
DDSettings.Opt_Start = op_list{x0type};
DDSettings.x0type = x0type;

if minscheme == 4
    [loadtype,vv] = listdlg('PromptString','Select load type','SelectionMode','single','ListString',{'Axial','Plane strain','Plane stress'});
    if vv==0; error('Exited by user'); end
    [loaddirec,vv] = listdlg('PromptString','Select load direction','SelectionMode','single','ListString',{'X','Y','Z'});
    if vv==0; error('Exited by user'); end
    switch loadtype
        case 1
           stress = [1 0 0;0 0 0;0 0 0]; 
        case 2
            a = input('Ratio of shear to axial: ');
            stress = [1 a 0;a -1 0;0 0 0];
        case 3
            a = input('Ratio of primary axial to shear: ');
            aa = input('Ratio of major to minor axis: ');
            stress = [1 a 0;a aa 0;0 0 (-1-aa)];
    end
    switch loaddirec
        case 1
            rot = eye(3);
        case 2
            rot = [0 -1 0;1 0 0;0 0 1];
        case 3
            rot = [0 0 -1;0 1 0;1 0 0];
    end
    
    stress = (rot')*stress*rot;
end
if vv==0; error('Exited by user'); end



stepsize = alpha_data.stepsize;

%% Work out beta derivatives and/or alpha

Fatemp = alpha_data.Fa;
Fctemp = alpha_data.Fc;

if iscell(Settings.data.phi1rn)==1
    phi1rn = real(cell2mat(Settings.data.phi1rn));
    PHIrn =  real(cell2mat(Settings.data.PHIrn));
    phi2rn =  real(cell2mat(Settings.data.phi2rn));
else
    phi1rn = real((Settings.data.phi1rn));
    PHIrn =  real((Settings.data.PHIrn));
    phi2rn =  real((Settings.data.phi2rn));
end

Fatemp2 = zeros(3,3,length(Fatemp));
Fctemp2 = zeros(3,3,length(Fatemp));

for i = 1:length(Fatemp)
    Fatemp2(:,:,i) = ((Fatemp(:,:,i)) - [1 0 0;0 1 0;0 0 1])./stepsize;
    Fctemp2(:,:,i) = ((Fctemp(:,:,i)) - [1 0 0;0 1 0;0 0 1])./stepsize;
end

n = Settings.data.cols;
m = Settings.data.rows;

if length(phi1rn)==3*length(Fatemp)
    temp1 = zeros(length(Fatemp),1);
    temp2 = zeros(length(Fatemp),1);
    temP = zeros(length(Fatemp),1);
    for i=1:length(Fatemp)
        temp1(i) = phi1rn((3*i-1));
        temp2(i) = phi2rn((3*i-1));
        temP(i) = PHIrn((3*i-1));
    end
    
    phi1rn = temp1;
    phi2rn = temp2;
    PHIrn = temP;
    
end


betaderiv1 = -Fatemp2;
betaderiv2 = Fctemp2;


beta(1,:)=betaderiv2(1,1,:);
beta(2,:)=betaderiv1(1,2,:);
beta(3,:)=betaderiv1(1,3,:);
beta(4,:)=betaderiv2(1,3,:);
beta(5,:)=betaderiv2(2,1,:);
beta(6,:)=betaderiv1(2,2,:);
beta(7,:)=betaderiv1(2,3,:);
beta(8,:)=betaderiv2(2,3,:);
beta(9,:)=betaderiv2(3,1,:);
beta(10,:)=betaderiv1(3,2,:);
beta(11,:)=betaderiv1(3,3,:);
beta(12,:)=betaderiv2(3,3,:);

alphavecp(1,:)=betaderiv2(1,1,:) - betaderiv1(1,2,:);
alphavecp(2,:)=betaderiv2(2,1,:) - betaderiv1(2,2,:);
alphavecp(3,:)=betaderiv2(3,1,:) - betaderiv1(3,2,:);
alphavecp(4,:)=betaderiv1(1,3,:);
alphavecp(5,:)=-betaderiv2(2,3,:);
alphavecp(6,:)=-betaderiv2(1,3,:) - betaderiv1(2,3,:);%.5*(betaderiv1(3,2,:,:) - betaderiv1(2,3,:,:) - betaderiv2(1,3,:,:) + betaderiv2(3,1,:,:));


%% Resolving slip, parallel processing
rhos = zeros(length(bedge) + length(bscrew),m,n);


NumberOfCores = Settings.DoParallel;
try
    ppool = gcp('nocreate');
    if isempty(ppool)
        parpool(NumberOfCores);
    end
catch
    ppool = matlabpool('size');
    if ~ppool
        matlabpool('local',NumberOfCores); 
    end
end
% addpath cd
pctRunOnAll javaaddpath('java')

disp(['Starting cross-correlation: ' num2str(m*n) ' points']);
ppm = ParforProgMon( 'Split Dislocation Density ', m*n,1,400,50 );
    
% matlabpool close force;
% %Determine the number of available cores and use one less
% %(Keeps Matlab from near-freezing the computer if it is not
% % entirely dedicated to running HROIM)
% NumberOfCores = feature('numCores');
% if NumberOfCores > 1
%         
%    NumberOfCores = NumberOfCores - 1;
% %  NumberOfCores = 4; % just for my computer or multi-threaded i7's
% %, otherwise use the previous line
%         
% end
% %     matlabpool('open', NumberOfCores);
% matlabpool('local',NumberOfCores)
% % addpath cd
% pctRunOnAll javaaddpath(cd)


parfor i = 1:m*n
    
        
        gmat = euler2gmat(phi1rn(i),PHIrn(i), phi2rn(i));     
        
        switch alphaorbeta
            case 'Nye-Kroner'
                merp = alphavecp(1:3,i);
                rhos(:,i)=resolvedislocB(merp,0,minscheme,matchoice,gmat,1, x0type);
            case 'Distortion Matching'
                merp = beta(:,i);
                rhos(:,i)=resolvedisloc(merp,2,minscheme,matchoice,gmat,stress, stepsize^2, x0type); %CHANGE BACK TO 2
            case 'Nye-Kroner (Pantleon)'
                merp = alphavecp(:,i);
                rhos(:,i)=resolvedislocB(merp,1,minscheme,matchoice,gmat,1, x0type);
            case 11
                merp = zeros(6,1);
                merp(1,1) = beta(1,i);
                merp(2,1) = beta(2,i);
                merp(3,1) = beta(5,i);
                merp(4,1) = beta(6,i);
                merp(5,1) = beta(9,i);
                merp(6,1) = beta(10,i);
                rhos(:,i)=resolvedisloc(merp,11,minscheme,matchoice,gmat,stress, stepsize^2, x0type);
        end
        ppm.increment();        
        
        


    
end

% alpha_data.rhos = rhos;
% splitparams.x0type = x0type;
% splitparams.minscheme = minscheme;
% splitparams.matchoose = matchoose;
% splitparams.alphaorbeta = alphaorbeta;
% splitparams.stress = stress;
% 
% alpha_data.splitparams = splitparams;
end

