function [F, g, U, fitMetrics, XX, sigma] = GetDefGradientTensor(ImageInd,Settings,curMaterial)
%GETDEFGRADIENTTENSOR
%[F g U SSE] = GetDefGradientTensor(ImageInd,Settings)
%Takes in the HREBSD Settings structure and the image index
%Calculates deformation gradient tensor F between the image and the chosen
%reference image, returns F, orientation (g), strain (U), and the error
%measure SSE.
%Jay Basinger, March 24 2011

%ImageInd is the index of the image(s) to use for comparison.

% fprintf(1,'Running GetDefGradientTensor for point %u\n', ImageInd);
%% Read in the scan point's image. If L grid, read in legs as well.
DoLGrid = strcmp(Settings.ScanType,'L');
% fftw('wisdom',Settings.largefftmeth);
% disp(curMaterial)

if DoLGrid
    % This is depricated, and has been for as long as I have worked here,
    % we need to just remove it, otherwise, why do we even have source
    % control? --Zach C.
    
    %the LImageNamesList field is a cell of length three containing the
    %L-grid image paths.
        
    ImagePaths = Settings.LImageNamesList(ImageInd,:);
    ImagePath = ImagePaths{2};
    LegAPath = ImagePaths{1};
    LegCPath = ImagePaths{3};
    if strcmp(Settings.ImageFilterType,'standard')
        ScanImage = ReadEBSDImage(ImagePath,Settings.ImageFilter);
        LegAImage = ReadEBSDImage(LegAPath,Settings.ImageFilter);
        LegCImage = ReadEBSDImage(LegCPath,Settings.ImageFilter);
    else
        ScanImage = localthresh(ImagePath);
        LegAImage = localthresh(LegAPath);
        LegCImage = localthresh(LegCPath);
    end
   
    if isempty(ScanImage) || isempty(LegAImage) || isempty(LegCImage)
        
        F.a =  -eye(3);
        F.b = -eye(3);
        F.c = -eye(3);
        fitMetrics.a = computations.metrics.fitMetrics;
        fitMetrics.b = computations.metrics.fitMetrics;
        U = -eye(3);
        g = euler2gmat(Angles(ImageInd,1),Angles(ImageInd,2),Angles(ImageInd,3));
        sigma = -eye(3);
        
        return;
    end
    
else

    ScanImage = Settings.patterns.getPattern(Settings,ImageInd);

    g = euler2gmat(Settings.Angles(ImageInd,1) ...
        ,Settings.Angles(ImageInd,2),Settings.Angles(ImageInd,3));
    if isempty(ScanImage)
        F = -eye(3);
        fitMetrics.SSE = computations.metrics.fitMetrics;
        U = -eye(3);
        sigma = -eye(3);
        XX = -1 * ones(Settings.NumROIs, 3);
        return;
    end
end

%disp('GOT TO THIS POINT')--did print. so first IF statement is FALSE

%Initialize variables for params settings for calcFnew and genEBSDpattern

xstar = Settings.XStar(ImageInd);
ystar = Settings.YStar(ImageInd);
zstar = Settings.ZStar(ImageInd);

Av = Settings.AccelVoltage*1000; %put it in eV from KeV

sampletilt = Settings.SampleTilt;

elevang = Settings.CameraElevation;


pixsize = Settings.PixelSize;
Material = ReadMaterial(curMaterial);  % this should depend on the crystal structure maybe not here
paramspat={xstar;ystar;zstar;pixsize;Av;sampletilt;elevang;Material.Fhkl;Material.dhkl;Material.hkl};
if isfield(Settings,'camphi1')
    paramspat{11} = Settings.camphi1;
    paramspat{12} = Settings.camPHI;
    paramspat{13} = Settings.camphi2;
end
% for new Dr. Fullwood condition

if strcmp(Settings.ROIStyle,'Intensity')
    %     Settings.NumROIs=25;% originally 36; if you comment this line out it reverts****
    %     Settings.ROISizePercent=15; % was 25% - seems way too big
    %     Settings.ROISize=round(Settings.ROISizePercent*pixsize/100);
    %     Settings.ROIStyle='Intensity'; % was 'Grid'; comment out to revert - but beware that grid always chooses 48 ROIs
    I1 = genEBSDPatternHybrid(g,paramspat,eye(3),Material.lattice,Material.a1,Material.b1,Material.c1,Material.axs); %use high intensity points in simulated image rather than real image to pick ROI points
    
    [roixc,roiyc]= GetROIs(I1,Settings.NumROIs,pixsize,Settings.ROISize,...
        Settings.ROIStyle);
    Settings.roixc = roixc;
    Settings.roiyc = roiyc;
