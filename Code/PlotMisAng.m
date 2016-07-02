function [MaxMisAng,MisAng] = PlotMisAng(g,dims)
top = 1:dims(1);
bottom = prod(dims)-dims(1)+1:prod(dims);
left = 1:dims(1):prod(dims);
right = dims(1):dims(1):prod(dims);
MaxMisAng = zeros(prod(dims),1);
MisAng = zeros(prod(dims),4);
for i = 1:prod(dims)
    if ismember(i,top)
        t = i;
    else
        t = i-dims(1);
    end
    if ismember(i,bottom)
        b = i;
    else
        b = i+dims(1);
    end
    if ismember(i,left)
        l = i;
    else
        l = i-1;
    end
    if ismember(i,right)
        r = i;
    else
        r = i+1;
    end
    MisAng(i,1) = GeneralMisoCalc(g(:,:,i),g(:,:,r),'tetragonal');
    MisAng(i,2) = GeneralMisoCalc(g(:,:,i),g(:,:,b),'tetragonal');
    MisAng(i,3) = GeneralMisoCalc(g(:,:,i),g(:,:,l),'tetragonal');
    MisAng(i,4) = GeneralMisoCalc(g(:,:,i),g(:,:,t),'tetragonal');
    MaxMisAng(i) = max(MisAng(i,:));
end
map = reshape(MaxMisAng,dims(1),dims(2));
mapr = reshape(MisAng(:,1),dims(1),dims(2));
mapb = reshape(MisAng(:,2),dims(1),dims(2));
mapl = reshape(MisAng(:,3),dims(1),dims(2));
mapt = reshape(MisAng(:,4),dims(1),dims(2));
figure
subplot(3,3,2)
image(mapl)
subplot(3,3,4)
image(mapt)
subplot(3,3,5)
image(map)
subplot(3,3,6)
image(mapb)
subplot(3,3,8)
image(mapr)