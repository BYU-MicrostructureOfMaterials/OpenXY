function StrainOutput(Settings,Components,DoShowGB,smin,smax,MaxMisorientation,IQcutoff)
%STRAINOUTPUT
%StrainOutput(Settings,Components,DoShowGB,smin,smax,MaxMisorientation)
%Plot strain components
%code bits for this function taken from Step2_DisloDens_Lgrid_useF_2.m
%authors include: Collin Landon, Josh Kacher, Sadegh Ahmadi, and Travis Rampton
%modified for use with HROIM GUI code, Jay Basinger 4/20/2011

data = Settings.data;
r = data.rows;
c = data.cols;

%%
if iscell(data.g)
    Angles=cell2mat(data.g);
    n=length(Angles)/3;
    angles=zeros(n,3);
    n=[1:n];
    for i=1:3
        angles(:,i)=Angles((n-1)*3+i)';
    end
else
    angles = Settings.data.g;
end
%{
if DoShowGB && ~strcmp(Settings.ScanType,'Hexagonal')
    % parameters for grain finding algorithm
    clean=1;    %set to 1 to clean up small grains
    small=5;   % set to size of minimum grain size (pixels) for cleanup
    mistol=MaxMisorientation*pi/180;   % maximum misorientation within a grain
    % rotate Fs into sample frame, in order to take derivatives in the sample
    % frame  *****can probably vectorize this using Tony Fast's stuff *****
    % HROIM angles for grain boundary calc
    
    if ~strcmp(Settings.Material,'Scan File')
        anglestemp = reshape(angles,[r,c,3]);
        Material = ReadMaterial(Settings.Material);
        [~,~,~,BOUND]=findgrains(anglestemp, Material.lattice, clean, small, mistol);
        % BOUND=flipud(fliplr(BOUND));
        
        x=1:r;
        y=1:c;
        [X,Y]=meshgrid(x,y);
        X=X';
        Y=Y';
    end
end
%}

% Strain plots ************************

%Ignore obviously bad points
SSE = Settings.SSE;
BadIndex = 1:length(SSE);
cutoff = (mean(SSE(SSE ~= inf)) + 2*std(SSE(SSE ~= inf)));
BadPoints = SSE > cutoff;
BadIndex = BadIndex(BadPoints);
for j = 1:length(BadIndex)
    data.F(:,:,BadIndex(j)) = eye(3);
end

% FList = [data.F{:}];
% FArray=reshape(FList,[3,3,length(FList(1,:))/3]);

FArray = data.F;

thisF=zeros(3);
FSample=FArray;
U = zeros(size(FArray));
for i=1:length(FArray(1,1,:))
    g=euler2gmat(angles(i,1),angles(i,2),angles(i,3));% this give g(sample to crystal)
    thisF(:,:)=FArray(:,:,i);
    %[R,U(1:3,1:3,i)]=poldec(thisF);
    FSample(:,:,i)=g'*thisF*g; %check this is crystal to sample
end
FSampleTransp=permute(FSample,[2,1,3]); % sample frame
strain=(FSample+FSampleTransp)/2;
%{
min11 = min(strain(1,1,:));
min12 = min(strain(1,2,:));
min13 = min(strain(1,3,:));
min22 = min(strain(2,2,:));
min23 = min(strain(2,3,:));
min33 = min(strain(3,3,:));
for j = BadIndex
    strain(1,1,j) = min11;
    strain(1,2,j) = min12;
    strain(1,3,j) = min13;
    strain(2,2,j) = min22;
    strain(2,3,j) = min23;
    strain(3,3,j) = min33;
end
%}
%%
% strain = U;
% FArrayTransp=permute(FArray,[2,1,3]); % crystal frame
% strain=(FArray+FArrayTransp)/2;
strain(1,1,:)=strain(1,1,:)-1;
strain(2,2,:)=strain(2,2,:)-1;
strain(3,3,:)=strain(3,3,:)-1;
lines = [];
oldLines = [];
for i=1:3
    for j=i:3
        epsij=strain(i,j,:);
        if strcmp(Settings.ScanType,'Hexagonal')
            NColsOdd = c;
            NColsEven = c-1;
            NRows = r;
            count = 1;
            
            NewEpsij = zeros(NRows,NColsEven);
            if i==1 && j==1
                gmap = zeros(NRows,NColsEven);
            end
            for rr = 1:NRows
                if bitget(abs(rr),1)~=0 %odd
                    
                    for cc = 1:NColsOdd
                        NewEpsij(rr,cc) = epsij(count);
                        if i==1 && j==1
                            gmap(rr,cc)=Settings.grainID(count);
                        end
                        count = count + 1;
                    end
                else
                    for cc = 1:NColsEven
                        NewEpsij(rr,cc) = epsij(count);
                        if i==1 && j==1
                            gmap(rr,cc)=Settings.grainID(count);
                        end
                        count = count + 1;
                    end
                end
            end
            epsij = NewEpsij;
            
        else
            epsij=reshape(epsij, [c r])';
            
        end
        
        if r == 1
            epsij = repmat(epsij,Settings.ScanLength,1);
        end
        
        epsijvec = map2vec(epsij);
        AverageStrain = mean(epsijvec(~BadPoints));
        %cMap = [[0 0 0];parula(126);[0 0 0]];
        cMap = parula(128);
        cMap(1,:) = cMap(1,:)./3;
        cMap(end,:) = cMap(end,:)./3;
        if any(strcmp(['e' num2str(i) num2str(j)],Components))
            figure;
            imagesc(epsij)
            title(['\epsilon_',num2str(i),'_',num2str(j) ' Average Strain: ' num2str(AverageStrain)],'fontsize',14)
            shading flat
            axis equal tight
            % view(2)
            colorbar
            colormap(cMap)
            caxis([smin smax])
            
            if r == 1
                
                
            end
            
            if DoShowGB && ~strcmp(Settings.ScanType,'Hexagonal')
                if isempty(lines)% Cobbled together way to speed things up
                    lines = PlotGBs(Settings.grainID,[Settings.Nx Settings.Ny],Settings.ScanType);
                    if isfield(Settings, 'grainsHaveBeenSplit') && ...
                            Settings.grainsHaveBeenSplit
                        redlines = PlotGBs(Settings.oldGrains.grainID, [Settings.Nx Settings.Ny], Settings.ScanType,gca,1.5,'r');
                    end
                else
                    hold on
                    for ii = 1:size(lines,1)
                        plot(lines{ii,1},lines{ii,2},'LineWidth',1,'Color','k')
                    end%ii = 1:size(lines,1)
                    if isfield(Settings, 'grainsHaveBeenSplit') && ...
                            Settings.grainsHaveBeenSplit
                        for ii = 1:size(redlines,1)
                            plot(redlines{ii,1},redlines{ii,2},'LineWidth',1.5,'Color','r')
                        end%ii = 1:size(redlines,1)
                    end
                    hold off
                end
            end
        end
        
    end