else
    [roixc,roiyc]= GetROIs(ScanImage,Settings.NumROIs,pixsize,Settings.ROISize,...
        Settings.ROIStyle);
    Settings.roixc = roixc;
    Settings.roiyc = roiyc;
%     if exist('Optimize.mat','file') > 0
%         load Optimize.mat
%         Settings.NumROIs
%         Settings.ROISizePercent
%         ROIXC = [ROIXC; roixc];
%         ROIYC = [ROIYC; roiyc];
%     else
%         ROIXC = roixc;
%         ROIYC = roiyc;
%     end
%     save('Optimize.mat', 'ROIXC', 'ROIYC');
end



%use only for optical distortion correction
% paramspat={xstar;ystar;zstar;round(pixsize*1.6613);Av;sampletilt;elevang;Fhkl;dhkl;hkl};
% crpl=206; crpu=824;


%Josh tended to use a reference orientation for all points within a grain
%for materials with low deformation. If it has a great deal of deformation
%this needs to be reconsidered.
% gr = euler2gmat(Settings.Phi1Ref(ImageInd),Settings.PHIRef(ImageInd),Settings.Phi2Ref(ImageInd));%% the most recent version - but gets messed up due to wrong ref orientation!!!!! hence changed to next line 7/24/14
gr=g;
% gr = euler2gmat(Settings.Angles(ImageInd,1),Settings.Angles(ImageInd,2),Settings.Angles(ImageInd,3));


