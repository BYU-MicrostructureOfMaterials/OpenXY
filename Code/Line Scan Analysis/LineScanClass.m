classdef LineScanClass < handle
    properties
        Folder
        Filename
        Length
        Strain
        Settings
        SecInds
        Sections
        NumSections
        
        StrainStdDev
        TetStdDev
        SSE
        IterData
    end
    methods
        function obj = LineScanClass(Folder,Filename)
        %Constructor
            if nargin == 0
                [Filename,Folder] = uigetfile('*.mat','Select an Analysis Params file');
            elseif nargin == 1
                [Folder,Filename,ext] = fileparts(Folder);
                Filename = [Filename, ext];
            end
            if exist(fullfile(Folder,Filename),'file')
                obj.Folder = Folder;
                obj.Filename = Filename;
            end
        end
        function ReadScan(obj)
        %Loads the Settings file and calculates the strain
            tempf = load(fullfile(obj.Folder,obj.Filename));
            if isfield(tempf,'Settings') && isfield(tempf.Settings,'data')
                obj.Settings = tempf.Settings;
                obj.Length = obj.Settings.ScanLength;
                obj.CalcStrain;
            end
            clear('tempf');
        end
        function CalcStrain(obj)
        %Extracts the strain components from the F-matrix
            if ~isempty(obj.Settings)
                u11 = zeros(obj.Settings.ScanLength,1);
                u22 = zeros(obj.Settings.ScanLength,1);
                u33 = zeros(obj.Settings.ScanLength,1);
                for i=1:obj.Settings.ScanLength
                    tempF(:,:)=obj.Settings.data.F{i};
                    [~, tempU]=poldec(tempF);
                    tempU=tempU-eye(3);
                    u33(i)=tempU(3,3); 
                    u22(i)=tempU(2,2);
                    u11(i)=tempU(1,1);
                end
                obj.Strain = [u11,u22,u33];
            end
        end
        function SecInds = SectionScan(obj)
        %Sections the Scan by mesa
            if ~isempty(obj.Settings)
                SecInds = SectionLineScan(obj.Strain);
                obj.SecInds = SecInds;
            else
                SecInds = 0;
            end
        end
        function AnalyzeSections(obj,SecInds,ExpTet)
        %Analyzes each section of the scan
            if ~isempty(obj.Settings)
                if nargin == 1
                    if isempty(obj.SecInds)
                        obj.SectionScan;
                    end
                    SecInds = obj.SecInds;
                end
                obj.Sections = struct2table(AnalyzeSections(obj.Strain,SecInds,ExpTet));
            end
            if isfield(obj.Settings,'Iterations')
                obj.CalcIterData(SecInds,ExpTet)
            end
        end
        function CalcIterData(obj,SecInds,ExpTet)
            if ~isempty(obj.Settings)
                
                %Get all strain data
                strain = cellfun(@(x) CalcStrain(x),obj.Settings.Iterations.F,'UniformOutput',false);
                strain = cell2mat(strain);
                strain = reshape(strain,obj.Settings.ScanLength,3,'');
                
                %Get SSE for each iteration
                IterSSE = zeros(size(strain,3),2);
                IterStrainStdDev = zeros(size(strain,3),2);
                IterTetStdDev = zeros(size(strain,3),2);
                for i = 1:size(strain,3)
                    SectionData = struct2table(AnalyzeSections(strain(:,:,i),SecInds,ExpTet));
                    IterSSE(i,1) = mean(SectionData{SectionData.ExpTet == 0,'SSE'});
                    IterSSE(i,2) = mean(SectionData{SectionData.ExpTet ~= 0,'SSE'});
                    IterStrainStdDev(i,1) = mean(mean(SectionData{SectionData.ExpTet == 0,'Std'}));
                    IterStrainStdDev(i,2) = mean(mean(SectionData{SectionData.ExpTet ~= 0,'Std'}));
                    IterTetStdDev(i,1) = mean(SectionData{SectionData.ExpTet == 0,'TetStd'});
                    IterTetStdDev(i,2) = mean(SectionData{SectionData.ExpTet ~= 0,'TetStd'});
                    
                end
                obj.IterData.SSE = IterSSE;
                obj.IterData.StrainStdDev = IterStrainStdDev;
                obj.IterData.TetStdDev = IterTetStdDev;
            end
        end
        function plotIterData(obj,varargin)
            if ~isempty(obj.IterData)
                holdstate = ishold;
                if ~holdstate
                    cla
                end
                hold on
                %SSE
                s1 = subplot(3,2,1);
                p1 = plot(s1,obj.IterData.SSE,varargin{:});
                legend(s1,'Si','SiGe')
                title(s1,'SSE')
                %Strain StdDev
                s2 = subplot(3,2,3);
                p2 = plot(s2,obj.IterData.StrainStdDev,varargin{:});
                legend(s2,'Si','SiGe')
                title(s2,'Strain StdDev')
                %Tet StdDev
                s3 = subplot(3,2,5);
                p3 = plot(s3,obj.IterData.TetStdDev,varargin{:});
                legend(s3,'Si','SiGe')
                title(s3,'Tet StdDev')
                
                %Calculate Approximate Error for SSE
                error = zeros(length(obj.IterData.SSE),1);
                for i = 2:length(obj.IterData.SSE)
                    error(i-1) = abs(obj.IterData.SSE(i,2)-obj.IterData.SSE(i-1,2))/obj.IterData.SSE(i,2);
                end
                subplot(1,2,2);
                plot(error)
                title('SSE Approximate Error')
                xlabel('Iterations')
                
                XXtable = obj.Settings.Iterations.XX;
                XXtable = permute(reshape(cell2mat(cellfun(@(x) mean(x,1),XXtable,'UniformOutput',false)),obj.Settings.ScanLength,3,9),[1 3 2]);
                f = figure;
                pos = f.Position;
                f.Position = [pos(1) pos(2)-pos(4) pos(3)*2 pos(4)*2]; 
                s(1) = subplot(3,1,1);
                t{1} = 'Cross Correlation Coefficient';
                c{1} = 'green';
                s(2) = subplot(3,1,2);
                t{2} = 'Shift Confidence';
                c{2} = 'blue';
                s(3) = subplot(3,1,3);
                t{3} = 'Mutual Information';
                c{3} = 'magenta';
                for i = 1:size(XXtable,2)
                    for j = 1:3
                        cla(s(j))
                        hold(s(j),'on')
                        plot(s(j),XXtable(:,1:i-1,j),':','Color',c{j})
                        plot(s(j),XXtable(:,i,j),'Color',c{j});
                        title(s(j),t{j})
                    end
                    frame = getframe(f);
                    im = frame2im(frame);
                    [imind,cm] = rgb2ind(im,256);
                    if i == 1
                        imwrite(imind,cm,'iterations_s01.gif','gif','Loopcount',inf);
                    else
                        imwrite(imind,cm,'iterations_s01.gif','gif','WriteMode','append');
                    end
                    pause(0.5)
                end
                save('s01_Iter.mat','XXtable');
            end
        end
        function hg = plotSSEIter(obj,varargin)
            hg = 0;
            if ~isempty(obj.IterData)
                gcf;
                holdstate = ishold;
                if ~holdstate
                    cla
                end
                hold on
                hg = hggroup;
                %Calculate Approximate Error for SSE
                error = zeros(length(obj.IterData.SSE),1);
                for i = 2:length(obj.IterData.SSE)
                    error(i-1) = abs(obj.IterData.SSE(i,2)-obj.IterData.SSE(i-1,2))/obj.IterData.SSE(i,2);
                end
                plot(error,varargin{:},'Parent',hg)
                title('SSE Approximate Error')
                xlabel('Iterations')
                if ~holdstate
                    hold off
                end
            end
        end
        function hg = plot(obj,varargin)
        %Overloaded plot function to plot the u11 strain in each section
            if ~isempty(obj.Sections)
                holdstate = ishold;
                if ~holdstate
                    cla
                end
                hold on
                hg = hggroup;
                for i = 1:size(obj.Sections,1)
                    plot(obj.Sections.Ind{i},obj.Sections.u11{i},varargin{:},'Parent',hg)
                    plot(obj.Sections.Ind{i},obj.Sections.u22{i},varargin{:},'Parent',hg)
                    plot(obj.Sections.Ind{i},obj.Sections.u33{i},varargin{:},'Parent',hg)
                end
                if ~holdstate
                    hold off
                end
            end
        end
        function h = plottet(obj,varargin)
            if ~isempty(obj.Sections)
                holdstate = ishold;
                if ~holdstate
                    cla
                end
                hold on
                for i = 1:size(obj.Sections,1)
                    h = plot(obj.Sections.Ind{i},obj.Sections.Tet{i},varargin{:});
                end
                if ~holdstate
                    hold off
                end
            end
        end
        function h = plotXX(obj,varargin)
            h = zeros(3,0);
            if isfield(obj.Settings,'XX')
                holdon = ishold;
                if holdon
                    holdstate = 'on';
                else
                    holdstate = 'off';
                end
                if isstruct(obj.Settings.XX)
                    XXtable = struct2table(obj.Settings.XX);
                    XXtable = varfun(@(x) mean(x,2),XXtable(:,1:3));
                    XXtable.Properties.VariableNames = {'XX','CS','MI'};
                elseif iscell(obj.Settings.XX)
                    return;
                elseif isfield(obj.Settings,'Iterations')
                    XXtable = obj.Settings.Iterations.XX(:,end);
                    XXtable = cell2mat(cellfun(@(x) mean(x,1),XXtable,'UniformOutput',false));
                    XXtable = array2table(XXtable,'VariableNames',{'XX','CS','MI'});
                else
                    XXtable = array2table(obj.Settings.XX,'VariableNames',{'XX','CS','MI'});
                end
                XX = obj.XXParams('XX',XXtable);
                CS = obj.XXParams('CS',XXtable);
                MI = obj.XXParams('MI',XXtable);
                inds = (1:length(XX))';
                
                h(1) = subplot(3,1,1);
                hold(holdstate)
                plot(inds,XX,varargin{:});
                title('Cross Correlation Coefficient')
                
                h(2) = subplot(3,1,2);
                hold(holdstate)
                plot(inds,CS,varargin{:});
                title('Shift Confidence')
                
                h(3) = subplot(3,1,3);
                hold(holdstate)
                plot(inds,MI,varargin{:});
                title('Mutual Information')
            end
        end
              
        function NumSections = get.NumSections(obj)
            NumSections = size(obj.Sections,2);
        end
        function StdDev = get.StrainStdDev(obj)
            if ~isempty(obj.Sections)
                StdDev(1) = mean(mean((obj.Sections{obj.Sections.ExpTet == 0,'Std'})));
                StdDev(2) = mean(mean((obj.Sections{obj.Sections.ExpTet ~= 0,'Std'})));
            else
                StdDev = [];
            end
        end
        function StdDev = get.TetStdDev(obj)
            if ~isempty(obj.Sections)
                StdDev(1) = mean((obj.Sections{obj.Sections.ExpTet == 0,'TetStd'}));
                StdDev(2) = mean((obj.Sections{obj.Sections.ExpTet ~= 0,'TetStd'}));
            else
                StdDev = [];
            end
        end
        function SSE = get.SSE(obj)
            if ~isempty(obj.Sections)
                SSE(1) = mean((obj.Sections{obj.Sections.ExpTet == 0,'SSE'}));
                SSE(2) = mean((obj.Sections{obj.Sections.ExpTet ~= 0,'SSE'}));
            else
                SSE = [];
            end
        end
        
    end
    methods(Static)
        function Param2 = XXParams(Param,XXtable)
            Param = XXtable.(Param);
            if ~iscell(Param)
                Param = num2cell(Param,2);
            end
            Param = cellfun(@mean,Param);

            %Linear Interpolate Zero-points
            pts = Param==0;
            inds = (1:length(Param))';
            Param2 = Param;
            Param2(pts)=interp1(inds(~pts),Param(~pts),inds(pts));
        end
    end
end
        