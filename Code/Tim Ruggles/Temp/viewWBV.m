% WBV of Landon Ta Polycrystal data
% first load AnalysisParams_1830_4_April_2018.mat
normb=3.3026e-10; % Burger's vector size for Ta
n = Settings.data.cols;
m = Settings.data.rows;

alpha=alpha_data.alpha_filt;

a13=alpha(1,3,:)*normb;
a13=reshape(a13,[n,m])';
a23=alpha(2,3,:)*normb;
a23=reshape(a23,[n,m])';
a33=alpha(3,3,:)*normb;
a33=reshape(a33,[n,m])';

% put all WBVs in the same hemisphere
a13(a33<0)=-a13(a33<0);
a23(a33<0)=-a23(a33<0);
a33(a33<0)=-a33(a33<0);


a3=alpha_data.alpha_total3;
r = Settings.data.rows;%
c = Settings.data.cols;%
a3=reshape(a3,c,r)';
figure
imagesc((log10(a3)))
% pcolor(flipud(log10(a3))) %flipud puts it in the same orientation as OIM standard plots
shading flat
hold on
%figure % plot WBV components in x,y

% code to cut out smaller WBVs
dontplotsmall=1;
    a13plot=a13;
    a23plot=a23;

if dontplotsmall==1
    wbvsize=sqrt(a13.^2+a23.^2); % size of WBV in x-y frame
    stdwbv=std(wbvsize(:)); % standard deviation of WBV in x-y frame
    meanwbv=mean(wbvsize(:)); % mean
    cutoff=2*meanwbv;%-2*stdwbv; % cutoff size for smaller WBVs - you can change this to a different cutoff value
    a13plot(wbvsize<cutoff)=0;
    a23plot(wbvsize<cutoff)=0;
        a13plot(wbvsize>5*cutoff)=0; %get rid of large values too
    a23plot(wbvsize>5*cutoff)=0;
end

quiver((a13plot),(a23plot),10)
% quiver(flipud(a13plot),-flipud(a23plot),10) % flipud and swap y dimension to negative to get in the same orientation as standard OIM plots
% return
% Now try and map the WBV into the sterographic triangle in order to find
% out the density distribution
% a13=reshape(a13',[1,n*m]);
% a23=reshape(a23',[1,n*m]);
% a33=reshape(a33',[1,n*m]);
a13=alpha(1,3,:)*normb;
a23=alpha(2,3,:)*normb;
a33=alpha(3,3,:)*normb;

% put all WBVs in the same hemisphere
a13(a33<0)=-a13(a33<0);
a23(a33<0)=-a23(a33<0);
a33(a33<0)=-a33(a33<0);

cd('/Users/fullwood/Documents/GitHub/OpenXY/Code/')
symops=permute(gensymops, [2, 3, 1]); % I would not need to permute these if I removed the permute in StereoDir.m for the symops
cd('/Users/fullwood/Dropbox/SyncFolder/Current Students/Grads/Landon Hansen/Polycrystal Paper/ViewData/')
% get the direction (in the crystal frame) that is in the correct FZ of the
% sphere
SD=zeros(n*m,3);
f=waitbar(0,'working');
for i=1:n*m
    if round(i/10000)==i/10000
    waitbar(i/n/m,f)
    end
    if norm([a13(i),a23(i),a33(i)])>3000 % only look at the larger WBVs
        temp=StereoDir(euler2gmat(Settings.Angles(i,1),Settings.Angles(i,2),Settings.Angles(i,3)),symops,[a23(i),a13(i),-a33(i)]/norm([a23(i),a13(i),-a33(i)])); % but wbv in Euler frame by flipping x,y
        % note: alpha is in the sample frame - but the Euler system sample
        % frame. I think StereoDir (from IPF_Calc) expects the sample
        % direction to be in the microscope (xData, yData) frame? (hence it
        % rearranges the x/y in the euler space?????? not sure
        SD(i,:)=temp(:)/norm(temp);
    end
end
close(f)

%stereographic projections
SDSP=zeros(length(SD(:,1)),2);
SDSP(:,1)=SD(:,1)./(1+SD(:,3));
SDSP(:,2)=SD(:,2)./(1+SD(:,3));

SS=[SDSP(SDSP(:,1)>1e-4,1),SDSP(SDSP(:,1)>1e-4,2)];

% figure
% plot(SDSP(:,1),SDSP(:,2),'.')

% find local density
densityplot(SS(:,1),SS(:,2),'nbins',[50,50]);