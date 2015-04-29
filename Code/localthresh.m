% Local thresholding for Nate's images
% DTF 1 march 2010
% image of interest is I
% put mirror image copies of original image around edge to improve the
% edges?
function  BW=localthresh(FileName)
if ischar(FileName)
    I=imread(FileName);
else
    I=FileName; % allow to pass in image itself
end

[a b c]=size(I);
if c>1
G=single(rgb2gray(I));
else
    G=single(I);
end

% you can adjust these parameters:
localsize=30;  % size of local threshold window was 100
tol=.995;    % threshold for being white above local average was .97
tol=1.0;
cutsize=0; % size of specs on the image to cut out was 10

[x y] = size(G);
flipudG=flipud(G); % probably don't need to bother with making G bigger for EBSPs since we don't use the edges anyway
fliplrG=fliplr(G);
flipudfliplrG=flipud(fliplrG);
ads=ceil(localsize/2);
bigG=[flipudfliplrG(x-ads+1:x,y-ads+1:y) flipudG(x-ads+1:x,:) flipudfliplrG(x-ads+1:x,1:ads); fliplrG(:,y-ads+1:y) G fliplrG(:,1:ads); flipudfliplrG(1:ads,y-ads+1:y) flipudG(1:ads,:) flipudfliplrG(1:ads,1:ads)];
[bigx bigy] = size(bigG);
convmat=zeros(bigx,bigy);
convmat(1:localsize,1:localsize)=1;
convmat=circshift(convmat,round([-localsize/2,-localsize/2]));
locave=ifftn(conj(fftn(convmat)).*fftn(bigG))/(localsize^2);
locSD=ifftn(conj(fftn(convmat)).*fftn(bigG.*bigG))/(localsize^2); % to find local SD
locSD=sqrt(locave.^2-locSD);
locave=locave(ads+1:ads+x,ads+1:ads+y);
locSD=locSD(ads+1:ads+x,ads+1:ads+y);
% old method of scaling for contrast:***************should optimize these parameters somehow - perhaps using the band contrast thing OIM uses?
% BW=G;
% BW(G>locave*tol)=(BW(G>locave*tol)).^1.5; % note that this is only good for 0-255 greyscale; for 0 to1 you need a different power
% new method:6/20/12***************

BW=G;
BW((G<locave-.5*locSD))=(BW((G<locave-.5*locSD))).^0.7;
BW((G>locave-.5*locSD)&(G<locave))=(BW((G>locave-.5*locSD)&(G<locave))).^.9;
% BW(G>=locave)=(BW(G>=locave)).^1.5; 
BW((G>=locave)&(G<locave+.5*locSD))=(BW((G>=locave)&(G<locave+.5*locSD))).^1.3;
BW((G>locave+.5*locSD))=(BW((G>locave+.5*locSD))).^1.5;
% [BW grainsize perimsize Mx My]=cutgrains(BW,cutsize); % cutgrains.m uses circshift, cutgrains2.m uses ffts - cutgrains is faster
% figure
% imshow(BW/max(max(BW)))

BW = CropSquare(BW); %Added by Brian Jackson 4/29/2015

return
figure
hist(grainsize,50);
title('Histogram of Cluster Sizes')
ylabel('Number of Clusters with this Area')
xlabel('Area of Cluster')
% now run your chomp file on 1-BW

grainperim=grainsize./perimsize;
figure
hist(grainperim)
title('Histogram of grain size to perimeter size ratio')

meangrainsize=mean(grainsize)

meansizeperim=mean(grainsize./perimsize)

meandist=near_neighbour(Mx,My)
runchomp(1-BW);

[nf2sum2 normalized]=nondirectf2_dtf(1-BW,1,1);
figure
hold on
plot(normalized,'r')
title('Two Point Auto-correlations')
ylabel('Non-Directional f2')
xlabel('Radius')
tic
n=min(x,y);
k1=ones(2,2);
[r1,r2]=shape_entropy(1-BW(1:n,1:n),k1,0);
r1
toc