%Get Reference Image depending on the chosen HROIM Method (so far these are
%either Simulated or Real. Plan on adding Sim/Real Hybrid
switch Settings.HROIMMethod
    
    case 'Dynamic Simulated'
        mperpix = Settings.mperpix;
        
        if Settings.SinglePattern
            RefImage = Settings.RefImage;
            clear global rs cs Gs
%             [F1,fitMetrics1,XX] = CalcF(RefImage,ScanImage,gr,eye(3),ImageInd,Settings,curMaterial,Settings.RefImageInd);
            %disp('ATTEMPT THE SWITCH')
            [F1,fitMetrics1,XX] = SwitchF(RefImage,ScanImage,gr,eye(3),ImageInd,Settings,curMaterial,Settings.RefImageInd);
            %disp('FINISHED THE SWITCH')


        else
            try
                RefImage = genEBSDPatternHybrid_fromEMSoft(gr,xstar,ystar,zstar,pixsize,mperpix,elevang,sampletilt,curMaterial,Av,ImageInd);
                

%%%%%%%%%%%%%%%%%%%%UNCOMMENT TO SAVE UNFILTERED DYNAMIC IMAGES%%%%%%%%%%%%%%%%%%%%%%%%%%% 

if Settings.dynamic

                    RefImage2 = single(RefImage)/255;
%                     scanNum = 3; %change this too
%                     scanMat = ['silicon']; %can change this
%                     folderName = ['Scan_', num2str(scanNum), '_', scanMat];
                    folderName = 'E:/dataSets/Simulated Data Sets/EDAX File Format Examples/Dynamic Images';
                    mkdir(folderName);%make a new folder for every scan
                    cd(folderName);%go to the folder to save for all the data
                    imageName = ['pattern_', num2str(ImageInd), '.jpeg'];
                    imwrite(RefImage2(:, :), imageName);
                    cd('C:/Users/Bethany/Documents/GitHub/OpenXY/code')
end

                clear global rs cs Gs

%                 [F1,fitMetrics1,XX] = CalcF(RefImage,ScanImage,gr,eye(3),ImageInd,Settings,curMaterial,0);
                %disp('ATTEMPT THE SWITCH')
                [F1,fitMetrics1,XX] = SwitchF(RefImage,ScanImage,gr,eye(3),ImageInd,Settings,curMaterial,0);
                %disp('FINISHED THE SWITCH')

                % some catch on SSE as for simulated pattern approach below?
                for iq=1:Settings.IterationLimit-1
                    [rr,uu]=poldec(F1); % extract the rotation part of the deformation, rr
                    gr=rr'*gr; % correct the rotation component of the deformation so that it doesn't affect strain calc
                    RefImage = genEBSDPatternHybrid_fromEMSoft(gr,xstar,ystar,zstar,pixsize,mperpix,elevang,sampletilt,curMaterial,Av,ImageInd);
                    
%%%%%%%%%%%%%%%%%%%%UNCOMMENT TO SAVE Rotated DYNAMIC IMAGES%%%%%%%%%%%%%%%%%%%%%%%%%%% 

if Settings.dynRotated
                    RefImage2 = single(RefImage)/255;
%                     scanNum = 3; %change this too
%                     scanMat = ['silicon']; %can change this
%                     folderName = ['Scan_', num2str(scanNum), '_', scanMat];
                    folderName = 'E:/dataSets/sims/silicon_forStuNonOriginal_dynRot';
                    mkdir(folderName);%make a new folder for every scan
                    cd(folderName);%go to the folder to save for all the data
                    imageName = ['pattern_', num2str(ImageInd), '.jpeg'];
                    imwrite(RefImage2(:, :), imageName);
                    cd('C:/Users/Bethany/Documents/GitHub/OpenXY/code');
end

                    clear global rs cs Gs
%                     [F1,fitMetrics1,XX,sigma] = CalcF(RefImage,ScanImage,gr,eye(3),ImageInd,Settings,curMaterial,0);
                    %disp('ATTEMPT THE SWITCH')
                    [F1,fitMetrics1,XX, sigma] = SwitchF(RefImage,ScanImage,gr,eye(3),ImageInd,Settings,curMaterial,0);
                    %disp('FINISHED THE SWITCH')
                end
            catch ME
                F1 = eye(3);
                sigma = eye(3);
                XX(Settings.NumROIs,3) = 0;
                fitMetrics1.SSE = computations.metrics.fitMetrics;
                %cd 'C:\Users\bcsyphus\Documents\GitHub\OpenXY\Code';%hard code to get back to the OpenXY code after the failed EMsoft attempt -- Bethany Syphus 3/3/23
            end
            %%%%%
        end     
    case 'Simulated'
        
        %         RefImage = genEBSDPatternHybrid(gr,paramspat,eye(3),lattice,al,bl,cl,axs); % testing next line instead *****
        RefImage = genEBSDPatternHybrid(gr,paramspat,eye(3),Material.lattice,Material.a1,Material.b1,Material.c1,Material.axs);
        %          RefImage = genEBSDPatternHybridMexHat(gr,paramspat,eye(3),lattice,al,bl,cl,axs);
        
%%%%%%%%%%%%%%%%%%%UNCOMMENT TO SAVE UNFILTERED KINEMATIC IMAGES%%%%%%%%%%%%%%%%%%%%%%%%%%%    
if Settings.kinUnfiltered
                    RefImage2 = single(RefImage)/255;
%                     scanNum = 8; %change this too
%                     scanMat = 'ferriteUnfiltered'; %can change this
%                     folderName = ['Scan_', num2str(scanNum), '_', scanMat];
%                     orientation = 'ori1'; %change this every 6 times?
%                     file = 'A6'; %change this every time. Should only have 2 images
%                     folderName = ['e:/Namit/BethanySims/' orientation '/' file];
                    folderName = 'E:/dataSets/sims/silicon_smallOxford_kinUnfiltered';
                    mkdir(folderName);%make a new folder for every scan
                    cd(folderName);%go to the folder to save for all the data
                    imageName = ['pattern_', num2str(ImageInd), '.jpeg'];
                    imwrite(RefImage2(:, :), imageName);
                    cd('c:/Users/Bethany/Documents/GitHub/OpenXY/Code');
end




        %use following line only for optical distortion correction
        %    RefImage = RefImage(crpl:crpu,crpl:crpu);
        %         RefImage = genEBSDPattern(gr,paramspat,eye(3),lattice,al,bl,cl,axs);
        
        RefImage = custimfilt(RefImage,Settings.ImageFilter(1), ...
            Settings.PixelSize,Settings.ImageFilter(3),Settings.ImageFilter(4));


        %%%%%%%%%%%%%%%%%%%%if you want to control the F uncomment this one
%         strainedImagesKinematic(gr, paramspat, Material, Settings, ImageInd); 


        %%%%%%%%%%%%%%%%%%%%UNCOMMENT TO SAVE KINEMATIC IMAGES%%%%%%%%%%%%%%%%%%%%%%%%%%%    
        if Settings.kinFiltered
                    RefImage2 = double(RefImage)/255;
%                     scanNum = 8; %change this too
%                     scanMat = 'ferriteFiltered'; %can change this
%                     folderName = ['Scan_', num2str(scanNum), '_', scanMat];
%                     orientation = 'ori3'; %change this every 6 times?
%                     file = 'A6_unstrained'; %change this every time. Should only have 2 images
%                     folderName = ['e:/Namit/BethanySims/' orientation '/' file];
                    folderName = 'E:/dataSets/Simulated Data Sets/EDAX File Format Examples/Kinematic Filtered Images';
                    mkdir(folderName);%make a new folder for every scan
                    cd(folderName);%go to the folder to save for all the data
                    imageName = ['pattern_', num2str(ImageInd), '.jpeg'];
                    imwrite(RefImage2(:, :), imageName);
                    cd('c:/Users/Bethany/Documents/GitHub/OpenXY/Code');
        end
        

        %Initialize
        clear global rs cs Gs
%         [F1,fitMetrics1,XX] = CalcF(RefImage,ScanImage,gr,eye(3),ImageInd,Settings,curMaterial,0);
        %disp('ATTEMPT THE SWITCH')
        [F1,fitMetrics1,XX] = SwitchF(RefImage,ScanImage,gr,eye(3),ImageInd,Settings,curMaterial,0);
        %disp('FINISHED THE SWITCH')
        
        %.gif recording stuff
        if isfield(Settings,'doGif') && Settings.doGif
            f = getframe(figure(100));
            [im,map] = rgb2ind(f.cdata,256,'nodither');
            im(1,1,1,Settings.IterationLimit+5) = 0;
            frame = 2;
        end
%{a
        %%%%New stuff to remove rotation error from strain measurement DTF  7/14/14
        for iq=1:4
            [rr,uu]=poldec(F1); % extract the rotation part of the deformation, rr
            gr=rr'*gr; % correct the rotation component of the deformation so that it doesn't affect strain calc
            RefImage = genEBSDPatternHybrid(gr,paramspat,eye(3),Material.lattice,Material.a1,Material.b1,Material.c1,Material.axs);

% %%%%%%%%%%%%%%%%%%%%UNCOMMENT TO SAVE UNFILTERED KINEMATIC IMAGES%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%             if Settings.kinUnfiltered
%                     RefImage2 = single(RefImage)/255;
% %                     scanNum = 8; %change this too
% %                     scanMat = 'ferriteUnfiltered'; %can change this
% %                     folderName = ['Scan_', num2str(scanNum), '_', scanMat];
% %                     orientation = 'ori1'; %change this every 6 times?
% %                     file = 'A6'; %change this every time. Should only have 2 images
% %                     folderName = ['e:/Namit/BethanySims/' orientation '/' file];
%                     folderName = 'E:/dataSets/sims/silicon_forStuNonOriginal_kinUn2';
%                     mkdir(folderName);%make a new folder for every scan
%                     cd(folderName);%go to the folder to save for all the data
%                     imageName = ['pattern_', num2str(ImageInd), '.jpeg'];
%                     imwrite(RefImage2(:, :), imageName);
%                     cd('c:/Users/Bethany/Documents/GitHub/OpenXY/Code');
%             end

            RefImage = custimfilt(RefImage,Settings.ImageFilter(1), ...
                Settings.PixelSize,Settings.ImageFilter(3),Settings.ImageFilter(4));

            
% %%%%%%%%%%%%%%%%%%%%UNCOMMENT TO SAVE KINEMATIC IMAGES%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%             if Settings.kinFiltered
%                     RefImage2 = double(RefImage)/255;
% %                     scanNum = 8; %change this too
% %                     scanMat = 'ferriteFiltered'; %can change this
% %                     folderName = ['Scan_', num2str(scanNum), '_', scanMat];
% %                     orientation = 'ori3'; %change this every 6 times?
% %                     file = 'A6_unstrained'; %change this every time. Should only have 2 images
% %                     folderName = ['e:/Namit/BethanySims/' orientation '/' file];
%                     folderName = 'E:/dataSets/sims/silicon_forStuNonOriginal_kinFil2';
%                     mkdir(folderName);%make a new folder for every scan
%                     cd(folderName);%go to the folder to save for all the data
%                     imageName = ['pattern_', num2str(ImageInd), '.jpeg'];
%                     imwrite(RefImage2(:, :), imageName);
%                     cd('c:/Users/Bethany/Documents/GitHub/OpenXY/Code');
%             end
            


            clear global rs cs Gs
%             [F1,fitMetrics1,XX,sigma] = CalcF(RefImage,ScanImage,gr,eye(3),ImageInd,Settings,curMaterial,0);
            %disp('ATTEMPT THE SWITCH')
            [F1,fitMetrics1,XX, sigma] = SwitchF(RefImage,ScanImage,gr,eye(3),ImageInd,Settings,curMaterial,0);
            %disp('FINISHED THE SWITCH')


            if isfield(Settings,'doGif') && Settings.doGif
                f = getframe(figure(100));
                im(:,:,1,frame) = rgb2ind(f.cdata,map,'nodither');
                frame = frame + 1;
            end
        end
        %%%%%
%}a

        

        %Improved convergence routine should replace this loop:
        for ii = 1:Settings.IterationLimit
            %changed from 25 to 30 to get more of the simulated images
            if fitMetrics1.SSE > 25 % need to make this a variable in the AdvancedSettings GUI
                if ii == 1
                    display(['Didn''t make it in to the iteration loop for point ', num2str(ImageInd)]) %changed from "for point ' ImageInd" so that the index is converted to a string so it can be displayed
                  %  disp('this is where it breaks') %for debugging 
                  fid = fopen('badPoints.txt', 'a');  
                  formatSpec = '%i\n';
                  fprintf(fid, formatSpec, ImageInd);
                  %fprintf(fid, '%s', [num2str(ImageInd), '\n']);
                  fclose(fid);

%                   disp(['fitMetrics1.SSE = ', num2str(fitMetrics1.SSE)])

                end
                g = euler2gmat(Settings.Angles(ImageInd,1),Settings.Angles(ImageInd,2),Settings.Angles(ImageInd,3)); 
                F = -eye(3);
                %fitMetrics.SSE = computations.metrics.fitMetrics;
                fitMetrics = fitMetrics1;
                fitMetrics.SSE = 999;
                U = -eye(3);
                return;
                %the error gets here, then returns so it stops.
            end
            


            [r1,u1]=poldec(F1);
            U1=u1;
            R1=r1;
            FTemp=R1*U1; %**** isn't this just F1 - why did we bother doing this????
            
            NewRefImage = genEBSDPatternHybrid(gr,paramspat,FTemp,Material.lattice,Material.a1,Material.b1,Material.c1,Material.axs);% correct method ******DTF changed to test new profiles             pattern *****
            %  NewRefImage = genEBSDPatternHybridmult(gr,paramspat,FTemp,lattice,al,bl,cl,axs);  % multiplied simulated approach
            %   NewRefImage = genEBSDPatternHybridMexHat(gr,paramspat,eye(3),lattice,al,bl,cl,axs);
            %             NewRefImage = genEBSDPatternProfileFnew(gr,paramspat,FTemp,lattice,al,bl,cl,axs,ScanImage);
            %              NewRefImage = genEBSDPatternHybridOwnWave(gr,paramspat,FTemp,lattice,al,bl,cl,axs);
            %             keyboard
            %Comment in this line only for optical distortion test: NewRefImage = NewRefImage(crpl:crpu,crpl:crpu);
            
            NewRefImage = custimfilt(NewRefImage, Settings.ImageFilter(1), Settings.PixelSize, ...
                Settings.ImageFilter(3), Settings.ImageFilter(4));
            %         keyboard
            clear global rs cs Gs
%             [F1,fitMetrics1,XX,sigma] = CalcF(NewRefImage,ScanImage,gr,FTemp,ImageInd,Settings,curMaterial,0);

            %disp('ATTEMPT THE SWITCH')
            [F1,fitMetrics1,XX, sigma] = SwitchF(NewRefImage,ScanImage,gr,FTemp,ImageInd,Settings,curMaterial,0);
            %disp('FINISHED THE SWITCH')

            if isfield(Settings,'doGif') && Settings.doGif
                f = getframe(figure(100));
                im(:,:,1,frame) = rgb2ind(f.cdata,map,'nodither');
                frame = frame + 1;
            end
        end
        if isfield(Settings,'doGif') && Settings.doGif
            button = questdlg('Keep this as a gif?');
            if strcmp(button,'Yes')
                [~,gifName,~] = fileparts(ImagePath);
                gifName = ['D:\Katherine\GIFS\' gifName '.gif'];
                imwrite(im,map,gifName,'DelayTime',0.5,'LoopCount',inf)
            end
        end
    case 'Real'
        %Find the grain of scan image and get the reference image for that
        %grain
        RefImageInd = Settings.RefInd(ImageInd);
        RefImage = Settings.patterns.getPattern(Settings,RefImageInd);
        clear global rs cs Gs
%         disp(RefImagePath);
        gr = euler2gmat(Settings.Angles(RefImageInd,:));
        
        [F1,fitMetrics1,XX,sigma] = SwitchF(RefImage,ScanImage,gr,eye(3),ImageInd,Settings,curMaterial,RefImageInd);

    case 'Hybrid'
        %Use simulated pattern method on one reference image then use
        %Real for all others in that grain.
    
    case 'Remapping'
        RefImageInd = Settings.RefInd(ImageInd);
        RefImage = Settings.patterns.getPattern(Settings, RefImageInd);
        %{
        % Uncomment to compare unrotated refference to rotated one
        clear global rs cs Gs
        [F1,SSEPre,XX,sigma] = CalcFShift(RefImage,ScanImage,gr,eye(3),ImageInd,Settings,curMaterial,RefImageInd);
        clear global rs cs Gs
        %}
        gr = euler2gmat(Settings.Angles(RefImageInd,:));
        
        refXStar = Settings.XStar(RefImageInd);
        refYStar = Settings.YStar(RefImageInd);
        refZStar = Settings.ZStar(RefImageInd);
        RefImage = ...
            rotateImage(RefImage, gr, g, [refXStar refYStar refZStar],...
             Material.lattice, sampletilt, elevang);
        
        clear global rs cs Gs
        [F1,fitMetrics1,XX,sigma] = SwitchF(RefImage, ScanImage, gr, eye(3),...
            ImageInd, Settings, curMaterial, RefImageInd);
        clear global rs cs Gs
        
        if Settings.DoShowPlot
            drawnow
        end

end

%Calculate Mutual Information over entire Image
%XX.MI_total = CalcMutualInformation(RefImage,ScanImage);

if DoLGrid
    
    %For the leg points just set it to Real Sample all the
    %time
    KeepFCalcMethod = Settings.FCalcMethod;
    Settings.FCalcMethod = 'Real Sample';
    
    
    % evaluate point a using b as the reference
    clear global rs cs Gs
    [F.a, fitMetrics.a] = CalcFRuggles(ScanImage,LegAImage,gr,eye(3),ImageInd,Settings,curMaterial,ImageInd); %note - sending in index of scan point for now - no PC correction!!!
    
    % evaluate point c using b as the refrerence
    clear global rs cs Gs
    [F.c, fitMetrics.c] = CalcFRuggles(ScanImage,LegCImage,gr,eye(3),ImageInd,Settings,curMaterial,ImageInd);%note - sending in index of scan point for now - no PC correction!!!
    
    Settings.FCalcMethod = KeepFCalcMethod;
    
    F.b = F1;
    fitMetrics.b = fitMetrics1;
    
    [r.a, u.a] = poldec(F.a);
    [r.b, u.b] = poldec(F.b);
    [r.c, u.c] = poldec(F.c);
    
    g.a = r.a'*gr;
    g.b = r.b'*gr;
    g.c = r.c'*gr;
    
    U.a = u.a;
    U.b = u.b;
    U.c = u.c;
else
    fitMetrics = fitMetrics1;
    [r, u]=poldec(F1);
    U=u;
    R=r;
    F=r*u;
    g = R'*gr;
    U=U-eye(3); %*****used to send it back before subtracting I - is this a problem????
%     sum(sum(U.*U))
%     U(1,1)
%     U(3,3)
end

end

