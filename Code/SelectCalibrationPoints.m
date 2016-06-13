function Inds = SelectCalibrationPoints(mapsize,IQ,Angles)
%Input Option 1:
%   mapsize: [Nx Ny] array of scan sizes
%   IQ: vector of image quality. Length must equal prod(mapsize)
%   Angles: vector of euler angles. Length must equal prod(mapsize)
%Input Option 2:
%   1st Argument: Image quality map of (Ny,Nx) dimensions
%   2nd Argument: IPF map of (Ny,Nx) dimensions

    if all(size(mapsize) == [1,2])
        if nargin == 3
            Nx = mapsize(1);
            Ny = mapsize(2);
            [im,PlotType] = ChoosePlot(mapsize,IQ,Angles);
            npoints = 1;
            Inds = zeros(1);
        end
    else
        if nargin > 1
            %Ask image type
            PlotType = questdlg('Select Image to Display','Resize Scan','Image Quality','IPF','Image Quality');
            if strcmp(PlotType,'Image Quality')
                im = mapsize;
            elseif strcmp(PlotType,'IPF')
                im = IQ;
            end
            [Ny,Nx,~] = size(im);
        end
        if nargin == 3
            Inds = Angles;
            npoints = length(Inds)+1;
        else
            Inds = zeros(0);
            npoints = 1;
        end 
    end
    
    %Select Calibration Points
    morepoints = 1;
    Title = {{'{\bf Press RETURN key or right-click last point to exit}';...
        '{\fontsize{10} Click Mouse wheel or hold SHIFT to enter point by index}'},'Interpreter','tex','FontWeight','Normal'};
    
    %Set minimum number of points
    MinPoints = 1;
    if Ny == 1
        MinPoints = 1;
    end
    
    f = figure(1);
    PlotScan(im,PlotType);
    title(Title{:})
   
    if Inds ~= 0
        hold on
        [Xind,Yind] = ind2sub([size(im,2) size(im,1)],Inds);
        plot(Xind,Yind,'kd','MarkerFaceColor','k')
    else
         Xind = zeros(1); Yind = zeros(1);
    end
    
    while morepoints       
        %Gets X,Y data from user
        [x,y, button] = ginput(1);
        if x > Nx
            x = Nx;
        elseif x < 1
            x = 1;
        end
        if y > Ny
            y = Ny;
        elseif y < 1
            y = 1;
        end
        
        if ~isempty(x)
            sze = [size(im,2),size(im,1)];
            ind = sub2ind(sze,round(x),round(y));
            if button ~= 2
                [La,Lb] = ismember(ind,Inds);
                if La %De-select Point
                    Inds(Lb) = [];
                    Xind(Lb) = [];
                    Yind(Lb) = [];
                else
                    Inds(npoints) = ind;
                    Xind(npoints) = round(x);
                    Yind(npoints) = round(y);
                end
                npoints = length(Inds)+1;
            else
                answer = inputdlg('Enter Point Indices (space delimited):','Manual Point Selection',1,{num2str(ind)});
                answer = answer{1};
                ind = sscanf(answer,'%d');
                
                [La,Lb] = ismember(ind,Inds);
                Inds(unique(Lb(Lb>0)))=[]; %De-select points
                if Inds == 0
                    Inds = ind(~La);
                else
                    Inds = [Inds;ind(~La)];
                end
                [Xind,Yind] = ind2sub(sze,Inds);
                npoints = length(Inds)+1;
            end
            if button == 3 && npoints > MinPoints
                morepoints = 0;
            end
            
        elseif npoints > MinPoints %
            morepoints = 0;
        end
        
        %Plot Points
        cla
        PlotScan(im,PlotType);
        hold on
        plot(Xind,Yind,'kd','MarkerFaceColor','k')
        title(Title{:})
        axis equal tight
    end
    close(f)