function DislocationDensityCalculate(Settings,MaxMisorientation,IQcutoff,VaryStepSizeI)
%DISLOCATIONDENSITYOUTPUT
%DislocationDensityOutput(Settings,Components, cmin, cmax, MaxMisorientation)
%code bits for this function taken from Step2_DisloDens_Lgrid_useF_2.m
%authors include: Collin Landon, Josh Kacher, Sadegh Ahmadi, and Travis Rampton
%modified for use with HROIM GUI code, Jay Basinger 4/20/2011
format compact
tic

%Calculate Dislocation Density
data = Settings.data;
AnalysisParamsPath=Settings.AnalysisParamsPath;
r = data.rows;%
c = data.cols;%
stepsize_orig = abs((data.xpos(3)-data.xpos(2))/1e6); %units in meters. This is for square grid
Allg=data.g;
ImageNamesList=Settings.ImageNamesList;
ImageFilter=Settings.ImageFilter;
special=0;

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
intensityr=zeros(size(ImageNamesList));
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
    INL=reshape(ImageNamesList,[c r])';
    INL=INL(rowlist,collist);
    r = length(rowlist);%
    c = length(collist);%
    INL=INL';
    ImageNamesList=INL(:);
end
% adjust these values for a new grid

stepsize = stepsize_orig*(skippts+1);

% End of setup for different step size
disp(Settings.ScanType)
if ~strcmp(Settings.ScanType,'L')
    
    ScanImage = ReadEBSDImage(ImageNamesList{1},Settings.ImageFilter);
    [roixc,roiyc]= GetROIs(ScanImage,Settings.NumROIs,Settings.PixelSize,...
        Settings.ROISize, Settings.ROIStyle);
    Settings.roixc = roixc;
    Settings.roiyc = roiyc;

  %Not sure if everything before matlabpool close force is necessary...Travis?  ImageNamesList=Settings.ImageNamesList;
  %  ImageFilter=Settings.ImageFilter;
   % Allg=data.g;
   % ScanType=Settings.ScanType;
   % intensityr=zeros(size(ImageNamesList));

    
    N = length(Settings.ImageNamesList);
    
    lattice=cell(N,1);
    Burgers=zeros(N,1);

    for p=1:N
        Material = ReadMaterial(lower(Settings.Phase{p}));
        lattice{p}=Material.lattice;
        Burgers(p)=Material.Burgers;
    end
    b = Burgers;
    
    %Set up Parameters
    for cnt = 1:N
        DDSettings{cnt} = GetDDSettings(cnt,ImageNamesList,Allg,[r,c],ScanType,skippts);
    end
    
    %Perform Calculation
    if Settings.DoParallel > 1  
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
            [AllFa{cnt},AllSSEa(cnt),AllFc{cnt},AllSSEc(cnt), misang(cnt)] = ...
                DDCalc(DDSettings{cnt},lattice{cnt},ImageFilter,Settings);
            ppm.increment();
        end
        ppm.delete();
    else
        h = waitbar(0,'Single Processor Progress');
        for cnt = 1:N
            [AllFa{cnt},AllSSEa(cnt),AllFc{cnt},AllSSEc(cnt), misang(cnt)] = ...
                DDCalc(DDSettings{cnt},lattice{cnt},ImageFilter,Settings);
            waitbar(cnt/N,h);
        end
        close(h);
    end
            
    data.Fa=AllFa;
    data.SSEa=AllSSEa;
    data.Fc=AllFc;
    data.SSEc=AllSSEc;

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
lattice=cell(i,1);
Burgers=zeros(i,1);
for p=1:i
    Material = ReadMaterial(lower(Settings.Phase{p}));
    lattice{p}=Material.lattice;
    Burgers(p)=Material.Burgers;
end
b = Burgers;
if isempty(b)
   errordlg('No Burgers vector specified for this material in Materials sub-folder).','Error');
   return
end

NoiseCutoff=log10((0.006*pi/180)/(stepsize*max(b))); %lower cutoff filters noise below resolution level
disp(stepsize)
LowerCutoff=log10(1/stepsize^2);
MinCutoff=max([LowerCutoff(:),NoiseCutoff(:)]);
UpperCutoff=log10(1/(min(b)*stepsize));
alpha_data.Fa=FaSample;
alpha_data.Fc=FcSample;

