classdef LineScanAnalysis < handle
    %LINESCANANALYSIS Stores and compares data from Vaudin Line Scans
    %   Noise Analysis
    
    properties
        Baseline
        Folder
        SectionInds
        Scans
        ActiveScan
        NumScans
        ExpTet
        ExpTetTol
    end
    properties (SetAccess = private, GetAccess = private)
       I 
    end
    methods
        function obj = LineScanAnalysis
            obj.Scans = containers.Map;
            obj.I = cell(0,2);
            obj.Folder = pwd;
        end
        function SetBaseline(obj, BaselineName)
        %Selects which scan is to be used a the reference point as well as
        %used to section the scan. Typically the 'Real' scan is used.
            if obj.Scans.isKey(BaselineName)
                obj.Baseline = BaselineName;
                obj.SectionInds = obj.Scans(BaselineName).SectionScan;
                obj.Folder = obj.Scans(BaselineName).Folder;
                [~,ind] = intersect(obj.I(:,1),BaselineName);
                obj.I(:,2) = num2cell([(2:ind)';1;(ind+1:obj.NumScans)']);
            else
                disp('Not a valid key')
            end
        end
        function addScan(obj,Name,Folder,Filename)
        %Add a scan to the analysis.
        %Name: Short key name used to reference the scan
        %Folder, Filename: path to the scan, or may be left blank to use
        %the file picker
            p = path;
            w = pwd;
            cd(obj.Folder);
            if nargin == 1
                Name = ['Scan' num2str(obj.Scans.Count+1)];
            end
            if nargin == 1 || nargin == 2
                obj.Scans(Name) = LineScanClass;
            elseif nargin == 3
                obj.Scans(Name) = LineScanClass(Folder);
            else
                obj.Scans(Name) = LineScanClass(Folder,Filename);
            end
            cd(w);
            path(p);
            if isKey(obj.Scans,Name) && ~isempty(obj.Scans(Name).Folder)
                ReadScan(obj.Scans(Name));
                obj.I(obj.NumScans,:) = {Name,obj.NumScans};
            else
                remove(obj.Scans,Name);
                disp([Name ' not added']);
            end
        end
        function Comparison = CompareScans(obj,SelectScans,showplots)
        %Compares the scans. Generates a plot and returns a table of data.
            OpenSelection = 0;
            plots = 0;
            NumCompare = obj.NumScans;
            Comparison = {};
            if nargin > 1
                OpenSelection = SelectScans;
            end
            if nargin == 3
                plots = showplots;
            end
            if ~isempty(obj.Baseline)
                scan = cell(obj.NumScans,1);
                for i = 1:obj.NumScans
                    scan{i} = obj.I{[obj.I{:,2}]'==i,1};
                end
                if OpenSelection
                    [Selection,ok] = listdlg('ListString',scan(2:end),'PromptString','Select scans to compare','Name','Compare Scans');
                    if ok
                        scan = scan([1,Selection+1]);
                        NumCompare = length(scan);
                    end
                end
                if isempty(obj.ExpTet)
                    obj.SetTet;
                end
                colors = hsv(NumCompare+1);
                colors = colors(2:end,:);
                if plots; hold on; end;
                
                %Initialize Variables
                hs = zeros(NumCompare,1);
                ht = zeros(NumCompare,1);
                StrainStdDev = zeros(NumCompare,2);
                TetStdDev = zeros(NumCompare,2);
                SSE = zeros(NumCompare,2);
                TetDiff = zeros(NumCompare,1);
                
                %Analyze and plot each section
                for i = 1:NumCompare
                    AnalyzeSections(obj.Scans(scan{i}),obj.SectionInds,obj.ExpTet);
                    if plots
                        hs(i) = plot(obj.Scans(scan{i}),'color',colors(i,:));
                    end
                    StrainStdDev(i,:) = obj.Scans(scan{i}).StrainStdDev;
                end
                if plots
                    ylabel('Strain (%)')
                    title('Strain')
                    legend(hs,scan')
                    hold off
                    
                    figure
                    hold on
                end
                
                %Plot tetragonality sections
                for i = 1:NumCompare
                    if plots
                        ht(i) = plottet(obj.Scans(scan{i}),'color',colors(i,:));
                    end
                    TetStdDev(i,:) = obj.Scans(scan{i}).TetStdDev;
                    SSE(i,:) = obj.Scans(scan{i}).SSE;
                    TetDiff(i) = obj.Scans(scan{i}).TetDiff - obj.ExpTet;
                end
                if plots
                    Len = obj.Scans(obj.Baseline).Length;
                    X = 1:Len;
                    Y = ones(1,Len)*obj.ExpTet;
                    Y0 = zeros(1,Len);
                    ht(i+1) = plot(X,Y+obj.ExpTetTol,'r--');
                    plot(X,Y-obj.ExpTetTol,'r--');
                    plot(X,Y0+obj.ExpTetTol,'r--');
                    plot(X,Y0-obj.ExpTetTol,'r--');
                    ylabel('Tetragonality (%)')
                    title('Tetragonality')
                    legend(ht,[scan;'Expected Tetragonality']')
                    hold off
                    
                    figure
                    hold on
                end
                
                %Plot XX Params
                j = 1;
                XXlegend = cell(size(scan));
                for i = 1:NumCompare
                    if plots
                        h = plotXX(obj.Scans(scan{i}),'color',colors(i,:));
                        if ~isempty(h)
                            XXlegend{j} = scan{i};
                            j = j + 1;
                        end
                    end
                end
                if plots
                    legend(XXlegend(1:j-1));
                end
                
                scan{1} = [scan{1} ' (Baseline)'];
                Comparison.Scans = scan;
                Comparison.StrainStdDev = StrainStdDev;
                Comparison.TetStdDev = TetStdDev;
                Comparison.SSE = SSE;
                Comparison.TetDiff = TetDiff;
                %Comparison.StdDev_Percent = (StrainStdDev(1)-StrainStdDev)/StrainStdDev(1);
                %Comparison.SSE_Percent = (SSE(1)-SSE)/SSE(1);
                Comparison = struct2table(Comparison);
            end
        end
        function NumScans = get.NumScans(obj)
            NumScans = length(obj.Scans.keys);
        end
        function SetTet(obj)
            prompt = {'Expected tetragonality (10^{-2}):','Expected tetragonality tolerance  (10^{-2}):'};
            options.Resize = 'on';
            options.WindowStyle = 'normal';
            options.Interpreter = 'tex';
            answer = inputdlg(prompt,'Input Expected Tet.',1,{'1.25','0.02'},options);
            obj.ExpTet = str2double(answer{1});
            obj.ExpTetTol = str2double(answer{2});
        end
        function RemoveScan(obj,ScanName)
            remove(obj.Scans,ScanName);
        end
    end
    
end


    