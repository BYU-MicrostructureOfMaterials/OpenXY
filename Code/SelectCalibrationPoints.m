function Inds = SelectCalibrationPoints(mapsize,IQ,Angles)
%Input Option 1:
%   mapsize: [Nx Ny] array of scan sizes
%   IQ: vector of image quality. Length must equal prod(mapsize)
%   Angles: vector of euler angles. Length must equal prod(mapsize)
%Input Option 2:
%   1st Argument: Image quality map of (Ny,Nx) dimensions
%   2nd Argument: IPF map of (Ny,Nx) dimensions


    if nargin == 3
        %Set up Images to Plot
        Nx = mapsize(1);
        Ny = mapsize(2);
        ScanLength = Nx*Ny;
        g = zeros(3,3,ScanLength);
        for i = 1:ScanLength
            g(:,:,i) = euler2gmat(Angles(i,:));
        end
    
        %Ask image type
        sel = questdlg('Select Image to Display','Resize Scan','Image Quality','IPF','Image Quality');
        if strcmp(sel,'Image Quality')
            im = reshape(IQ,Nx,Ny)';
        elseif strcmp(sel,'IPF')
            im = PlotIPF(g,[Nx Ny],0);
        end
    elseif nargin == 2
        %Ask image type
        sel = questdlg('Select Image to Display','Resize Scan','Image Quality','IPF','Image Quality');
        if strcmp(sel,'Image Quality')
            im = mapsize;
        elseif strcmp(sel,'IPF')
            im = IQ;
        end
        [Ny,Nx] = size(im);
    end
    
    %Select Calibration Points
    morepoints = 1;
    npoints = 1;
    Inds = [];
    Title = 'Press RETURN key or right-click last point to exit';
    
    %Set minimum number of points
    MinPoints = 3;
    if Ny == 1
        MinPoints = 1;
    end
    
    f = figure(1);
    image(im)
    title(Title)
    Inds = zeros(1); Xind = zeros(1); Yind = zeros(1);
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
            ind = sub2ind(size(im),round(y),round(x));
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
            
            if button ~= 1 && npoints >= MinPoints
                morepoints = 0;
            end
            npoints = length(Inds)+1;
        elseif npoints > MinPoints %
            morepoints = 0;
        end
        
        %Plot Points
        cla
        image(im)
        hold on
        plot(Xind,Yind,'kd','MarkerFaceColor','k')
        title(Title)
    end
    close(f)