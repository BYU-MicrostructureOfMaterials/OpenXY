%This is a slight modification of Calvin Gardner's code ROILocatorBlack. 
%Thanks CJ!
%Jay Basinger 3/17/2011
function [roixc,roiyc]= GetROIs(I1,ROInum,pixsize,roisize,ROImethod)

%For Testing comment lines below in
% close all;
% clear all;
% I1 = ReadEBSDImage('C:\Users\Shiny\Documents\My Dropbox\HRStuff\Pattern Center\Germanium Images\Gebin2x2_r0c0.bmp');
% pixsize = size(I1,1);
% roisize = round(pixsize*.15);
% ROInum = 15;
% ROImethod = 'Grid';

switch ROImethod
    case 'Manual'
        roixc = [round(pixsize/2)];
        roiyc = [round(pixsize/2)];
    case 'Intensity'
        %initiate variables
        k=1;
        m=1;
        n=1;
        %preallocate
        roixc=zeros(1,ROInum);
        roiyc=zeros(1,ROInum);
        I2=zeros(pixsize, pixsize);
        for i=1:pixsize
            for j=1:pixsize
                if i==1 && j==1
                    I2(i,j)=n;
                elseif i==1 && j~=1
                    if I1(i,j)==I1(i,j-1)
                        I2(i,j)=I2(i,j-1);
                    else
                        n=n+1;
                        I2(i,j)=n;
                    end
                elseif i~=1 && j==1
                    if I1(i,j)==I1(i-1,j)
                        I2(i,j)=I2(i-1,j);
                    elseif I1(i,j)==I1(i-1,j+1)
                        I2(i,j)=I2(i-1,j+1);
                    else
                        n=n+1;
                        I2(i,j)=n;
                    end
                elseif i~=1 && j~=1 && j~=pixsize
                    if I1(i,j)==I1(i-1,j-1)
                        I2(i,j)=I2(i-1,j-1);
                    elseif I1(i,j)==I1(i-1,j)
                        I2(i,j)=I2(i-1,j);
                    elseif I1(i,j)==I1(i-1,j+1)
                        I2(i,j)=I2(i-1,j+1);
                    elseif I1(i,j)==I1(i,j-1)
                        I2(i,j)=I2(i,j-1);
                    else
                        n=n+1;
                        I2(i,j)=n;
                    end
                elseif i~=1 && j==pixsize
                    if I1(i,j)==I1(i-1,j-1)
                        I2(i,j)=I2(i-1,j-1);
                    elseif I1(i,j)==I1(i-1,j)
                        I2(i,j)=I2(i-1,j);
                    elseif I1(i,j)==I1(i,j-1)
                        I2(i,j)=I2(i,j-1);
                    else
                        n=n+1;
                        I2(i,j)=n;
                    end
                end
            end
        end
        I2=I2/(1000*max(max(I2)));
        
        I1=double(I1)+I2;
        I=flipud(unique(I1));
        
        while k<=ROInum
            [row,col]=find(I1==I(m));
            x=round((max(col)+min(col))/2);
            y=round((max(row)+min(row))/2);
            if (x<(ceil(roisize/2)+1))||((pixsize-x)<(ceil(roisize/2)+1))||(y<(ceil(roisize/2)+1))||((pixsize-y)<(ceil(roisize/2)+1))
                m=m+1;
            else
                for l=1:ROInum
                    if (abs(roixc(l)-x)<(pixsize/10))&&(abs(roiyc(l)-y)<(pixsize/10))
                        m=m+1;
                        break
                    elseif l==ROInum
                        roixc(k)=x;
                        roiyc(k)=y;
                        m=m+1;
                        k=k+1;
                    end
                end
            end
        end
    case 'Grid'
