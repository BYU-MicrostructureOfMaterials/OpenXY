%clean up noise in OIM picture
%merges grains of size<small into neighbouring grains
% DTF 4/1/2010

function [goodgrains,goodgrainsize] = cleanup(grains,grainsize,small)
goodgrains=grains;
goodgrainsize=grainsize;
N=length(grainsize);
dummy=0;
[nx,ny]=size(grains);
x=1:nx;
y=1:ny;
[X,Y]=meshgrid(x,y);
X=X';
Y=Y';

% Set up edge detection to prevent wrap-around grains
top = false(nx,ny);
top(1,:) = true;
bottom = false(nx,ny);
bottom(end,:) = true;
left = false(nx,ny);
left(:,1) = true;
right = false(nx,ny);
right(:,end) = true;

% set up convolution mask if convolution is used
convim=zeros(nx,ny);
convim(1:3,1:3)=1;
convim=circshift(convim,[-1,-1]);
h=waitbar(0, 'Cleaning up Small Grains');
for i=1:N
    if goodgrainsize(i)<small && goodgrainsize(i)>0
        if i>dummy
            waitbar(i/N);
            dummy=dummy+N/20;
        end
        thisgrain=(goodgrains==i); % pick out the current small grain
        % now find all neighbouring points about this grain (including
        % diagonals)
        if goodgrainsize(i)==1
            x=X(thisgrain==1);
            y=Y(thisgrain==1);
            edge=circshift(convim,[x-1,y-1])-thisgrain;
        else
            % use convolution to do this (dilate by 1, and then
            % subtract grain) - this is slower than circshift
%             edge=real(ifftn(conj(fftn(convim)).*fftn(thisgrain)))/9;
%             edge=(edge>0.01);
%             edge=edge-thisgrain;
%             edgenums=goodgrains(edge>0.01);
            %alternative method:
            edge=-8*thisgrain+circshift(thisgrain,[-1,1])+circshift(thisgrain,[0,1])+circshift(thisgrain,[1,1])...
                +circshift(thisgrain,[-1,-1])+circshift(thisgrain,[0,-1])+circshift(thisgrain,[1,-1])...
                +circshift(thisgrain,[-1,0])+circshift(thisgrain,[1,0]);
            edge=(edge>0);
        end
        
        % Filter the edge to prevent wrap-around
        if any(any(thisgrain & top))
            edge = edge & ~bottom;
        end
        if any(any(thisgrain & bottom))
            edge = edge & ~top;
        end
        if any(any(thisgrain & left))
            edge = edge & ~right;
        end
        if any(any(thisgrain & right))
            edge = edge & ~left;
        end

        
        edgenums=goodgrains(edge==1);
        [maxnum,maxfreq]=mode(edgenums);    % find the neighbouring grain that most often touches the current grain
        edgenums=edgenums(edgenums~=maxnum);    %find the second most frequent number
        [maxnum2,maxfreq2]=mode(edgenums);
        if maxfreq2==maxfreq % if there are two neighbouring grains of the same frequency...
            temp=[maxnum maxnum2];
            [dummy,ind]=max([goodgrainsize(maxnum),goodgrainsize(maxnum2)]); % choose the largest neighbour to absorb this grain
            newmaxnum=temp(ind);
        else
            newmaxnum=maxnum;
        end
        goodgrains(goodgrains==i)=newmaxnum;
        goodgrainsize(newmaxnum) = goodgrainsize(newmaxnum) + goodgrainsize(i);
        goodgrainsize(i)=0;
    end
end
close(h);
