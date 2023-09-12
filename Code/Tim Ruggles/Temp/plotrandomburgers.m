bb=zeros(3,1000);
ster=zeros(1000,2);
for i=1:1000
    bb(:,i)=rand(3,1);
    normbb(i)=norm(squeeze(bb(:,i)));
    temp=StereoDir(squeeze(g(:,:,round(rand*m),round(rand*n))),symops,squeeze(bb(:,i))/normbb(i));
ster(i,:)=temp(1:2)/(1+temp(3));
end
figure
densityplot(ster(:,1),ster(:,2),'nbins',[50,50]);