disp(['MinCutoff: ',num2str(MinCutoff)])
disp(['UpperCutoff: ',num2str(UpperCutoff)])

% Beta(i,j,k(Fc=1 or Fa=2),point number)=0;

Beta(1,1,2,:)=(FcSample(1,1,:)-1)/stepsize;
% Beta(1,2,2,:)=FcSample(1,2,:)/stepsize;
Beta(1,3,2,:)=FcSample(1,3,:)/stepsize;
% Beta(1,1,1,:)=-(FaSample(1,1,:)-1)/stepsize;
Beta(1,2,1,:)=-FaSample(1,2,:)/stepsize;
Beta(1,3,1,:)=-FaSample(1,3,:)/stepsize;

Beta(2,1,2,:)=(FcSample(2,1,:))/stepsize;
% Beta(2,2,2,:)=(FcSample(2,2,:)-1)/stepsize;
Beta(2,3,2,:)=FcSample(2,3,:)/stepsize;
Beta(2,2,1,:)=-(FaSample(2,2,:)-1)/stepsize;
% Beta(2,1,1,:)=-FaSample(2,1,:)/stepsize;
Beta(2,3,1,:)=-FaSample(2,3,:)/stepsize;

Beta(3,1,2,:)=FcSample(3,1,:)/stepsize;
% Beta(3,2,2,:)=FcSample(3,2,:)/stepsize;
Beta(3,3,2,:)=(FcSample(3,3,:)-1)/stepsize;
% Beta(3,1,1,:)=-FaSample(3,1,:)/stepsize;
Beta(3,2,1,:)=-FaSample(3,2,:)/stepsize;
Beta(3,3,1,:)=-(FaSample(3,3,:)-1)/stepsize;
% keyboard
alpha(1,1,:)=shiftdim(Beta(1,2,3,:)-Beta(1,3,2,:))./shiftdim(b);
alpha(1,2,:)=shiftdim(Beta(1,3,1,:)-Beta(1,1,3,:))./shiftdim(b);
alpha(1,3,:)=shiftdim(Beta(1,1,2,:)-Beta(1,2,1,:))./shiftdim(b);

alpha(2,1,:)=shiftdim(Beta(2,2,3,:)-Beta(2,3,2,:))./shiftdim(b);
alpha(2,2,:)=shiftdim(Beta(2,3,1,:)-Beta(2,1,3,:))./shiftdim(b);
alpha(2,3,:)=shiftdim(Beta(2,1,2,:)-Beta(2,2,1,:))./shiftdim(b);

alpha(3,1,:)=shiftdim(Beta(3,2,3,:)-Beta(3,3,2,:))./shiftdim(b);
alpha(3,2,:)=shiftdim(Beta(3,3,1,:)-Beta(3,1,3,:))./shiftdim(b);
alpha(3,3,:)=shiftdim(Beta(3,1,2,:)-Beta(3,2,1,:))./shiftdim(b);

clear FaSample FcSample

% Filter out bad data
discount=0;
alpha_filt=alpha;

if strcmp(Settings.ScanType,'Square') ||  strcmp(Settings.ScanType,'LtoSquare') % Square grid
    misang=zeros(Settings.ScanLength,1);
    for i=1:Settings.ScanLength
        bnum=i;
        if r > 1 
            if i <= c*(skippts+1)
                anum=bnum+c*(skippts+1);
            else
                anum=bnum-c*(skippts+1);
            end
        elseif r == 1
            anum = bnum;
        end
        if mod(i,c)==0 || (c-mod(i,c))<=skippts
            cnum=bnum-(skippts+1);
        else
            cnum=bnum+(skippts+1);
        end
        
        iq = min([data.IQ{anum},data.IQ{bnum},data.IQ{cnum}]);% Is data.IQ shaped the same as ImageNamesList
        %IQcutoff = 0; % bad Jay, I ought to put this as an option somewhere in the OutputPlotting.m GUI
        if (iq<=IQcutoff)
            alpha_filt(:,:,i)=0;
        end
        
        Amat=euler2gmat(Allg{anum}(1),Allg{anum}(2),Allg{anum}(3));
        Bmat=euler2gmat(Allg{bnum}(1),Allg{bnum}(2),Allg{bnum}(3));
        Cmat=euler2gmat(Allg{cnum}(1),Allg{cnum}(2),Allg{cnum}(3));
        misanglea=GeneralMisoCalc(Bmat,Amat,lattice{i});
        misanglec=GeneralMisoCalc(Bmat,Cmat,lattice{i});
        misang(i)=max([misanglea misanglec]);
        if (misang(i)>MaxMisorientation)
            alpha_filt(:,:,i)=0;
        end
        if Settings.grainID(bnum)~=Settings.grainID(anum) || Settings.grainID(bnum)~=Settings.grainID(cnum)
            alpha_filt(:,:,i)=0;
        end
        
        if intensityr(i)<50