end

% Plot Effective strain:

% Von Mises Equivalent strain calculated from https://dianafea.com/manuals/d944/Analys/node405.html
exx=(2*strain(1,1,:)-strain(2,2,:)-strain(3,3,:))/3;
eyy=(-strain(1,1,:)+2*strain(2,2,:)-strain(3,3,:))/3;
ezz=(-strain(1,1,:)-strain(2,2,:)+2*strain(3,3,:))/3;
strainEff=2/3*sqrt(3*(exx.^2+eyy.^2+ezz.^2)/2+3*(strain(1,2,:).^2+strain(1,3,:).^2+strain(2,3,:).^2));

if strcmp(Settings.ScanType,'Hexagonal')
    NColsOdd = c;
    NColsEven = c-1;
    NRows = r;
    count = 1;
    
    NewstrainEff = zeros(NRows,NColsEven);
    if i==1 && j==1
        gmap = zeros(NRows,NColsEven);
    end
    for rr = 1:NRows
        if bitget(abs(rr),1)~=0 %odd
            
            for cc = 1:NColsOdd
                NewstrainEff(rr,cc) = strainRff(count);
                if i==1 && j==1
                    gmap(rr,cc)=Settings.grainID(count);
                end
                count = count + 1;
            end
        else
            for cc = 1:NColsEven
                NewstrainEff(rr,cc) = strainEff(count);
                if i==1 && j==1
                    gmap(rr,cc)=Settings.grainID(count);
                end
                count = count + 1;
            end
        end
    end
    strainEff = NewstrainEff;
    
else
    strainEff=reshape(strainEff, [c r])';
    
end

if r == 1
    strainEff = repmat(strainEff,Settings.ScanLength,1);
end

strainEffvec = map2vec(strainEff);
AverageStrain = mean(strainEffvec(~BadPoints));
%cMap = [[0 0 0];parula(126);[0 0 0]];
cMap = parula(128);
cMap(1,:) = cMap(1,:)./3;
% cMap(end,:) = cMap(end,:)./3;
if any(strcmp(['e' num2str(i) num2str(j)],Components))
    figure;
    imagesc(strainEff)
    title(['Effective Strain, \epsilon_E_f_f Average Strain: ' num2str(AverageStrain),' (Black=Poor Data)'],'fontsize',14)
    shading flat
    axis equal tight
    % view(2)
    colorbar
    colormap(cMap)
    caxis([0 smax])
    
    if r == 1
        
        
    end
    
    if DoShowGB && ~strcmp(Settings.ScanType,'Hexagonal')
        if isempty(lines)% Cobbled together way to speed things up
            lines = PlotGBs(Settings.grainID,[Settings.Nx Settings.Ny],Settings.ScanType);
            if isfield(Settings, 'grainsHaveBeenSplit') && ...
                    Settings.grainsHaveBeenSplit
                redlines = PlotGBs(Settings.oldGrains.grainID, [Settings.Nx Settings.Ny], Settings.ScanType,gca,1.5,'r');
            end
        else
            hold on
            for ii = 1:size(lines,1)
                plot(lines{ii,1},lines{ii,2},'LineWidth',1,'Color','k')
            end%ii = 1:size(lines,1)
            if isfield(Settings, 'grainsHaveBeenSplit') && ...
                    Settings.grainsHaveBeenSplit
                for ii = 1:size(redlines,1)
                    plot(redlines{ii,1},redlines{ii,2},'LineWidth',1,'Color','r')
                end%ii = 1:size(redlines,1)
            end
            hold off
        end
    end
end