%{
        roixc = [round(pixsize/4)*1.5 round(pixsize/4)*2 round(pixsize/4)*2.5...
            round(pixsize/5) round(pixsize/5)*1.5 round(pixsize/5)*2 round(pixsize/5)*2.5 round(pixsize/5)*3 round(pixsize/5)*3.5 round(pixsize/5)*4.0...
            round(pixsize/5) round(pixsize/5)*1.5 round(pixsize/5)*2 round(pixsize/5)*2.5 round(pixsize/5)*3 round(pixsize/5)*3.5 round(pixsize/5)*4.0...
            round(pixsize/5) round(pixsize/5)*1.5 round(pixsize/5)*2 round(pixsize/5)*2.5 round(pixsize/5)*3 round(pixsize/5)*3.5 round(pixsize/5)*4.0...
            round(pixsize/5) round(pixsize/5)*1.5 round(pixsize/5)*2 round(pixsize/5)*2.5 round(pixsize/5)*3 round(pixsize/5)*3.5 round(pixsize/5)*4.0...
            round(pixsize/5) round(pixsize/5)*1.5 round(pixsize/5)*2 round(pixsize/5)*2.5 round(pixsize/5)*3 round(pixsize/5)*3.5 round(pixsize/5)*4.0...
            round(pixsize/5) round(pixsize/5)*1.5 round(pixsize/5)*2 round(pixsize/5)*2.5 round(pixsize/5)*3 round(pixsize/5)*3.5 round(pixsize/5)*4.0...
            round(pixsize/3) round(pixsize/3)*1.5 round(pixsize/3)*2];
        roiyc = [round(pixsize/5) round(pixsize/5) round(pixsize/5)...
            round(pixsize/6)*2 round(pixsize/6)*2 round(pixsize/6)*2 round(pixsize/6)*2 round(pixsize/6)*2 round(pixsize/6)*2 round(pixsize/6)*2.0...
            round(pixsize/6)*2.5 round(pixsize/6)*2.5 round(pixsize/6)*2.5 round(pixsize/6)*2.5 round(pixsize/6)*2.5 round(pixsize/6)*2.5 round(pixsize/6)*2.5...
            round(pixsize/6)*3 round(pixsize/6)*3 round(pixsize/6)*3 round(pixsize/6)*3 round(pixsize/6)*3 round(pixsize/6)*3 round(pixsize/6)*3.0...
            round(pixsize/6)*3.5 round(pixsize/6)*3.5 round(pixsize/6)*3.5 round(pixsize/6)*3.5 round(pixsize/6)*3.5 round(pixsize/6)*3.5 round(pixsize/6)*3.5...
            round(pixsize/6)*4 round(pixsize/6)*4 round(pixsize/6)*4 round(pixsize/6)*4 round(pixsize/6)*4 round(pixsize/6)*4 round(pixsize/6)*4.0...
            round(pixsize/6)*4.5 round(pixsize/6)*4.5 round(pixsize/6)*4.5 round(pixsize/6)*4.5 round(pixsize/6)*4.5 round(pixsize/6)*4.5 round(pixsize/6)*4.5...
            round(pixsize/6)*5 round(pixsize/6)*5 round(pixsize/6)*5];
%}
        edgeCount = round(sqrt(ROInum));
        edgeSpacing = round(roisize/2 + (0.1)*pixsize);
        edgePoints = linspace(edgeSpacing,pixsize - edgeSpacing,edgeCount);
        
        [roixc,roiyc] = meshgrid(edgePoints);
        roixc = roixc(:)';
        roiyc = roiyc(:)';

