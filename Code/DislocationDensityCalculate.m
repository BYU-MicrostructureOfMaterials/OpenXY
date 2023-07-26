function alpha_data = DislocationDensityCalculate(Settings,maxMisorientation,IQcutoff,VaryStepSizeI)
%DISLOCATIONDENSITYOUTPUT
%DislocationDensityOutput(Settings,Components, cmin, cmax, MaxMisorientation)
%code bits for this function taken from Step2_DisloDens_Lgrid_useF_2.m
%authors include: Collin Landon, Josh Kacher, Sadegh Ahmadi, and Travis Rampton
%modified for use with HROIM GUI code, Jay Basinger 4/20/2011
format compact
tic

NoStrain = false;

%Calculate Dislocation Density
data = Settings.data;
AnalysisParamsPath=Settings.AnalysisParamsPath;
r = Settings.Ny;%
c = Settings.Nx;%
stepsize_orig = abs((Settings.XData(3)-Settings.XData(2))/1e6); %units in meters. This is for square grid
NewAngles=cell2mat(data.g');
Allg=Settings.Angles;
Allg(Settings.Inds,:) = NewAngles;
Inds = Settings.Inds;
ImageFilter=Settings.ImageFilter;
doEnforcedAntisymetry = Settings.doEnforcedAntisymmetry;
special=0;
if isfield(Settings,'GNDMethod') && strcmp(Settings.GNDMethod,'Partial')
    EasyDD = 1;
else
    EasyDD = 0;
end

if strcmp(VaryStepSizeI,'a')
    numruntimes=floor(min(r,c)/2)-1;
%     numruntimes=3;
    VaryStepSize=0;
    disp('run all step sizes')
elseif strcmp(VaryStepSizeI,'t')
    numruntimes=1+floor(log2(min(r,c)/2))+ceil(mod(log2(min(r,c)/2),1));
%     numruntimes=3;
    VaryStepSize=0;
    disp('run step sizes of two')
else
    numruntimes=1;
    if isnumeric(VaryStepSizeI)
        VaryStepSize = VaryStepSizeI;
    else
        VaryStepSize=str2double(VaryStepSizeI);
    end
end
disp(numruntimes)


for run=1:numruntimes
% let b=1 direction related to Fc
% let c=2 direction related to Fa




if run==1
    
    if strcmp(Settings.ScanType,'L')
        if VaryStepSize>0
            Settings.ScanType='LtoSquare';
            %change stepsize
            stepsize_orig = abs((data.xpos(5)-data.xpos(2))/1e6); %units in meters
        else
            cstype=questdlg('Run as square grid?','Change Analysis Grid','Yes','No','No');
            if strcmp(cstype,'Yes')
                Settings.ScanType='LtoSquare';
                %change stepsize
                stepsize_orig = abs((data.xpos(5)-data.xpos(2))/1e6); %units in meters
            end
        end
    end
elseif run==2 && strcmp(Settings.ScanType,'LtoSquare')
    stepsize_orig = abs((data.xpos(5)-data.xpos(2))/1e6);
end
ScanType=Settings.ScanType;
alpha_data.r=r;
alpha_data.c=c;


% Ask if user would like to skip points periodically (effective increase of
% step size)

if VaryStepSize>0
    special=1;
end
skippts=VaryStepSize;
if skippts>=floor(r/2) || skippts>=floor(c/2)
    disp('BAD IDEA: THIS WON''T YIELD GOOD RESULTS')
end
% 
% alist=zeros(r,c);
% clist=alist;
% alist(1:skippts+1,1:skippts+1)=1;
% alist=alist';
% alist=alist(:);
% clist(skippts+2:end,skippts+2:end)=1;
% clist=clist';
% clist=clist(:);

rowlist=1:r;
collist=1:c;
% rowlist=find(mod(rowlist-1,skippts+1)==0);
% collist=find(mod(collist-1,skippts+1)==0);
if ~strcmp(Settings.ScanType,'Hexagonal')
    INL=reshape(Inds,[c r])';
    INL=INL(rowlist,collist);
    r = length(rowlist);%
    c = length(collist);%
    INL=INL';
    Inds=INL(:);
end
% adjust these values for a new grid

% End of setup for different step size
disp(Settings.ScanType)
if ~strcmp(Settings.ScanType,'L')
    
    ScanImage = Settings.patterns.getPattern(Settings,1);
    
    [roixc,roiyc]= GetROIs(ScanImage,Settings.NumROIs,Settings.PixelSize,...
        Settings.ROISize, Settings.ROIStyle);
    Settings.roixc = roixc;
    Settings.roiyc = roiyc;

    N = Settings.ScanLength;
    
    lattice=cell(N,1);
    Burgers=zeros(N,1);

    %Get info for Subscans
    if isfield(Settings,'Resize') && ~all(Settings.Resize == [c r])
        Oldsize = Settings.Resize;
    else
        Oldsize = [c r];
    end
    if strcmp(Settings.ScanType,'Hexagonal')
        FullLength = Oldsize(1)*Oldsize(2)-floor(Oldsize(2)/2);
    elseif strcmp(Settings.ScanType,'Square')
        FullLength = prod(Oldsize);
    end

    
    %FullLength = 10;
    %uncomment this^^ line if you want it to run less images
    
    %Get Material Info
    for p=1:FullLength
        Material = ReadMaterial(lower(Settings.Phase{p}));
        lattice{p}=Material.lattice;
        Burgers(p)=Material.Burgers;
    end
    b = Burgers;
    if isempty(b)
       errordlg('No Burgers vector specified for this material in Materials sub-folder).','Error');
       return
    end
    
    %Set up Parameters
    [RefInds,Refg,NumInds] = GetDDSettings(Settings.Inds,Allg,Oldsize,ScanType,skippts);
    
    %Preallocate
    misanglea = zeros(Settings.ScanLength,1);
    misanglec = zeros(Settings.ScanLength,1);
    
    %Perform Calculation
    if Settings.DoParallel > 1
        pool = gcp('nocreate');
        if isempty(pool)
            pool = parpool(Settings.DoParallel);
        end
        pctRunOnAll javaaddpath('java')
        ppm = ParforProgMon( 'Dislocation Density Progress ', N , 1, 400, 50);
        
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

        parfor (cnt = 1:N)% Change for parallel computing
            if ~EasyDD
                [AllFa{cnt},AllSSEa(cnt),AllFc{cnt},AllSSEc(cnt), misanglea(cnt),misanglec(cnt)] = ...
                    DDCalc(RefInds(cnt,:),Refg(:,:,:,cnt),lattice{cnt},ImageFilter,Settings);
            else
                [AllFa{cnt},AllFc{cnt}, misanglea(cnt),misanglec(cnt)] = ...
                    DDCalcEasy(RefInds(cnt,:),Refg(:,:,:,cnt),lattice{cnt},Settings);
                AllSSEa(cnt) = 0;
                AllSSEc(cnt) = 0;
            end
            ppm.increment();
        end
        ppm.delete();
    else
        h = waitbar(0,'Single Processor Progress');
        for cnt = 1:N
            if ~EasyDD
                [AllFa{cnt},AllSSEa(cnt),AllFc{cnt},AllSSEc(cnt), misanglea(cnt),misanglec(cnt)] = ...
                    DDCalc(RefInds(cnt,:),Refg(:,:,:,cnt),lattice{cnt},ImageFilter,Settings);
            else
                [AllFa{cnt},AllFc{cnt},misanglea(cnt),misanglec(cnt)] = ...
                    DDCalcEasy(RefInds(cnt,:),Refg(:,:,:,cnt),lattice{cnt},Settings);
                AllSSEa(cnt) = 0;
                AllSSEc(cnt) = 0;
            end
            waitbar(cnt/N,h)
        end
        close(h);
    end
    
    if NoStrain
        for i = 1:Settings.ScanLength
            AllFa{i} = poldec(AllFa{i});
            AllFc{i} = poldec(AllFc{i});
        end
    end
            
    data.Fa=AllFa;
    data.SSEa=AllSSEa;
    data.Fc=AllFc;
    data.SSEc=AllSSEc;

    
    
    misang = max(misanglea,misanglec);

end
if strcmp(Settings.ScanType,'Hexagonal')
    Beta=zeros(3,3,3,Settings.ScanLength);
    alpha_total3=zeros(1,Settings.ScanLength);
    alpha_total5=zeros(1,Settings.ScanLength);
    alpha_total9=zeros(1,Settings.ScanLength);
else
    Beta=zeros(3,3,3,Settings.ScanLength);
    alpha_total3=zeros(1,Settings.ScanLength);
    alpha_total5=zeros(1,Settings.ScanLength);
    alpha_total9=zeros(1,Settings.ScanLength);
end

% if strcmp(Settings.ScanType,'L')
    FcList = [data.Fc{:}];
    FcArray=reshape(FcList,[3,3,length(FcList(1,:))/3]);
    FaList = [data.Fa{:}];
    FaArray=reshape(FaList,[3,3,length(FaList(1,:))/3]);
% end

% rotate Fs into sample frame, in order to take derivatives in the sample
% frame  *****can probably vectorize this using Tony Fast's stuff *****
% HROIM angles for grain boundary calc
Angles=cell2mat(data.g);
n=length(Angles)/3;
angles=zeros(n,3);
n=1:n;
for i=1:3
    angles(:,i)=Angles((n-1)*3+i)';
end

% if strcmp(Settings.ScanType,'L')
    thisF=zeros(3,3);
    FaSample=FaArray;
    FcSample=FcArray;
    for i=1:length(FaArray(1,1,:))
        g=euler2gmat(angles(i,1),angles(i,2),angles(i,3));% this give g(sample to crystal)
        thisF(:,:)=FaArray(:,:,i);
        FaSample(:,:,i)=g'*thisF*g; %check this is crystal to sample
        thisF(:,:)=FcArray(:,:,i);
        FcSample(:,:,i)=g'*thisF*g; %check this is crystal to sample
    end
    
    clear FaArray FaList FcArray FcList
% end

%Determine Step Size
if strcmp(ScanType,'Hexagonal')
    step = skippts+0.5;
    stepsizea = stepsize_orig*(ceil(step)*sqrt(3)/2);
    stepsizec = stepsize_orig*step;
else
    stepsizea = stepsize_orig*(skippts+1);
    stepsizec = stepsizea;
end

NoiseCutoff=log10((0.006*pi/180)/(stepsizea*max(b))); %lower cutoff filters noise below resolution level
disp(stepsizea)
LowerCutoff=log10(1/stepsizea^2);
MinCutoff=max([LowerCutoff(:),NoiseCutoff(:)]);
UpperCutoff=log10(1/(min(b)*stepsizea));
alpha_data.Fa=FaSample;
alpha_data.Fc=FcSample;

disp(['MinCutoff: ',num2str(MinCutoff)])
disp(['UpperCutoff: ',num2str(UpperCutoff)])

if doEnforcedAntisymetry
    for ii = 1:Settings.ScanLength
        FaSample(:, :, ii) = poldec(FaSample(:, :, ii));
        FcSample(:, :, ii) = poldec(FcSample(:, :, ii));
    end
end

repetedEye = repmat(eye(3), [1, 1, Settings.ScanLength]);

beta_c = FcSample - repetedEye;
beta_a= -(FaSample - repetedEye);

if doEnforcedAntisymetry
    Qps = frameTransforms.phosphorToSample(Settings);
    
    for ii = 1:Settings.ScanLength
        
        beta_c(:, :, ii) = enforceAntisymetry(beta_c(:, :, ii), Qps);
        beta_a(:, :, ii) = enforceAntisymetry(beta_a(:, :, ii), Qps);
    end

end

% Beta is the derivate of the beta tensors
% Beta(i,j,k(Fc=1 or Fa=2),point number)=0;
Beta(:, :, 1, :) = beta_c / stepsizea;
Beta(:, :, 2, :) = beta_a / stepsizea;

alpha_data.beta_a = beta_a;
alpha_data.beta_c = beta_c;
alpha_data.Beata = Beta;

left = squeeze([Beta(:, 2, 3, :), Beta(:, 3, 1, :), Beta(:, 1, 2, :)]);
right = squeeze([Beta(:, 3, 2, :), Beta(:, 1, 3, :), Beta(:, 2, 1, :)]);

burgers = permute(repmat(b(Inds), [1, 3, 3]), [2, 3, 1]);

alpha = (left - right) ./ burgers;

% Filter out bad data
alpha_filt=alpha;

%Use Full-size scan dimensions
c = Oldsize(1);
r = Oldsize(2);

%Filter alpha data
badMisAng = misang > maxMisorientation;
differentGrains =...
    Settings.grainID(RefInds(:,2))~=Settings.grainID(RefInds(:,1)) |...
    Settings.grainID(RefInds(:,2))~=Settings.grainID(RefInds(:,3));

filteredInds = badMisAng | differentGrains;
alpha_filt(:, :, filteredInds) = 0;
discount = sum(filteredInds);

alpha_total3(1,:)=30/10.*(...
    abs(alpha_filt(1,3,:)) +...
    abs(alpha_filt(2,3,:)) +...
    abs(alpha_filt(3,3,:)));
alpha_total5(1,:)=30/14.*(...
    abs(alpha_filt(1,3,:)) +...
    abs(alpha_filt(2,3,:)) +...
    abs(alpha_filt(3,3,:)) +...
    abs(alpha_filt(2,1,:)) +...
    abs(alpha_filt(1,2,:)));
alpha_total9(1,:)=30/20.*(...
    abs(alpha_filt(1,3,:)) +...
    abs(alpha_filt(2,3,:)) +...
    abs(alpha_filt(3,3,:)) +...
    abs(alpha_filt(1,1,:)) +...
    abs(alpha_filt(2,1,:)) +...
    abs(alpha_filt(3,1,:)) +...
    abs(alpha_filt(1,2,:)) +...
    abs(alpha_filt(2,2,:)) +...
    abs(alpha_filt(3,2,:)));


%save averaged alphas to a file.
% OutPath = Settings.OutputPath;
% SlashInds = find(OutPath == '\');
% OutDir = OutPath(1:SlashInds(end));
%Create alpha_data to store information for later
alpha_data.alpha_total3=alpha_total3;
alpha_data.alpha_total5=alpha_total5;
alpha_data.alpha_total9=alpha_total9;
alpha_data.alpha=alpha;
alpha_data.alpha_filt=alpha_filt;
alpha_data.misang=misang;
alpha_data.misanglea=misanglea;
alpha_data.misanglec=misanglec;
alpha_data.MisAngleInds=RefInds;
alpha_data.discount=discount;
% alpha_data.intensityr=intensityr;
alpha_data.stepsizea=stepsizea;
alpha_data.stepsizec=stepsizec;
alpha_data.b=b(Inds);
alpha_data.NumInds = NumInds;
alpha_data.filteredInds=filteredInds;

% if special==1
%     disp('special')
%     disp(num2str(stepsizea))
%     Settings.OutputPath=[AnalysisParamsPath(1:end-8),'Skip',num2str(skippts),'.ang.mat']; 
%     save(Settings.OutputPath,'Settings');
%     save(Settings.OutputPath ,'alpha_data','-append'); 
% elseif strcmp(Settings.ScanType,'LtoSquare')
%     disp('LtoSquare')
%     Settings.OutputPath=[AnalysisParamsPath(1:end-8),'LtoSquare.ang.mat'];
%     save(Settings.OutputPath ,'Settings');     
%     save(Settings.OutputPath ,'alpha_data','-append'); 
% else
%     disp('Normal Norman')
%     save(AnalysisParamsPath ,'alpha_data','-append'); 
% end
    
% pgnd=logspace(11,17);
% Lupper=1./sqrt(pgnd);
% Llower=1./(b*pgnd);
% Lusafe=Lupper/3;
% Llsafe=Llower/3;
% 
% figure;loglog(pgnd,Lupper,'r',pgnd,Llower,'b',pgnd,Lusafe,'r',pgnd,Llsafe,'b')%,...
%                 %pgnd,2e-7*ones(size(pgnd)),'--g',pgnd,4e-6*ones(size(pgnd)),'--g')
% % grid on
% hold on
% plot(alpha_data.alpha_total3,stepsize*ones(size(alpha_data.alpha_total3)),'*k')
% xlim([10^11 10^17])
% pm=[14.5953, 13.1897 13.0449 12.8969 12.4546 12.1251 12.2425 mean(log10(alpha_data.alpha_total3))];
% pmupper=10.^(pm+[.3429 .7346 1.4164 1.9906 2.7976 3.3855 3.4416 std(log10(alpha_data.alpha_total3))]);
% pmlower=10.^(pm-[.3429 .7346 1.4164 1.9906 2.7976 3.3855 3.4416 std(log10(alpha_data.alpha_total3))]);
% Lm=[2e-7, 4e-6 8e-6 1.2e-5 1.6e-5 2e-5 2.4e-5 stepsize];
% plot(10.^pm,Lm,'ok')

% % HROIM angles for grain boundary calc
% Angles=cell2mat(data.g);
% n=length(Angles)/3;
% angles=zeros(n,3);
% n=[1:n];
% for i=1:3
%     angles(:,i)=Angles((n-1)*3+i)';
% end
% angles = reshape(angles,[r,c,3]);
% clean=1;    %set to 1 to clean up small grains
% small=5;   % set to size of minimum grain size (pixels) for cleanup
% mistol=MaxMisorientation*pi/180;   % maximum misorientation within a grain

% [grains grainsize sizes BOUND]=findgrains(angles, lattice, clean, small, mistol);
% % BOUND=flipud(fliplr(BOUND));
% x=[1:r];
% y=[1:c];
% [X Y]=meshgrid(x,y);
% X=X';
% Y=Y';

% Calculate average total dislocation density
% alpha_total_ave=sum(sum(abs(alpha_total3)))/(r*c-discount)
% alpha_total_ave5=sum(sum(abs(alpha_total5)))/(r*c-discount);
% alpha_total_ave9=sum(sum(abs(alpha_total9)))/(r*c-discount);

    special =1;
    if strcmp(Settings.ScanType,'L')
        disp(1)
        Settings.ScanType='LtoSquare';
        NewAngles=cell2mat(data.g');
        Allg=Settings.Angles;
        Allg(Settings.Inds,:) = NewAngles;
    elseif numruntimes>1
        if strcmp(VaryStepSizeI,'t')
            if run==numruntimes-1
                disp(2)
                VaryStepSize=floor(min(r,c)/2)-1;
            else
                disp(4)
                VaryStepSize=VaryStepSize*2+1;
            end
        else
            disp(5)
            VaryStepSize=VaryStepSize+1;
        end
    else
        disp(6)
        %nothing
    end
    disp(Settings.OutputPath)
    disp(VaryStepSize)
    
end
 alpha_data=rmfield(alpha_data,'r');
 alpha_data=rmfield(alpha_data, 'c');

save(AnalysisParamsPath ,'alpha_data','-append'); 

end

function [AllFa,AllSSEa,AllFc,AllSSEc, misanglea, misanglec] = DDCalc(RefInd,RefG,lattice,ImageFilter,Settings)

    image_a2= 0;
    RefIndA2 = 0;
    image_c2 = 0;
    RefIndC2 = 0;
    
    skippts = Settings.NumSkipPts;
    
    %Extract Dim variables
    r = Settings.Ny;%
    
    %Extract Variables 
    RefIndA = RefInd(1);
    cnt = RefInd(2);
    RefIndC = RefInd(3);
    
    Amat = RefG(:,:,1);
    g_b = RefG(:,:,2);
    Cmat = RefG(:,:,3);
    
    %Get Patterns
    image_a = Settings.patterns.getPattern(Settings,RefIndA);
    image_b = Settings.patterns.getPattern(Settings,cnt);
    image_c = Settings.patterns.getPattern(Settings,RefIndC);
    
    
    
    if strcmp(Settings.ScanType,'Hexagonal')
        step = skippts+0.5;
        Cind = 4;
        if mod(ceil(step),2) %Two Ref A's
            % FIXME This seems odd, I'll need to fix it... --Zach C.
            RefIndA2 = RefInd(4);
            image_a2 = Settings.patterns.getPattern(Settings,RefIndA2);
            Cind = 5;
        end
        if mod(step,1) > 0 %Two Ref C's
            RefIndC2 = RefInd(Cind);
            image_c2 = Settings.patterns.getPattern(Settings,RefIndC2);
        end
    end
    
    misanglea=GeneralMisoCalc(g_b,Amat,lattice);
    misanglec=GeneralMisoCalc(g_b,Cmat,lattice);
    % evaluate points a and c using Wilk's method with point b as the
    % reference pattern
    %         imgray=rgb2gray(imread(ImagePath)); % this can add significant time for large scans
    %         intensityr(cnt)=mean(imgray(:));

    if (isempty(image_a)) || (isempty(image_b)) ||  (isempty(image_c)) || ...
            (RefIndA2>0 && isempty(image_a2)) || (RefIndC2>0 && isempty(image_c2))
        AllFa= -eye(3);
        AllSSEa=101;
        AllFc=-eye(3);
        AllSSEc=101;
    else
        % first, evaluate point a
        if r > 1 %Not Line Scan

            clear global rs cs Gs
            if RefIndA2 == 0
                    [AllFa,AllSSEa] = CalcFShift(image_b,image_a,g_b,eye(3),RefIndA,Settings,Settings.Phase{cnt}, cnt);%g_b or Amat?
            else
                [AllFa1,AllSSEa1] = CalcFShift(image_b,image_a ,g_b,eye(3),RefIndA,Settings,Settings.Phase{cnt},cnt );
                [AllFa2,AllSSEa2] = CalcFShift(image_b,image_a2,g_b,eye(3),RefIndA2,Settings,Settings.Phase{cnt},cnt);
                AllFa=0.5*(AllFa1+AllFa2);
                if isstruct(AllSSEa1)
                    AllSSEa1=AllSSEa1.SSE;
                    AllSSEa2=AllSSEa2.SSE;
                end
                AllSSEa=0.5*(AllSSEa1+AllSSEa2);
            end
        else
            AllFa= -eye(3);
            AllSSEa=101;
        end

        % then, evaluate point c
        clear global rs cs Gs
        if RefIndC2 == 0
            [AllFc,AllSSEc] = CalcFShift(image_b,image_c ,g_b,eye(3),RefIndC,Settings,Settings.Phase{cnt},cnt);
        else
            [AllFc1,AllSSEc1] = CalcFShift(image_b,image_c ,g_b,eye(3),RefIndC,Settings,Settings.Phase{cnt},cnt);
            [AllFc2,AllSSEc2] = CalcFShift(image_b,image_c2,g_b,eye(3),RefIndC2,Settings,Settings.Phase{cnt},cnt);
            AllFc=0.5*(AllFc1+AllFc2);
            if isstruct(AllSSEc1)
                    AllSSEc1=AllSSEc1.SSE;
                    AllSSEc2=AllSSEc2.SSE;
                end
            AllSSEc=0.5*(AllSSEc1+AllSSEc2);
        end
    end
end

function [AllFa,AllFc,misanglea,misanglec] = DDCalcEasy(RefInd, RefG, lattice, Settings)
    

    skippts = Settings.NumSkipPts;
        
    %Extract Dim variables
    r = Settings.Ny;%
        
    %Extract Variables 
    RefIndA = RefInd(1);
    cnt = RefInd(2);
    RefIndC = RefInd(3);

    Amat = RefG(:,:,1);
    g_b = RefG(:,:,2);
    Cmat = RefG(:,:,3);

    if strcmp(Settings.ScanType,'Hexagonal')
        step = skippts+0.5;
        Cind = 4;
        if mod(ceil(step),2) %Two Ref A's
            RefIndA2 = RefInd(4);
            Cind = 5;
        end
        if mod(step,1) > 0 %Two Ref C's
            RefIndC2 = RefInd(Cind);
        end
    end
                
    misanglea=GeneralMisoCalc(g_b,Amat,lattice); %need to check the second A-point if hexagonal scan grid***
    misanglec=GeneralMisoCalc(g_b,Cmat,lattice);
    
    Fbinv = inv(g_b'*Settings.data.F(:,:,cnt)*g_b); % in sample frame
%     Fbinv = inv(Settings.data.F{cnt}); % in crystal frame
    % first, evaluate point a
    if r > 1 %Not Line Scan
        if ~strcmp(Settings.ScanType,'Hexagonal') || (strcmp(Settings.ScanType,'Hexagonal') && skippts>0)
            AllFa = g_b*Amat'*Settings.data.F(:,:,RefIndA)*Amat*Fbinv*g_b'; %put Fa in sample frame, then put the whole thing back in crystal
%             AllFa = Settings.data.F{RefIndA}*Fbinv; %leave in crystal
                else
            Amat2=euler2gmat(Settings.data.NewAngles(RefIndA2,1),Settings.data.NewAngles(RefIndA2,2),Settings.data.NewAngles(RefIndA2,3));
            AllFa1 = g_b*Amat'*Settings.data.F(:,:,RefIndA1)*Amat*Fbinv*g_b';
            AllFa2 = g_b*Amat2'*Settings.data.F(:,:,RefIndA2)*Amat2*Fbinv*g_b';
            AllFa=0.5*(AllFa1+AllFa2);
                end
                
        % scale a direction step F tensor for different step size 
        if strcmp(Settings.ScanType,'Hexagonal')
            AllFatemp=AllFa-eye(3);
            AllFatemp=AllFatemp/sqrt(3)*2;
            AllFa=AllFatemp+eye(3);
        end
                else
        AllFa= -eye(3);
            end
    % then, evaluate point c
    AllFc = g_b*Cmat'*Settings.data.F(:,:,RefIndC)*Cmat*Fbinv*g_b'; %sample then back to crystal
%     AllFc = Settings.data.F{RefIndC}*Fbinv; %crystal

            
            end

function [RefInd,Refg,NumInds] = GetDDSettings(Inds,Angles,Dims,ScanType,skippts)
    if size(Inds,1) == 1
        Inds = Inds';
        end
       
    %Get Reference Images
    [RefIndA,RefIndC] = GetAdjacentInds(Dims,Inds,skippts,ScanType);
    RefInd = [RefIndA(:,1) Inds RefIndC(:,1)];
    
    NumInds.A = 1;
    NumInds.C = 1;
    if strcmp(ScanType,'Hexagonal')
        step = skippts+0.5;
        if mod(ceil(step),2) %Two Ref A's
            RefInd = [RefInd RefIndA(:,2)];
            NumInds.A = 2;
        end
        if mod(step,1) > 0 %Two Ref C's
            RefInd = [RefInd RefIndC(:,2)];
            NumInds.C = 2;
    end
    end
    
    %Get Reference Angles
    g = euler2gmat(Angles);
    Refg = permute(reshape(g(:,:,RefInd),3,3,length(Inds),[]),[1 2 4 3]);
    
end

function beta = enforceAntisymetry(beta, Qps)

Qsp = Qps';

beta = Qsp * beta * Qsp';

beta(3, 1) = -beta(1, 3);
beta(3, 2) = -beta(2, 3);

beta = Qps * beta * Qps';

end
