function suckitblue = alphacompplot( alphafield, cmax, cmin )
suckitblue  = 0;


figure
count = 0;
for i=1:3
    for j=1:3
%         figure
%         imagesc(shiftdim(alphafield(i,j,:,:)),[cmin cmax])
%         title(['Alpha',num2str(i),num2str(j)])
%         axis off
        count = count+1;
        subplot(3,3,count),imagesc(shiftdim(alphafield(i,j,:,:)),[cmin cmax])
        axis off
    end
end

end