%   Find the best way to threshold images with
%         little or no pattern.
            alpha_filt(:,:,i)=0;
        end
        
        if alpha_filt(:,:,i)==0
            discount=discount+1;
        end
    end
end

if strcmp(Settings.ScanType,'L') % L grid
    clear Allg
    phi1=Settings.data.phi1rn;
    PHI=Settings.data.PHIrn;
    phi2=Settings.data.phi2rn;
    Allg=[phi1 PHI phi2];
    
    for i=1:length(data.Fa)
        anum = i*3-2;
        bnum = i*3-1;
        cnum = i*3;
        iq = data.IQ{i};
%         iq = min([data.IQ{anum},data.IQ{bnum},data.IQ{cnum}]);
        IQcutoff = 0; % bad Jay, I ought to put this as an option somewhere in the OutputPlotting.m GUI
        if (iq<=IQcutoff)
            alpha_filt(:,:,i)=0;
        end
        
        Amat=euler2gmat(Allg(anum,1),Allg(anum,2),Allg(anum,3));
        Bmat=euler2gmat(Allg(bnum,1),Allg(bnum,2),Allg(bnum,3));
        Cmat=euler2gmat(Allg(cnum,1),Allg(cnum,2),Allg(cnum,3));
        misanglea=GeneralMisoCalc(Bmat,Amat,lattice{i});
        misanglec=GeneralMisoCalc(Bmat,Cmat,lattice{i});
        misang(i)=max([misanglea misanglec]);
        if (misang(i)>MaxMisorientation)
            alpha_filt(:,:,i)=0;
        end
        if alpha_filt(:,:,i)==0
            discount=discount+1;
        end
    end
end

alpha_total3(1,:)=3.*(abs(alpha(1,3,:))+abs(alpha(2,3,:))+abs(alpha(3,3,:)));
alpha_total5(1,:)=9/5.*(abs(alpha(1,3,:))+abs(alpha(2,3,:))+abs(alpha(3,3,:))+abs(alpha(2,1,:))+abs(alpha(1,2,:)));
alpha_total9(1,:)=abs(alpha(1,3,:))+abs(alpha(2,3,:))+abs(alpha(3,3,:))+abs(alpha(1,1,:))+abs(alpha(2,1,:))+abs(alpha(3,1,:))+abs(alpha(1,2,:))+abs(alpha(2,2,:))+abs(alpha(3,2,:));


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
alpha_data.discount=discount;
alpha_data.intensityr=intensityr;
alpha_data.stepsize=stepsize;
alpha_data.b=b;

if special==1
    disp('special')
    disp(num2str(stepsize))
    Settings.OutputPath=[AnalysisParamsPath(1:end-8),'Skip',num2str(skippts),'.ang.mat']; 
    save(Settings.OutputPath,'Settings');
    save(Settings.OutputPath ,'alpha_data','-append'); 
elseif strcmp(Settings.ScanType,'LtoSquare')
    disp('LtoSquare')
    Settings.OutputPath=[AnalysisParamsPath(1:end-8),'LtoSquare.ang.mat'];
    save(Settings.OutputPath ,'Settings');     
    save(Settings.OutputPath ,'alpha_data','-append'); 
else
    disp('Normal Norman')
    save(AnalysisParamsPath ,'alpha_data','-append'); 
end
    
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
        Allg=data.g;
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
save(AnalysisParamsPath ,'alpha_data','-append'); 

end

