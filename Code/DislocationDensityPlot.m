function DislocationDensityPlot(Settings, alpha_data, cmin, cmax)
%DISLOCATIONDENSITYOUTPUT
%DislocationDensityOutput(Settings,Components, cmin, cmax, MaxMisorientation)
%code bits for this function taken from Step2_DisloDens_Lgrid_useF_2.m
%authors include: Collin Landon, Josh Kacher, Sadegh Ahmadi, and Travis Rampton
%modified for use with HROIM GUI code, Jay Basinger 4/20/2011
format compact
tic

%Calculate Dislocation Density
data = Settings.data;
r = data.rows;%
c = data.cols;%
ImageNamesList=Settings.ImageNamesList;
NColsOdd=[];
NColsEven=[];
if strcmp(Settings.ScanType,'Hexagonal')
    NColsOdd = c;
    NColsEven = c-1;
    leftside=1:c:length(ImageNamesList);
    rightside=NColsOdd:c:length(ImageNamesList);
    rightside=[rightside,c:c:length(ImageNamesList)];
    rightside=sort(rightside);
    topside=rightside(end-1)+1:length(ImageNamesList);
end

alpha_total3 = alpha_data.alpha_total3;
alpha_total9 = alpha_data.alpha_total9;
alpha = alpha_data.alpha;

% figure;hist(log10(alpha_data.alpha_total3),10:.1:17);xlim([11 17])
% disp(['median3: ',num2str((median(alpha_data.alpha_total3)))]);
% disp(['stdev3: 10e',num2str(log10(std(alpha_data.alpha_total3)))]);
% 
%cmin=MinCutoff;
%cmax=UpperCutoff;

if strcmp(Settings.ScanType,'Square') ||  strcmp(Settings.ScanType,'LtoSquare')
    alpha_total3=reshape(alpha_total3, [c r])';
    
    % alphare=reshape(alpha,[3,3,r,c]);

    qq=reshape(alpha(1,3,:),[c r])';
    if r == 1; qq=repmat(qq,floor(Settings.ScanLength/4),1); end;
    figure;imagesc(log10(abs(qq)))
    title('Alpha_1_3','fontsize',14)
    shading flat
    axis equal tight
    % view(2)
    colorbar
    caxis([cmin cmax])

    qq=reshape(alpha(2,3,:),[c r])';
    if r == 1; qq=repmat(qq,floor(Settings.ScanLength/4),1); end;
    figure;imagesc(log10(abs(qq)))
    title('Alpha_2_3','fontsize',14)
    shading flat
    axis equal tight
    % view(2)
    colorbar
    caxis([cmin cmax])

    qq=reshape(alpha(3,3,:),[c r])';
    if r == 1; qq=repmat(qq,floor(Settings.ScanLength/4),1); end;
    figure;imagesc(log10(abs(qq)))
    title('Alpha_3_3','fontsize',14)
    shading flat
    axis equal tight
    % view(2)
    colorbar
    caxis([cmin cmax])

    % colormapeditor % change scaling of colorbar
    qq = alpha_total3;
    if r == 1; qq=repmat(qq,floor(Settings.ScanLength/4),1); end;
    figure;imagesc(log10(abs(qq)))
    title('Alpha Total','fontsize',14)
    shading flat
    axis equal tight
    view(2)
    colorbar
    caxis([cmin cmax+1])
    drawnow
    
    toc
end
if strcmp(Settings.ScanType,'Hexagonal')
    Newdd = zeros(r,NColsEven);
    New13=Newdd;
    New23=Newdd;
    New33=Newdd;
    count=1;
    for rr = 1:r
        if bitget(abs(rr),1)~=0 %odd

            for cc = 1:NColsOdd
                Newdd(rr,cc) = alpha_total9(count);
                New13(rr,cc)=alpha(1,3,count);
                New23(rr,cc)=alpha(2,3,count);
                New33(rr,cc)=alpha(3,3,count);
                gid(rr,cc)=Settings.grainID(count);

                count = count + 1;
            end
        else
            for cc = 1:NColsEven
                Newdd(rr,cc) = alpha_total9(count);
                New13(rr,cc)=alpha(1,3,count);
                New23(rr,cc)=alpha(2,3,count);
                New33(rr,cc)=alpha(3,3,count);
                gid(rr,cc)=Settings.grainID(count);

                count = count + 1;
            end
        end
    end
    
    % alphare=reshape(alpha,[3,3,r,c]);

    figure;imagesc(log10(abs(New13)))
    title('Alpha_1_3','fontsize',14)
    shading flat
    axis equal tight
    % view(2)
    colorbar
    caxis([cmin cmax])

    figure;imagesc(log10(abs(New23)))
    title('Alpha_2_3','fontsize',14)
    shading flat
    axis equal tight
    % view(2)
    colorbar
    caxis([cmin cmax])

    figure;imagesc(log10(abs(New33)))
    title('Alpha_3_3','fontsize',14)
    shading flat
    axis equal tight
    % view(2)
    colorbar
    caxis([cmin cmax])

    figure;imagesc(log10((abs(New13)+abs(New23)+abs(New33))*3))
    title('Alpha 3 Term','fontsize',14)
    shading flat
    axis equal tight
    % view(2)
    colorbar
    caxis([cmin cmax+1])
    
    % colormapeditor % change scaling of colorbar
    figure;imagesc(log10(abs(Newdd)))
    
    title('Alpha Total','fontsize',14)
    shading flat
    axis equal tight
    view(2)
    colorbar
    caxis([cmin cmax+1])
    drawnow
    
    toc
end
if strcmp(Settings.ScanType,'L')
    alpha_total3=reshape(alpha_total3, [c r])';
    
    qq=reshape(alpha(1,3,:),[c r])';
    figure;imagesc(log10(abs(qq)))
    title('Alpha_1_3','fontsize',14)
    shading flat
    axis equal tight
    % view(2)
    colorbar
    caxis([cmin cmax])

    qq=reshape(alpha(2,3,:),[c r])';
    figure;imagesc(log10(abs(qq)))
    title('Alpha_2_3','fontsize',14)
    shading flat
    axis equal tight
    % view(2)
    colorbar
    caxis([cmin cmax])

    qq=reshape(alpha(3,3,:),[c r])';
    figure;imagesc(log10(abs(qq)))
    title('Alpha_3_3','fontsize',14)
    shading flat
    axis equal tight
    % view(2)
    colorbar
    caxis([cmin cmax])

    % colormapeditor % change scaling of colorbar
    figure;imagesc(log10(abs(alpha_total3)))
    title('Alpha Total','fontsize',14)
    shading flat
    axis equal tight
    view(2)
    colorbar
    caxis([cmin cmax+1])
end
