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
Angles=cell2mat(data.g);
n=length(Angles)/3;
angles=zeros(n,3);
n=[1:n];
for i=1:3
    angles(:,i)=Angles((n-1)*3+i)';
end
if DoShowGB && ~strcmp(Settings.ScanType,'Hexagonal')
    % parameters for grain finding algorithm
    clean=1;    %set to 1 to clean up small grains
    small=5;   % set to size of minimum grain size (pixels) for cleanup
    mistol=MaxMisorientation*pi/180;   % maximum misorientation within a grain
    % rotate Fs into sample frame, in order to take derivatives in the sample
    % frame  *****can probably vectorize this using Tony Fast's stuff *****
    % HROIM angles for grain boundary calc
    
    anglestemp = reshape(angles,[r,c,3]);
    Material = ReadMaterial(Settings.Material);
    [grains grainsize sizes BOUND]=findgrains(anglestemp, Material.lattice, clean, small, mistol);
    % BOUND=flipud(fliplr(BOUND));
    
    x=[1:r];
    y=[1:c];
    [X Y]=meshgrid(x,y);
    X=X';
    Y=Y';
end
% Strain plots ************************

%Ignore obviously bad points
Bob = Settings.SSE;
Bill = cell2mat(Bob);
Gob = 1:length(Bill);
stuff = Gob(Bill > (mean(Bill) + std(Bill)));
for j = 1:length(stuff) data.F{stuff(j)} = eye(3); end

FList = [data.F{:}];
FArray=reshape(FList,[3,3,length(FList(1,:))/3]);

thisF=zeros(3,3);
FSample=FArray;
U = zeros(size(FArray));
for i=1:length(FArray(1,1,:))
    g=euler2gmat(angles(i,1),angles(i,2),angles(i,3));% this give g(sample to crystal)
    thisF(:,:)=FArray(:,:,i);
    [R U(1:3,1:3,i)]=poldec(thisF);
    FSample(:,:,i)=g'*thisF*g; %check this is crystal to sample
end
FSampleTransp=permute(FSample,[2,1,3]); % sample frame
strain=(FSample+FSampleTransp)/2;
%%
% strain = U;
% FArrayTransp=permute(FArray,[2,1,3]); % crystal frame
% strain=(FArray+FArrayTransp)/2;
strain(1,1,:)=strain(1,1,:)-1;
strain(2,2,:)=strain(2,2,:)-1;
strain(3,3,:)=strain(3,3,:)-1;

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
        
        AverageStrain = mean(epsij(:));
        if any(strcmp(['e' num2str(i) num2str(j)],Components))
            figure;
            imagesc(epsij)
            title(['\epsilon_',num2str(i),'_',num2str(j) ' Average Strain: ' num2str(AverageStrain)],'fontsize',14)
            shading flat
            axis equal tight
            % view(2)
            colorbar
            caxis([smin smax])
            
            if r == 1
               
               
            end
            
            if DoShowGB && ~strcmp(Settings.ScanType,'Hexagonal')
                h=gcf;set(h,'Position',[50 50 750 750])
                hold on
                plot(Y(BOUND==1),X(BOUND==1),'k.','MarkerSize',5); % subtract 1/2 from Y and X if you want the middle of the band
                axis equal
                axis off
                shading interp
            end
        end
        
    end
end