function [AllFa,AllSSEa,AllFc,AllSSEc, misang] = DDCalc(DDSettings,lattice,ImageFilter,Settings)

    image_a = 0;
    image_a1 = 0;
    image_a2= 0;
    image_c = 0;
    Amat = 0;
    Cmat = 0;
    RefIndA = 0;
    RefIndA1 = 0;
    RefIndA2 = 0;
    RefIndC = 0;
    
    skippts = Settings.NumSkipPts;
    
    %Extract Dim variables
    r = Settings.data.rows;%
    
    %Extract Image Variables
    image_a = ReadEBSDImage(DDSettings{1,1},ImageFilter);
    image_b = ReadEBSDImage(DDSettings{1,2},ImageFilter);
    image_c = ReadEBSDImage(DDSettings{1,3},ImageFilter);
    
    RefIndA = DDSettings{2,1};
    cnt = DDSettings{2,2};
    RefIndC = DDSettings{2,3};
    
    Amat = DDSettings{3,1};
    g_b = DDSettings{3,2};
    Cmat = DDSettings{3,3};
    
    if size(DDSettings,2) > 3
        image_a1 = image_a;
        image_a2 = ReadEBSDImage(DDSettings{1,4},ImageFilter);
        
        RefIndA1 = RefIndA;
        RefIndA2 = DDSettings{2,4};
    end
    
    misanglea=GeneralMisoCalc(g_b,Amat,lattice);
    misanglec=GeneralMisoCalc(g_b,Cmat,lattice);
    misang=max([misanglea misanglec]);
    % evaluate points a and c using Wilk's method with point b as the
    % reference pattern
    %         imgray=rgb2gray(imread(ImagePath)); % this can add significant time for large scans
    %         intensityr(cnt)=mean(imgray(:));

    if (isempty(image_b)) || (isempty(image_a) && (~strcmp(Settings.ScanType,'Hexagonal'))) || (isempty(image_c)) ||... 
            (strcmp(Settings.ScanType,'Hexagonal') && skippts == 0 && (isempty(image_a1) || isempty(image_a2)))
        AllFa= -eye(3);
        AllSSEa=101;
        AllFc=-eye(3);
        AllSSEc=101;
    else
        % first, evaluate point a
        if r > 1 %Not Line Scan

            clear global rs cs Gs
            if ~strcmp(Settings.ScanType,'Hexagonal') || (Settings.strcmp(ScanType,'Hexagonal') && skippts>0)

                    [AllFa,AllSSEa] = CalcF(image_b,image_a,g_b,eye(3),cnt,Settings,Settings.Phase{cnt}, RefIndA);

            else
                [AllFa1,AllSSEa1] = CalcF(image_b,image_a1,g_b,eye(3),cnt,Settings,Settings.Phase{cnt},RefIndA1);
                [AllFa2,AllSSEa2] = CalcF(image_b,image_a2,g_b,eye(3),cnt,Settings,Settings.Phase{cnt},RefIndA2);
                AllFa=0.5*(AllFa1+AllFa2);
                AllSSEa=0.5*(AllSSEa1+AllSSEa2);
            end

            % scale a direction step F tensor for different step size 
            if strcmp(Settings.ScanType,'Hexagonal')
                AllFatemp=AllFa-eye(3);
                AllFatemp=AllFatemp/sqrt(3)*2;
                AllFa=AllFatemp+eye(3);
            end
        else
            AllFa= -eye(3);
            AllSSEa=101;
        end

        % then, evaluate point c
        clear global rs cs Gs
        if ~strcmp(Settings.ScanType,'Hexagonal') || (strcmp(Settings.ScanType,'Hexagonal') && skippts>0)

            [AllFc,AllSSEc] = CalcF(image_b,image_c,g_b,eye(3),cnt,Settings,Settings.Phase{cnt},RefIndC);

        else
            [AllFc,AllSSEc] = CalcF(image_b,image_c,g_b,eye(3),cnt,Settings,Settings.Phase{cnt},RefIndC);
        end
    end
end

