% Copyright 2021 National Technology & Engineering Solutions of Sandia, LLC (NTESS).
% Under the terms of Contract DE-NA0003525 with NTESS, the U.S. Government retains certain rights in this software.
% Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files
% (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge,
% publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do
% so, subject to the following conditions:
% The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
% OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
% LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
% IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

function [F, g, U, fitMetrics, XX, sigma, PCnew] = GetDefGradientTensor(ImageInd,Settings,curMaterial)
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
    
    case 'Dynamic Simulated 1'
        
        mperpix = Settings.mperpix;
        
        if Settings.SinglePattern
            disp('hello')
            RefImage = Settings.RefImage;
            clear global rs cs Gs
            [F1,fitMetrics1,XX] = CalcF(RefImage,ScanImage,gr,eye(3),ImageInd,Settings,curMaterial,Settings.RefImageInd);
        else
            try
                RefImage = genEBSDPatternHybrid_fromEMSoft(gr,xstar,ystar,zstar,pixsize,mperpix,elevang,sampletilt,curMaterial,Av,ImageInd);
                clear global rs cs Gs
                [F1,fitMetrics1,XX] = CalcF(RefImage,ScanImage,gr,eye(3),ImageInd,Settings,curMaterial,0);
                % some catch on SSE as for simulated pattern approach below?
                for iq=1:Settings.IterationLimit-1
                    [rr,uu]=poldec(F1); % extract the rotation part of the deformation, rr
                    gr=rr'*gr; % correct the rotation component of the deformation so that it doesn't affect strain calc
                    RefImage = genEBSDPatternHybrid_fromEMSoft(gr,xstar,ystar,zstar,pixsize,mperpix,elevang,sampletilt,curMaterial,Av,ImageInd);
                    
                    clear global rs cs Gs
                    [F1,fitMetrics1,XX,sigma] = CalcF(RefImage,ScanImage,gr,eye(3),ImageInd,Settings,curMaterial,0);
                end
            catch ME
                F1 = eye(3);
                sigma = eye(3);
                XX(Settings.NumROIs,3) = 0;
                fitMetrics1.SSE = computations.metrics.fitMetrics;
            end
            %%%%%
        end

%         case 'Dynamic Simulated' %XASGO
%         
%         mperpix = Settings.mperpix;
%         
%         if Settings.SinglePattern
%             RefImage = Settings.RefImage;
%             clear global rs cs Gs
%             [F1,fitMetrics1,XX] = CalcF(RefImage,ScanImage,gr,eye(3),ImageInd,Settings,curMaterial,Settings.RefImageInd);
%         else
%             Qps = frameTransforms.phosphorToSample(Settings);
%             Settings.IterationOptions.numimax = 25;
%             Settings.IterationOptions.Hupdate = false;
%             Settings.IterationOptions.F_guess = eye(3);
%             Settings.IterationOptions.steptolerance = 100.0e-6;
%             Settings.ROIinfo = [.5 .5 .0 .40];
% %             try
%                 RefImage = genEBSDPatternHybrid_fromEMSoft(gr,xstar,ystar,zstar,pixsize,mperpix,elevang,sampletilt,curMaterial,Av,ImageInd);
% %                 clear global rs cs Gs
% %                 [F1,fitMetrics1,XX] = CalcF(RefImage,ScanImage,gr,eye(3),ImageInd,Settings,curMaterial,0);
%                 F1 = eye(3);
%                 % some catch on SSE as for simulated pattern approach below?
%                 for iq=1:Settings.IterationLimit-1
%                     [rr,uu]=poldec(F1); % extract the rotation part of the deformation, rr
%                     gr=rr'*gr; % correct the rotation component of the deformation so that it doesn't affect strain calc
%                     RefImage = genEBSDPatternHybrid_fromEMSoft(gr,xstar,ystar,zstar,pixsize,mperpix,elevang,sampletilt,curMaterial,Av,ImageInd);
%                     
% %                 if iq>0
% %                     Settings.IterationOptions.F_guess = (Qps')*(gr')*F1*gr*Qps;
% %                 end
%                 F1 = CalcF_Amoeba(RefImage,ScanImage, 0, ImageInd, Settings);
%                 sigma = eye(3);
%                 XX = -1 * ones(Settings.NumROIs, 3);
%                 fitMetrics1 = computations.metrics.fitMetrics;     
%                 end
% %             catch ME
% %                 F1 = eye(3);
% %                 sigma = eye(3);
% %                 XX(Settings.NumROIs,3) = 0;
% %                 fitMetrics1.SSE = computations.metrics.fitMetrics;
% %             end
%             %%%%%
%         end

    case 'Dynamic Simulated'
%         try
        
        Material = ReadMaterial(curMaterial);
        mperpix = Settings.mperpix;
        C1111=Material.C11*1e9;
        C2323=Material.C44*1e9;
        C1122=Material.C12*1e9;
        delta=eye(3);
        Cc=zeros(3,3,3,3);
        
        for i=1:3
            for j=1:3
                for k=1:3
                    for ls=1:3
                        Cc(i,j,k,ls)=C1122*delta(i,j)*delta(k,ls)+C2323*(delta(i,k)*delta(j,ls)+delta(i,ls)*delta(j,k))...
                            +(C1111-C1122-2*C2323)*(delta(1,i)*delta(1,j)*delta(1,k)*delta(1,ls)+delta(2,i)*delta(2,j)*delta(2,k)*delta(2,ls)+delta(3,i)*delta(3,j)*delta(3,k)*delta(3,ls));

                    end
                end
            end
        end
        
%         try
        
        Qps = frameTransforms.phosphorToSample(Settings);
        damper = 1;
        goodtogo = 0;
        
        Settings.IterationOptions.numimax = 20;
        Settings.IterationOptions.Hupdate = true;
        Settings.IterationOptions.F_guess = eye(3);
        Settings.IterationOptions.steptolerance = 10.0e-6;


        RefImage = genEBSDPatternHybrid_fromEMSoft(gr,xstar,ystar,zstar,pixsize,mperpix,elevang,sampletilt,curMaterial,Av,ImageInd);
        
        clear global rs cs Gs
        [F1,fitMetrics1,XX] = CalcF(RefImage,ScanImage,gr,eye(3),ImageInd,Settings,curMaterial,0);
        
%         Settings.ROIinfo = [.5 .5 .0 .40];
%         F1 = CalcF_Amoeba(RefImage,ScanImage, 0, ImageInd, Settings);
%         Settings.IterationOptions.F_guess = (Qps')*(gr')*F1*gr*Qps;
%         F1 = CalcF_XASGO(RefImage,ScanImage, 0, ImageInd, Settings);
%         sigma = eye(3);
%         XX = -1 * ones(Settings.NumROIs, 3);
%         fitMetrics1 = computations.metrics.fitMetrics;
        
        [F1,Delta] = ResolveFandDelta(F1, gr, Qps, Cc);
        xs = zeros(Settings.IterationLimit,1);
        ys = xs;
        zs = xs;
        xs(1) = xstar;
        ys(1) = ystar;
        zs(1) = zstar;
        count = 1;
        xstar = xstar - Delta(1)*zstar;
        ystar = ystar + Delta(2)*zstar;
        zstar = zstar + Delta(3)*zstar;
        
        while ~goodtogo
            for iq=1:Settings.IterationLimit-1
                count = count + 1
                xs(count) = xstar;
                ys(count) = ystar;
                zs(count) = zstar;
                [rr,uu]=poldec(F1); % extract the rotation part of the deformation, rr
                gr=rr'*gr; % correct the rotation component of the deformation so that it doesn't affect strain calc
                RefImage = genEBSDPatternHybrid_fromEMSoft(gr,xstar,ystar,zstar,pixsize,mperpix,elevang,sampletilt,curMaterial,Av,ImageInd);
%                 clear global rs cs Gs
%                 [F1,fitMetrics1,XX,sigma] = CalcF(RefImage,ScanImage,gr,eye(3),ImageInd,Settings,curMaterial,0);
                
%                 if iq>0
%                     Settings.IterationOptions.F_guess = (Qps')*(gr')*F1*gr*Qps;
%                 end
%                 Settings.ROIinfo = [.5 .5 .0 .40];
%                 F1 = CalcF_XASGO(RefImage,ScanImage, 0, ImageInd, Settings);
%                 sigma = eye(3);
%                 XX = -1 * ones(Settings.NumROIs, 3);
%                 fitMetrics1 = computations.metrics.fitMetrics;
                
                clear global rs cs Gs
                [F1,fitMetrics1,XX,sigma] = CalcF(RefImage,ScanImage,gr,eye(3),ImageInd,Settings,curMaterial,0);
                
                [F1,Delta] = ResolveFandDelta(F1, gr, Qps, Cc);
                xstar = xstar - damper*Delta(1)*zstar;
                ystar = ystar + damper*Delta(2)*zstar;
                zstar = zstar + damper*Delta(3)*zstar;
                F1 = eye(3) + damper*(F1-eye(3));
            end
            taillen = 4;
            p = polyfit(1:taillen,xs(end-taillen+1:end)',1);
            mx = p(1);
            stdx = std(xs(end-taillen+1:end));
            
            p = polyfit(1:taillen,ys(end-taillen+1:end)',1);
            my = p(1);
            stdy = std(ys(end-taillen+1:end));
            
            p = polyfit(1:taillen,zs(end-taillen+1:end)',1);
            mz = p(1);
            stdz = std(zs(end-taillen+1:end));
            
            goodtogo = 1;
        
        end
%         fitMetrics1.mx = mx;
%         fitMetrics1.my = my;
%         fitMetrics1.mz = mz;
%         fitMetrics1.fdcount = count;
        
%         figure; plot(xs);
%         figure; plot(ys);
%         figure; plot(zs);
        
        [rr,uu]=poldec(F1); % extract the rotation part of the deformation, rr
        gr=rr'*gr;
        RefImage = genEBSDPatternHybrid_fromEMSoft(gr,xstar,ystar,zstar,pixsize,mperpix,elevang,sampletilt,curMaterial,Av,ImageInd);
        RefImage = custimfilt(RefImage,9,90,0,0);



        
    case 'Simulated'
        
        %         RefImage = genEBSDPatternHybrid(gr,paramspat,eye(3),lattice,al,bl,cl,axs); % testing next line instead *****
        RefImage = genEBSDPatternHybrid(gr,paramspat,eye(3),Material.lattice,Material.a1,Material.b1,Material.c1,Material.axs);
        %          RefImage = genEBSDPatternHybridMexHat(gr,paramspat,eye(3),lattice,al,bl,cl,axs);
        
        %use following line only for optical distortion correction
        %    RefImage = RefImage(crpl:crpu,crpl:crpu);
        %         RefImage = genEBSDPattern(gr,paramspat,eye(3),lattice,al,bl,cl,axs);
        
        RefImage = custimfilt(RefImage,Settings.ImageFilter(1), ...
            Settings.PixelSize,Settings.ImageFilter(3),Settings.ImageFilter(4));

        %Initialize
        clear global rs cs Gs
        [F1,fitMetrics1,XX] = CalcF(RefImage,ScanImage,gr,eye(3),ImageInd,Settings,curMaterial,0);
        
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
            RefImage = custimfilt(RefImage,Settings.ImageFilter(1), ...
                Settings.PixelSize,Settings.ImageFilter(3),Settings.ImageFilter(4));
            
            clear global rs cs Gs
            [F1,fitMetrics1,XX,sigma] = CalcF(RefImage,ScanImage,gr,eye(3),ImageInd,Settings,curMaterial,0);
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
            if fitMetrics1.SSE > 25 % need to make this a variable in the AdvancedSettings GUI
                if ii == 1
                    display(['Didn''t make it in to the iteration loop for point ' ImageInd])
                end
                g = euler2gmat(Settings.Angles(ImageInd,1),Settings.Angles(ImageInd,2),Settings.Angles(ImageInd,3)); 
                F = -eye(3);
                fitMetrics.SSE = computations.metrics.fitMetrics;
                U = -eye(3);
                return;
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
            [F1,fitMetrics1,XX,sigma] = CalcF(NewRefImage,ScanImage,gr,FTemp,ImageInd,Settings,curMaterial,0);
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
        if Settings.RefImageInd==0
            RefImageInd = Settings.RefInd(ImageInd);
        else
            RefImageInd = Settings.RefImageInd;
        end
        RefImage = Settings.patterns.getPattern(RefImageInd);
        clear global rs cs Gs
%         disp(RefImagePath);
        gr = euler2gmat(Settings.Angles(RefImageInd,:));
        [F1,fitMetrics1,XX,sigma] = CalcFShift(RefImage,ScanImage,gr,eye(3),ImageInd,Settings,curMaterial,RefImageInd);
        
    case 'Real XASGO'
%         profile on
        %Find the grain of scan image and get the reference image for that
        %grain
        RefImageInd = Settings.RefInd(ImageInd);
        RefImage = Settings.patterns.getPattern(RefImageInd);

        gr = euler2gmat(Settings.Angles(RefImageInd,:));
        
%         [Fg,~,~,~] = CalcFShift(RefImage,ScanImage,gr,eye(3),ImageInd,Settings,curMaterial,RefImageInd);
        Qps = frameTransforms.phosphorToSample(Settings);
        Settings.IterationOptions.numimax = 15;
        Settings.IterationOptions.Hupdate = false;
        Settings.IterationOptions.F_guess = eye(3);%(Qps')*Fg*Qps;
        Settings.IterationOptions.steptolerance = 50.0e-6;
        Settings.ROIinfo = [.5 .5 .00 .40];
        try
            F1 = CalcF_XASGO(RefImage,ScanImage, RefImageInd, ImageInd, Settings);
        catch me
            F1 = -eye(3);
        end
        sigma = eye(3);
        XX = -1 * ones(Settings.NumROIs, 3);
        fitMetrics1 = computations.metrics.fitMetrics;
%         profile viewer
        
    case 'Hybrid'
        %Use simulated pattern method on one reference image then use
        %Real for all others in that grain.
    
    case 'Remapping'
        RefImageInd = Settings.RefInd(ImageInd);
        RefImage = Settings.patterns.getPattern(RefImageInd);
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
        [F1,fitMetrics1,XX,sigma] = CalcFShift(RefImage, ScanImage, gr, eye(3),...
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
    [F.a fitMetrics.a] = CalcFRuggles(ScanImage,LegAImage,gr,eye(3),ImageInd,Settings,curMaterial,ImageInd); %note - sending in index of scan point for now - no PC correction!!!
    
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

PCnew = [xstar;ystar;zstar];

end