% bottom row removed
% roixc = [round(pixsize/4)*1.5 round(pixsize/4)*2 round(pixsize/4)*2.5...
%     round(pixsize/5) round(pixsize/5)*1.5 round(pixsize/5)*2 round(pixsize/5)*2.5 round(pixsize/5)*3 round(pixsize/5)*3.5 round(pixsize/5)*4.0...
%     round(pixsize/5) round(pixsize/5)*1.5 round(pixsize/5)*2 round(pixsize/5)*2.5 round(pixsize/5)*3 round(pixsize/5)*3.5 round(pixsize/5)*4.0...
%     round(pixsize/5) round(pixsize/5)*1.5 round(pixsize/5)*2 round(pixsize/5)*2.5 round(pixsize/5)*3 round(pixsize/5)*3.5 round(pixsize/5)*4.0...
%     round(pixsize/5) round(pixsize/5)*1.5 round(pixsize/5)*2 round(pixsize/5)*2.5 round(pixsize/5)*3 round(pixsize/5)*3.5 round(pixsize/5)*4.0...
%     round(pixsize/5) round(pixsize/5)*1.5 round(pixsize/5)*2 round(pixsize/5)*2.5 round(pixsize/5)*3 round(pixsize/5)*3.5 round(pixsize/5)*4.0...
%     round(pixsize/5) round(pixsize/5)*1.5 round(pixsize/5)*2 round(pixsize/5)*2.5 round(pixsize/5)*3 round(pixsize/5)*3.5 round(pixsize/5)*4.0];
% roiyc = [round(pixsize/5) round(pixsize/5) round(pixsize/5)...
%     round(pixsize/6)*2 round(pixsize/6)*2 round(pixsize/6)*2 round(pixsize/6)*2 round(pixsize/6)*2 round(pixsize/6)*2 round(pixsize/6)*2.0...
%     round(pixsize/6)*2.5 round(pixsize/6)*2.5 round(pixsize/6)*2.5 round(pixsize/6)*2.5 round(pixsize/6)*2.5 round(pixsize/6)*2.5 round(pixsize/6)*2.5...
%     round(pixsize/6)*3 round(pixsize/6)*3 round(pixsize/6)*3 round(pixsize/6)*3 round(pixsize/6)*3 round(pixsize/6)*3 round(pixsize/6)*3.0...
%     round(pixsize/6)*3.5 round(pixsize/6)*3.5 round(pixsize/6)*3.5 round(pixsize/6)*3.5 round(pixsize/6)*3.5 round(pixsize/6)*3.5 round(pixsize/6)*3.5...
%     round(pixsize/6)*4 round(pixsize/6)*4 round(pixsize/6)*4 round(pixsize/6)*4 round(pixsize/6)*4 round(pixsize/6)*4 round(pixsize/6)*4.0...
%     round(pixsize/6)*4.5 round(pixsize/6)*4.5 round(pixsize/6)*4.5 round(pixsize/6)*4.5 round(pixsize/6)*4.5 round(pixsize/6)*4.5 round(pixsize/6)*4.5];

    case 'Radial'
        roixc=zeros(1,ROInum);
        roiyc=zeros(1,ROInum);
        roixc(1) = round(pixsize/2);
        roiyc(1) = round(pixsize/2);
        row1num = ceil((ROInum-1)/3);
        row2num = ROInum-1-row1num;
        rad2 = floor((pixsize-2-roisize)/2.5);
        rad1 = round(rad2/2);
        ang1 = 2*pi/row1num;
        ang2 = 2*pi/row2num;
        
        for i = 1:row1num
            dx = rad1*cos((i-1)*ang1);
            dy = rad1*sin((i-1)*ang1);
            roixc(i+1)=roixc(1)+dx;
            roiyc(i+1)=roiyc(1)+dy;
        end
        for i = 1:row2num
            dx = rad2*cos((i-1)*ang2);
            dy = rad2*sin((i-1)*ang2);
            roixc(i+1+row1num)=roixc(1)+dx;
            roiyc(i+1+row1num)=roiyc(1)+dy;
        end
    case 'Annular'
        roixc=zeros(1,ROInum);
        roiyc=zeros(1,ROInum);
        roixc(1) = round(pixsize/2);
        roiyc(1) = round(pixsize/2);
        angSpacing = 2*pi / (ROInum - 1);
        radius = floor((pixsize-0-roisize)/3);
        for i = 1:ROInum-1
            dx = radius*cos((i-1)*angSpacing);
            dy = radius*sin((i-1)*angSpacing);
            roixc(i+1)= roixc(1)+dx;
            roiyc(i+1)= roixc(1)+dy;
        end        
end


% figure; imagesc(I1); colormap gray
% for ii = 1:length(roixc)
%    
% %     DrawROI(roixc(ii),roiyc(ii),roisize)
%     hold on
%     rectangle('Curvature',[0 0],'Position',...
%         [roixc(ii)-roisize/2 roiyc(ii)-roisize/2 roisize roisize],...
%         'EdgeColor','g');
% end
% axis equal