function DDSettings = GetDDSettings(cnt,ImageNamesList,Allg,Dims,ScanType,skippts)
    extra_a = false;
    
    r = Dims(1);
    c = Dims(2);
    
    ImagePath = ImageNamesList{cnt};% Change for parallel computing
    g_b = euler2gmat(Allg{cnt}(1),Allg{cnt}(2),Allg{cnt}(3));% is Allg in the same order as ImageNamesList?

    image_b = ImagePath;% Change for parallel computing
    if strcmp(ScanType,'Square') || strcmp(ScanType,'LtoSquare')% Change for parallel computing
        %Image A
        if r > 1 %No image_a for line scans
            if cnt <= c*(skippts+1) % this is the first row(s)
                RefIndA = cnt+c*(skippts+1); 
            else
                RefIndA = cnt-c*(skippts+1);
            end
            image_a = ImageNamesList{RefIndA};
            Amat=euler2gmat(Allg{RefIndA}(1),Allg{RefIndA}(2),Allg{RefIndA}(3));
        elseif r == 1
            image_a = image_b;
            Amat = eye(3);
            RefIndA = cnt;
        end 
        
        %Image C
        if mod(cnt,c)==0 || (c-mod(cnt,c))<=skippts               
            RefIndC = cnt-(skippts+1);
        else
            RefIndC = cnt+(skippts+1);
        end
        image_c = ImageNamesList{RefIndC}; 
        Cmat=euler2gmat(Allg{RefIndC}(1),Allg{RefIndC}(2),Allg{RefIndC}(3));

    elseif strcmp(ScanType,'Hexagonal')% Change for parallel computing
        % Current hexagonal grid analysis ignores edges and cannot
        % handle skipping points (adding odd skip values)
        
        NColsOdd = c;
        NColsEven = c-1;
        c = NColsOdd+NColsEven;
        leftside=1:c:length(ImageNamesList);
        rightside=NColsOdd:c:length(ImageNamesList);
        rightside=[rightside,c:c:length(ImageNamesList)];
        rightside=sort(rightside);
        topside=rightside(end-1)+1:length(ImageNamesList);

        if sum([find(leftside==cnt),find(rightside==cnt),find(topside==cnt)])==0

            if skippts==0
                %Image A
                RefIndA1 = cnt+NColsEven;
                image_a1 = ImageNamesList{RefIndA1};
                RefIndA2 = cnt+NColsEven+1;
                image_a2 = ImageNamesList{RefIndA2};
                Amat=euler2gmat(Allg{RefIndA1}(1),Allg{RefIndA1}(2),Allg{RefIndA1}(3));
                
                %Image C
                RefIndC = cnt+1;
                image_c = ImageNamesList{RefIndC};% Change for parallel computing
                Cmat=euler2gmat(Allg{RefIndC}(1),Allg{RefIndC}(2),Allg{RefIndC}(3));
                
                extra_a = true;
            else
                %Image A
                if cnt <= c*(skippts+1)/2 % this is the first row(s) / top rows
                    RefIndA = cnt+c*(skippts+1)/2;
                else
                    RefIndA = cnt-c*(skippts+1)/2;
                end
                image_a = ImageNamesList{RefIndA};
                Amat=euler2gmat(Allg{RefIndA}(1),Allg{RefIndA}(2),Allg{RefIndA}(3));
                
                %Image C
                if (mod(cnt,c)>NColsOdd-skippts && mod(cnt,c)<=NColsOdd) || (mod(cnt,c)>c-skippts && mod(cnt,c)<c) % distinguish even and odd rows then first look at points too close to right edge
                    RefIndC = cnt-(skippts+1);
                else
                    RefIndC = cnt+(skippts+1);
                end 
                image_c = ImageNamesList{RefIndC};
                Cmat=euler2gmat(Allg{RefIndC}(1),Allg{RefIndC}(2),Allg{RefIndC}(3));
            end
        else
            image_a = image_b;
            image_a1 = image_b;
            image_a2 = image_b;
            image_c = image_b;

            RefIndA = cnt;
            RefIndA1 = cnt;
            RefIndA2 = cnt;
            RefIndC = cnt;

            Amat=g_b;
            Cmat=g_b;
            
        end
       
    end
    if extra_a
        DDSettings = {image_a1,image_b,image_c,image_a2;...
                        RefIndA1,cnt,RefIndC,RefIndA2;...
                        Amat,g_b,Cmat,[]};
    else
        DDSettings = {image_a,image_b,image_c;...
                        RefIndA,cnt,RefIndC;...
                        Amat,g_b,Cmat};
    end
    
    
end