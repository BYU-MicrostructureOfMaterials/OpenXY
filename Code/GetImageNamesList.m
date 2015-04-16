function [ImageNamesList IsNewOIMNaming] = GetImageNamesList(ScanFormat, ScanLength, Dimensions, FirstImagePath, XStep, YStep)
%GETIMAGENAMESLIST
%ImageNamesList = GetImageNamesList(ScanFormat, ScanLength, Dimensions, FirstImagePath, XStep, YStep)
%Returns a list of image names belonging to a scan, given the scan format,
%length, dimensions, and the path of the first image. XStep and YStep are
%currently not used, but may be in the future.
%Jay Basinger 5/10/2011

%Read EBSD images
%Determine the number of characters in the file extension
[path, ImageName, ext] = fileparts(FirstImagePath);
DotPosition = find(FirstImagePath=='.');
if length(DotPosition) > 1
    DotPosition = DotPosition(length(DotPosition));
end

DistFromEnd = length(FirstImagePath) - DotPosition;
if DistFromEnd ~= 3 && DistFromEnd ~= 4
    error('Had trouble reading in the file names')
end

switch ScanFormat
    
    case 'L'
        % The 'L' points are labeled as shown:
        %   a
        %   b c
        % They also generally correspond to the image names as follows: a =
        % 0001c1 , b = 0001c2, c = 0001c3
        
        NumSmallGridPoints = 3; %makes the L

        %total number of larger-step-size grid points
        NumGridPoints = ScanLength/NumSmallGridPoints; 

        if rem(NumGridPoints,1) ~= 0;
            warndlg('Missing a scan point','Warning - GetImageNamesList.m')
        end

        ImageNamesList = cell([NumGridPoints,NumSmallGridPoints]);
        if NumGridPoints > 100000
            errordlg('your scan is way too big','Error - GetImageNamesList.m','modal')
            return;
        end
    
        %don't bother putting it in a grid, just make an n by 3 list where
        %n = NumGridPoints
        for i = 1:NumGridPoints
            for j = 1:NumSmallGridPoints
                ImageNamesList{i,j} = ...
                    [FirstImagePath(1:end-DistFromEnd-9) '_' sprintf('%05.0f',i) 'c' num2str(j) FirstImagePath(end-DistFromEnd:end)];
            end
        end
    
    case 'Square'
        NumColumns = Dimensions(1);
        NumRows = Dimensions(2);

        %Check to see if we have a new OIM naming scheme starting somewhere around OIM 6.2 or greater
        IsNewOIMNaming = 1;
        IsLineScan = 0;
        NameParts = textscan(ImageName,'%s');
        NameParts = NameParts{1};
        
        %Looks for pairs of x,y or r,c that have numbers after them
        for i = 1:length(NameParts)
            Xinds = strfind(NameParts{i},'x');
            Yinds = strfind(NameParts{i},'y');
            Rinds = strfind(NameParts{i},'r');
            Cinds = strfind(NameParts{i},'c');
            if (~isempty(Xinds) && ~isempty(Yinds))
                if (isstrprop(NameParts{i}(Xinds+1),'digit') && isstrprop(NameParts{i}(Yinds+1),'digit'))
                    break;
                end
            elseif (~isempty(Rinds) && ~isempty(Cinds))
                if (isstrprop(NameParts{i}(Rinds+1),'digit') && isstrprop(NameParts{i}(Cinds+1),'digit'))
                    Xinds = Rinds;
                    Yinds = Cinds;
                    break;
                end
            end
        end
        Xinds = Xinds(end); Yinds = Yinds(end);
        PositionPart = NameParts{i};
        
        %Break up the Position string around the position numbers
        preStr = '';
        for ii = 1:i-1
            preStr = [preStr NameParts{ii} ' '];
        end
        preStr = [preStr(1:end-1) PositionPart(1:Xinds)];
        i = Xinds + 1;
        while isstrprop(PositionPart(i),'digit') || strcmp(PositionPart(i),'.')
            i = i + 1;
        end
        midStr = PositionPart(i:Yinds);
        i = Yinds + 1;
        while isstrprop(PositionPart(i),'digit') || strcmp(PositionPart(i),'.')
            i = i + 1;
            if i > length(PositionPart), break; end;
        end
        endStr = PositionPart(i:end);

        for i = 1:ScanLength
            %X(i) = mod(i,NumColumns)*XStep;
            %Y(i) = floor(i/NumColumns)*YStep;
        end
        if isempty(Rinds) 
            Rinds = 0;
        end
        if isempty(Xinds) || isempty(Yinds) 
            IsNewOIMNaming = 0;
        else
            Xinds = Xinds(end);
            Yinds = Yinds(end);
            Rinds = Rinds(end);
           if length(FirstImagePath) - Xinds(end)  > 20 || length(FirstImagePath) - Yinds(end)  > 20 || Rinds > max(Xinds,Yinds)
               IsNewOIMNaming = 0;
           end
        end
        if isempty(Xinds) && isempty(Yinds) && isempty(Rinds)
            IsLineScan = 1;
        end

        ImageNamesList = cell([ScanLength/NumColumns,NumColumns]);

        if IsNewOIMNaming
            spos=max(strfind(FirstImagePath,'\'));
            d=dir(FirstImagePath(1:spos-1));
            IMnames={d.name};
            UseList=[];
            for i=1:length(IMnames)
                if length(IMnames{i})>7
                    if strcmp(IMnames{i}(end-3:end),FirstImagePath(end-3:end))
                        UseList=[UseList,i];
                    end
                end
            end
            IMnames=IMnames(UseList);

            curI=IMnames{1};
            xpos=max(strfind(curI,'x'));

            for i=1:length(IMnames)
                curI=IMnames{i};

                ypos=max(strfind(curI,'y'));
                yvals(i)=str2double(curI(ypos+1:end-4));
                xvals(i)=str2double(curI(xpos+1:ypos-1));
            end

            xvals=sort(unique(xvals));
            yvals=sort(unique(yvals));

    %         XStep = xvals(2);
    %         YStep = XStep;
    %         disp(['Image increment: ',num2str(YStep)])
    %         
    %         for x = 0:NumColumns-1
    %             for y = 0:NumRows-1
    %                 ImageNamesList{y+1,x+1} = [FirstImagePath(1:Xinds(end)) num2str(x*XStep) 'y' num2str(y*YStep) FirstImagePath(end-DistFromEnd:end)];
    %             end
    %         end

            XStep = xvals(3)/2;
            YStep = XStep;
            disp(['Image increment: ',num2str(YStep)])

            for x = 0:NumColumns-1
                for y = 0:NumRows-1
                    ImageNamesList{y+1,x+1} = [FirstImagePath(1:Xinds(end)) num2str(floor(x*XStep)) 'y' num2str(y*YStep) FirstImagePath(end-DistFromEnd:end)];
                end
            end
        else

            for r = 1:NumRows
                for c = 1:NumColumns
                    ImageNamesList{r,c} = [FirstImagePath(1:end-DistFromEnd-4) num2str(r-1) 'c' num2str(c-1) FirstImagePath(end-DistFromEnd:end)];
                end
            end

        end

    case 'Hexagonal'
        
        NColsOdd = ceil(Dimensions(1)/2);
        NColsEven = floor(Dimensions(1)/2);
        NRows = Dimensions(2);
        
        IsNewOIMNaming = 1;
        Xinds = strfind(FirstImagePath,'x');
        Yinds = strfind(FirstImagePath,'y');
        Rinds = strfind(FirstImagePath,'r');

        
        if isempty(Rinds) 
            Rinds = 0;
        end
        if isempty(Xinds) || isempty(Yinds) 
            IsNewOIMNaming = 0;
        else
            Xinds = Xinds(end);
            Yinds = Yinds(end);
            Rinds = Rinds(end);
           if length(FirstImagePath) - Xinds(end)  > 20 || length(FirstImagePath) - Yinds(end)  > 20 || Rinds > max(Xinds,Yinds)
               IsNewOIMNaming = 0;
           end

        end
        
        count = 1;
        if IsNewOIMNaming
            spos=max(strfind(FirstImagePath,'\'));
            d=dir(FirstImagePath(1:spos-1));
            IMnames={d.name};
            UseList=[];
            for i=1:length(IMnames)
                if length(IMnames{i})>7
                    if strcmp(IMnames{i}(end-3:end),FirstImagePath(end-3:end))
                        UseList=[UseList,i];
                    end
                end
            end
            IMnames=IMnames(UseList);
            
            curI=IMnames{1};
            xpos=max(strfind(curI,'x'));
            
            for i=1:length(IMnames)
                curI=IMnames{i};
                
                ypos=max(strfind(curI,'y'));
                yvals(i)=str2double(curI(ypos+1:end-4));
                xvals(i)=str2double(curI(xpos+1:ypos-1));
            end
            
            xvals=sort(unique(xvals));
            XvalsOdd=xvals(1:2:Dimensions(1));
            XvalsEven=xvals(2:2:Dimensions(1));
            yvals=sort(unique(yvals));
            
            %Check if NColsEven and Odd are correct, reverse if not 
            %(Needs to be tested)
            if exist([FirstImagePath(1:Xinds) num2str(XvalsOdd(NColsOdd)) 'y' num2str(yvals(0)) FirstImagePath(end-DistFromEnd:end)],'file');
                disp('Reversing Number of Odd and Even Columns...');
                NColsEven = NColsOdd;
                NColsOdd = NColsEven - 1;
            end
            for r = 1:NRows
                if bitget(abs(r),1)~=0 %odd
                    for c = 1:NColsOdd
                        ImageNamesList{count} = ...
                            [FirstImagePath(1:Xinds) num2str(XvalsOdd(c)) 'y' num2str(yvals(r)) FirstImagePath(end-DistFromEnd:end)];
                        count = count + 1;
                    end
                else
                    for c = 1:NColsEven
                        ImageNamesList{count} = ...
                            [FirstImagePath(1:Xinds) num2str(XvalsEven(c)) 'y' num2str(yvals(r)) FirstImagePath(end-DistFromEnd:end)];
                        count = count + 1;
                    end
                end
            end
            
        else
            %Check if NColsEven and Odd are correct, reverse if not
            if exist([FirstImagePath(1:end-DistFromEnd-4) num2str(0) 'c' num2str(NColsOdd-1) FirstImagePath(end-DistFromEnd:end)],'file');
                disp('Reversing Number of Odd and Even Columns...');
                NColsEven = NColsOdd;
                NColsOdd = NColsEven - 1;
            end
            for r = 0:NRows-1
                if bitget(abs(r),1)~=0 %odd
                    for c = 0:NColsOdd - 1
                        ImageNamesList{count} = ...
                            [FirstImagePath(1:end-DistFromEnd-4) num2str(r) 'c' num2str(c) FirstImagePath(end-DistFromEnd:end)];
                        count = count + 1;
                    end
                else
                    for c = 0:NColsEven - 1
                        ImageNamesList{count} = ...
                            [FirstImagePath(1:end-DistFromEnd-4) num2str(r) 'c' num2str(c) FirstImagePath(end-DistFromEnd:end)];
                        count = count + 1;
                    end
                end
            end
            
        end
        
        
    otherwise 
    
    errordlg('Scan Format/Type does not exist in GetImageNamesListList','Error','modal');
    
end