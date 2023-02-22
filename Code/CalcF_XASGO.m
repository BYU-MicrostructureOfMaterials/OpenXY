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

function F = CalcF_XASGO(RefImage,ScanImage, RefInd, Ind, Settings)
%disp('MADE IT INTO XASGO!!!!!!')

RefPat.Image = RefImage;
if RefInd==0
    RefPat.g = euler2gmat(Settings.Angles(Ind,1),Settings.Angles(Ind,2),Settings.Angles(Ind,3));
    RefPat.P = [Settings.XStar(Ind);Settings.YStar(Ind);Settings.ZStar(Ind)];
else
    RefPat.g = euler2gmat(Settings.Angles(RefInd,1),Settings.Angles(RefInd,2),Settings.Angles(RefInd,3));
    RefPat.P = [Settings.XStar(RefInd);Settings.YStar(RefInd);Settings.ZStar(RefInd)];
end

DefPat.Image = ScanImage;
DefPat.g = euler2gmat(Settings.Angles(Ind,1),Settings.Angles(Ind,2),Settings.Angles(Ind,3));
DefPat.P = [Settings.XStar(Ind);Settings.YStar(Ind);Settings.ZStar(Ind)];

Qps = frameTransforms.phosphorToSample(Settings);

if isfield(Settings,'ROIinfo')
    ROIinfo = Settings.ROIinfo;
else
    ROIinfo = [.5 .5 .25 .35];
end

if isfield(Settings,'IterationOptions')
    IterationOptions = Settings.IterationOptions;
else
    IterationOptions.numimax = 20;
    IterationOptions.Hupdate = false;
    IterationOptions.steptolerance = 5.0e-6;
    gD = DefPat.g;
    gR = RefPat.g;
    IterationOptions.F_guess = Qps'*gD'*gR*Qps;
end
if isfield(Settings,'DoShowPlot')
    IterationOptions.DoShowPlot = Settings.DoShowPlot;
else
    IterationOptions.DoShowPlot = 0;
end

F_p = OneOffFCalcICGN(RefPat,DefPat, ROIinfo, IterationOptions);
F_s = Qps*F_p*(Qps');
F = DefPat.g*F_s*(DefPat.g');

%Possible input options for CalcF_XASGO
%Various display options
%Do we care about pad_size?

end

function [F_out] = OneOffFCalcICGN(RefPat,DefPat, ROIinfo, IterationOptions)
%Unpack RefPat
RefI = RefPat.Image;
PR = RefPat.P;
m = min(size(RefI));
if size(ROIinfo,2)>4
    ROI = ROIinfo;
else
    ROI = AnnularROI(ROIinfo,m);%_DED
end
PR_p_px = PC_to_phosphor_frame(PR,m);
DD = PR_p_px(3);
P_ivec = phosphor_frame_to_image_vec(PR_p_px);
pad_size = 50;

%Preliminary calcs (could also be stored in RefPat)
RefI_coeff = calc_B_coeffs(RefI, pad_size);

df_ddp = GetSteepestDescentImagesPatternDistortion(RefI_coeff, ROI, pad_size, P_ivec, DD);

% f = EvaluateWarpedImagePatternDistortion_Fast(RefI_coeff, ROI, mattovec(eye(3)), pad_size, P_ivec, DD, [0;0], 0);
f = double(GetRefF(ROI,RefI));

f_m = mean(f);
hess = ComputeHessian(f, f_m, df_ddp);
% hessfast = ComputeHessian_Fast(f, f_m, df_ddp);
% disp('Hessian diff: ')
% disp(hess - hessfast)
% disp(hess)
% disp(hessfast)
% figure
% subplot(1,3,1); imagesc(hess);
% subplot(1,3,2); imagesc(hessfast)
% subplot(1,3,3); imagesc(hess - hessfast)

%Unpack DefPat (start the loop here for grain level calc)
DefI = DefPat.Image;
PD = DefPat.P;

PD_p_px = PC_to_phosphor_frame(PD,m);
Delta_p_px =  PD_p_px - PR_p_px;
DeltaDD = Delta_p_px(3);
Delta_ivec = phosphor_frame_to_image_vec(Delta_p_px);

%Run calc
F_guess = IterationOptions.F_guess;
Fgi = rotate_to_image_frame(F_guess);
numimax = IterationOptions.numimax;
Hupdate = IterationOptions.Hupdate;
steptolerance = IterationOptions.steptolerance;
Fvec = RunIcgnPatternDistortion(DefI, RefI_coeff, df_ddp, pad_size, f, f_m, hess, ROI, mattovec(Fgi), P_ivec, DD, Delta_ivec, DeltaDD, numimax, Hupdate, steptolerance, IterationOptions.DoShowPlot);
F = VR_deviatoric(vectomat(Fvec));
F_out = rotate_to_phosframe_from_image(F);

end

%% ICGN optimization
function p_old = RunIcgnPatternDistortion(G, F_coeff, df_ddp, pad_size, f, f_m, hess, ROI, initial_guess_M, P_ivec, DD, Delta_ivec, DeltaDD, numimax, Hupdate, steptolerance, ShowPlot)
%   # notation:
%   # F: intensity of entire undeformed image
%   # G: intensity of entire deformed image
%   # F_coeff: biquintic spline coefficients of entire undeformed image
%   # G_coeff: biquintic spline coefficients of entire deformed image
%   # ROI: region of interest (nx2 array of x,y locations)
%   # ROIrelative: region of interest described relative to center of ROI
%   # ref_c: [x, y] location of center of ROI in reference image
%   # f: intensity of ROI in undeformed image
%   # g: intensity of ROI in deformed image
%   # p: vector of deformations to be solved for
%   ShowPlot = 0;
  p_old = initial_guess_M;
  G_coeff = calc_B_coeffs(G, pad_size);
  converged = false;
  num_iterations = 0;
  pprog = zeros(9,numimax+1);
  g = EvaluateWarpedImagePatternDistortion_Fast_NoOB(G_coeff, ROI, p_old, pad_size, P_ivec, DD, Delta_ivec, DeltaDD);
%   gfast = EvaluateWarpedImagePatternDistortion_Fast(G_coeff, ROI, p_old, pad_size, P_ivec, DD, Delta_ivec, DeltaDD);
%   Plotfandg(gfast, mean(gfast), g, mean(g), ROI, size(G_coeff,1)-2*pad_size)
%   CC_initial = ComputeCorrelationCriteria(f, f_m, g, mean(g))
%   Plotfandg(f, f_m, g, mean(g), ROI, size(G_coeff,1)-2*pad_size)
%     if ShowPlot
%       Plotdfddp(df_ddp, ROI, size(G_coeff,1)-2*pad_size)
%     end
  if ~isempty(g)
      g_m = mean(g);
      grad = ComputeGradient_Fast(f, f_m, g, g_m, df_ddp);
      if ShowPlot
        gradmap = ComputeGradientMap(f, f_m, g, g_m, df_ddp);
        Plotdfddp(gradmap, ROI, size(G_coeff,1)-2*pad_size)
      end

      
%       gradfast = ComputeGradient_Fast(f, f_m, g, g_m, df_ddp);
%       
%       disp('Grad diff: ')
%       disp(grad - gradfast)

      if ShowPlot
          Plotfandg(f, f_m, g, mean(g), ROI, size(G_coeff,1)-2*pad_size, num_iterations)
      end
      failtoconverge = false;
      while ~converged && num_iterations < numimax

        num_iterations = num_iterations + 1;
        pprog(:,num_iterations) = p_old - [1 0 0 0 1 0 0 0 1];

        dp = hess\(-grad);
%         dpmat = vectomat(dp)
        p_new = UpdatePPatternDistortion(p_old, dp);
        converged = (norm(p_new - p_old) < steptolerance);

        if ~converged
            g = EvaluateWarpedImagePatternDistortion_Fast_NoOB(G_coeff, ROI, p_new, pad_size, P_ivec, DD, Delta_ivec, DeltaDD);
            if isempty(g)
                failtoconverge = true;
                break
            end
            g_m = mean(g);
            grad_new = ComputeGradient_Fast(f, f_m, g, g_m, df_ddp);
            if ShowPlot
                gradmap = ComputeGradientMap(f, f_m, g, g_m, df_ddp);
                Plotdfddp(gradmap, ROI, size(G_coeff,1)-2*pad_size)
            end
            if Hupdate
                hess = BFGSupdate(hess, grad_new, grad, dp, zeros(size(dp)));
            end
            p_old = p_new;
            grad = grad_new;
            if ShowPlot
                Plotfandg(f, f_m, g, g_m, ROI, size(G_coeff,1)-2*pad_size, num_iterations)
            end
        end
      end
%       if num_iterations > 1
%         disp(["Number of iterations: " num2str(num_iterations)])
%       end
      pprog(:,num_iterations+1) = p_old - [1 0 0 0 1 0 0 0 1];
      if failtoconverge || ~converged
          [failtoconverge converged]
          p_old = [2 1 1 1 2 1 1 1 2];
      end
  else
     p_old = [2 1 1 1 2 1 1 1 2];
  end
  figure(104); plot(pprog(:,1:num_iterations+1)')
  drawnow
%     CC_final = ComputeCorrelationCriteria(f, f_m, g, g_m)
%     Plotfandg(f, f_m, g, mean(g), ROI, size(G_coeff,1)-2*pad_size)
%     betafinalvec = p_old - [1 0 0 0 1 0 0 0 1]
  
end

function gradient = ComputeGradient(f, f_m, g, g_m, df_ddp)
  len_p = size(df_ddp,1);
  gradient = zeros(len_p,1);
  norm_f = sum((f-f_m).^2)^0.5;
  norm_g = sum((g-g_m).^2)^0.5;
  for i = 1:length(f)
    gradient = gradient + ((f(i)-f_m)/norm_f - (g(i)-g_m)/norm_g)* df_ddp(:,i);
  end
  gradient = gradient*2/norm_f;
end

function gradient = ComputeGradient_Fast(f, f_m, g, g_m, df_ddp)
  norm_f = sum((f-f_m).^2)^0.5;
  norm_g = sum((g-g_m).^2)^0.5;
  gradient = sum(df_ddp.*((f - f_m)/norm_f - (g - g_m)/norm_g),2)*2/norm_f;
end

function gradientmap = ComputeGradientMap(f, f_m, g, g_m, df_ddp)
  norm_f = sum((f-f_m).^2)^0.5;
  norm_g = sum((g-g_m).^2)^0.5;
  gradientmap = df_ddp.*((f - f_m)/norm_f - (g - g_m)/norm_g)*2/norm_f;
end

function hessian = ComputeHessian(f, f_m, df_ddp)
  len_p = size(df_ddp,1);
  hessian = zeros(len_p,len_p);
  for i = 1:length(f)
    hessian = hessian +  df_ddp(:,i) * df_ddp(:,i)';
  end
  hessian = hessian* 2.0 / sum((f-f_m).^2);
%   hessian =  factorize(hessian)
end

function hessian = ComputeHessian_Fast(f, f_m, df_ddp)
  hessian = df_ddp*(df_ddp');
  hessian = hessian* 2.0 / sum((f-f_m).^2);
end

function C = ComputeCorrelationCriteria(f, f_m, g, g_m)
  norm_f = sum((f-f_m).^2).^0.5;
  norm_g = sum((g-g_m).^2).^0.5;
  C = 0;
  for i = 1:length(f)
    C = C + ((f(i)-f_m)/norm_f - (g(i)-g_m)/norm_g)^2;
  end
end

function Plotfandg(f, f_m, g, g_m, ROI, m, num_iterations)
  norm_f = sum((f-f_m).^2).^0.5;
  norm_g = sum((g-g_m).^2).^0.5;
  fn = (f - f_m)/norm_f;
  gn = (g - g_m)/norm_g;
  ROIInd = sub2ind([m m],ROI(1,:),ROI(2,:));
  fnsq = zeros(m,m);
  fnsq(ROIInd) = fn;
  gnsq = zeros(m,m);
  gnsq(ROIInd) = gn;
  figure(102)
  subplot(1,3,1); imagesc(fnsq); axis equal; axis off
  subplot(1,3,2); imagesc(gnsq); axis equal; axis off
  subplot(1,3,3); imagesc(fnsq - gnsq); axis equal; axis off
%   figure(100); imagesc(fnsq); axis equal; axis off
%   figure(101); imagesc(gnsq); axis equal; axis off
%   figure(102); imagesc(fnsq - gnsq); axis equal; axis off
  title(num_iterations)
%   figure; imagesc(fnsq./gnsq); axis equal; axis off
end

function Plotdfddp(df_ddp, ROI, m)
  ROIInd = sub2ind([m m],ROI(1,:),ROI(2,:));
  figure(103);
%   figure
  for i=1:9
      subplot(3,3,i)
      fnsq = zeros(m,m);
      fnsq(ROIInd) = df_ddp(i,:);
      imagesc(fnsq);
      caxis(.3e-3*[-1 1])
      axis equal
      axis off
  end
end

function im = EvaluateWarpedImagePatternDistortion(F, ROIabsolute, p, pad_size, P_ivec, DD, Delta_ivec, DeltaDD)
  M = VR_deviatoric(vectomat(p));
  xs = [ROIabsolute(1,:)-P_ivec(1); ROIabsolute(2,:)-P_ivec(2)];
  ROI = zeros(size(ROIabsolute));
  mn = size(F);
  boundx = mn(1) - 2*pad_size;
  boundy = mn(2) - 2*pad_size;
  outofbounds = false;
  for i=1:size(ROIabsolute,2)
    x = xs(:,i);
    Mr = M*[x(1);x(2);-DD];
    ROInew = P_ivec + Delta_ivec - Mr(1:2)*(DD + DeltaDD)/Mr(3);
    ROI(:,i) = ROInew';
    if ~(boundx > ROInew(1) && ROInew(1) > 1) || ~(boundy > ROInew(2) && ROInew(2) > 1)
        outofbounds = true;
    end
  end
%   figure; plot(ROIabsolute(1,:),ROIabsolute(2,:),'.'); axis equal
%   hold on
%   plot(ROI(1,:),ROI(2,:),'r.')
  if ~outofbounds
      im = SplineEvaluate(F, ROI, pad_size);
  else
      disp('Out of Bounds on the spline there')
      im = [];
  end
end

function im = EvaluateWarpedImagePatternDistortion_Fast(F, ROIabsolute, p, pad_size, P_ivec, DD, Delta_ivec, DeltaDD)
  M = VR_deviatoric(vectomat(p));
  xs = [ROIabsolute(1,:)-P_ivec(1); ROIabsolute(2,:)-P_ivec(2)];
  mn = size(F);
  boundx = mn(1) - 2*pad_size;
  boundy = mn(2) - 2*pad_size;
  
  Mr = M*[xs;-DD*ones(1,size(xs,2))];
  ROI = P_ivec + Delta_ivec - Mr(1:2,:)*(DD + DeltaDD)./Mr(3,:);
  
  maxX = max(ROI(1,:));
  minX = min(ROI(1,:));
  maxY = max(ROI(2,:));
  minY = min(ROI(2,:));
  outofbounds = (minY < 1) || (minX < 1) || (maxY > boundy) || (maxX > boundx);
  if ~outofbounds
      im = SplineEvaluate_Fast(F, ROI, pad_size);
  else
      disp('Out of Bounds on the spline there')
      im = [];
  end
end

function im = EvaluateWarpedImagePatternDistortion_Fast_NoOB(F, ROIabsolute, p, pad_size, P_ivec, DD, Delta_ivec, DeltaDD)
  M = VR_deviatoric(vectomat(p));
  xs = [ROIabsolute(1,:)-P_ivec(1); ROIabsolute(2,:)-P_ivec(2)];
  mn = size(F);
  boundx = mn(1) - 2*pad_size;
  boundy = mn(2) - 2*pad_size;
  
  Mr = M*[xs;-DD*ones(1,size(xs,2))];
  ROI = P_ivec + Delta_ivec - Mr(1:2,:)*(DD + DeltaDD)./Mr(3,:);
  
  outbounds = (ROI(1,:) < 1) | (ROI(2,:) < 1) | (ROI(1,:) > boundx) | (ROI(2,:) > boundy);
  inbounds = 1 - outbounds;
%   figure; plot(ROI(1,inbounds), ROI(2,inbounds),'.')
  im(:,inbounds==1) = SplineEvaluate_Fast(F, ROI(:,inbounds==1), pad_size);
  im(:,outbounds==1) = -1;
end

function f = GetRefF(ROI,RefPat)
    inds = sub2ind(size(RefPat),ROI(1,:),ROI(2,:));
    f = RefPat(inds);
end


function df_ddp = GetSteepestDescentImagesPatternDistortion(F_coeff, ROIabsolute, pad_size, P_ivec, DD)
  df_ddp = zeros(9, size(ROIabsolute, 2));
  
  x = [ROIabsolute(1,:)-P_ivec(1); ROIabsolute(2,:)-P_ivec(2)];

  df_dxy = SplineDerivative_Fast(F_coeff, ROIabsolute, pad_size);
%   df_dxyfast = SplineDerivative_Fast(F_coeff, ROIabsolute, pad_size);
%   figure; plot(df_dxy(1,:),df_dxy(2,:),'.')
%   figure; plot(df_dxyfast(1,:),df_dxyfast(2,:),'.')
  
  f1 = df_dxy(1,:);
  f2 = df_dxy(2,:);
  df_ddp(1,:) = f1.*x(1,:);
  df_ddp(2,:) = f1.*x(2,:);
  df_ddp(3,:) = -DD*f1;
  df_ddp(4,:) = f2.*x(1,:);
  df_ddp(5,:) = f2.*x(2,:);
  df_ddp(6,:) = -DD*f2;
  df_ddp(7,:) = (f1.*x(1,:) + f2.*x(2,:)).*x(1,:)/DD;
  df_ddp(8,:) = (f1.*x(1,:) + f2.*x(2,:)).*x(2,:)/DD;
  df_ddp(9,:) = -f1.*x(1,:) - f2.*x(2,:);
end

function p_new = UpdatePPatternDistortion(p_old, dp)
  M = vectomat(p_old);
  I = eye(size(M,1));
  dM = VR_deviatoric(vectomat(dp)+I);
  p_new = mattovec(VR_deviatoric(M*inv(dM)));
end


function Bkp1 = BFGSupdate(Bk, gradkp1, gradk, xkp1, xk)
  yk = gradkp1 - gradk;
  sk = xkp1 - xk;
  Bkp1 = Bk + (yk*yk')/(yk'*sk) - Bk*(sk*sk')*Bk/(sk'*Bk*sk);
end

%% Quintic B-spline for pattern inerpolation
function f = SplineEvaluate(B_coeff, ROI, pad_size)
  QK = get_QK();
  f = zeros(1,size(ROI,2));
  for i = 1:size(ROI,2)
    x_floor = (floor(ROI(:,i)));
    dx = ROI(1,i) - x_floor(1);
    dy = ROI(2,i) - x_floor(2);
  
    dx_vec = dx.^(0:5)';
    dy_vec = dy.^(0:5)';

    c = B_coeff(pad_size + x_floor(1)-2:pad_size + x_floor(1) + 3,...
                pad_size + x_floor(2)-2:pad_size + x_floor(2) + 3)';
    f(i) = dy_vec' * QK * c * QK' * dx_vec;
  end
end
function f = SplineEvaluate_Fast(B_coeff, ROI, pad_size)

    QK = get_QK();
  
    xlm = zeros(6,size(ROI,2));
    yim = xlm;
    
    xlm(1,:) = 1.0;
    xlm(2,:) = ROI(1,:) - floor(ROI(1,:));
    xlm(3,:) = xlm(2,:).*xlm(2,:);
    xlm(4,:) = xlm(3,:).*xlm(2,:);
    xlm(5,:) = xlm(4,:).*xlm(2,:);
    xlm(6,:) = xlm(5,:).*xlm(2,:);
    
    yim(1,:) = 1.0;
    yim(2,:) = ROI(2,:) - floor(ROI(2,:));
    yim(3,:) = yim(2,:).*yim(2,:);
    yim(4,:) = yim(3,:).*yim(2,:);
    yim(5,:) = yim(4,:).*yim(2,:);
    yim(6,:) = yim(5,:).*yim(2,:);
    
    Ajm = (QK')*yim;
    Bkm = (QK')*xlm;
    
%     Cjkm = zeros(6,6,size(ROI,2));
    mn = size(B_coeff);    
    f = 0;
    for k=1:6
        xs = pad_size + floor(ROI(1,:)) + k - 3;
        for j=1:6
            ys = pad_size + floor(ROI(2,:)) + j - 3;
            inds = sub2ind(mn,xs,ys);
%             Cjkm(k,j,:) = B_coeff(inds);
            thisC = B_coeff(inds);
%             f = f + Ajm(j,:).*(squeeze(Cjkm(k,j,:)))'.*Bkm(k,:);
            f = f + Ajm(j,:).*(thisC).*Bkm(k,:);
        end
    end    
end

function df = SplineDerivative(B_coeff, ROI, pad_size)
  QK = get_QK();
  df = zeros(size(ROI));
  vec1 = zeros(6,1);
  vec1(1) = 1;
  vec2 = zeros(6,1);
  vec2(2) = 1;
  for i = 1:size(ROI,2)
    x_floor = (floor(ROI(:,i)));

    c = B_coeff(pad_size + x_floor(1)-2:pad_size + x_floor(1) + 3, ...
        pad_size + x_floor(2)-2:pad_size + x_floor(2) + 3)';
    df(1,i) = (vec1' * QK * c * QK' * vec2)';
    df(2,i) = (vec2' * QK * c * QK' * vec1)';
  end
end

function df = SplineDerivative_Fast(B_coeff, ROI, pad_size)
    QK = get_QK();
    df = zeros(size(ROI));
    vec1 = zeros(6,1);
    vec1(1) = 1;
    vec2 = zeros(6,1);
    vec2(2) = 1;
    mn = size(B_coeff);
    A = (QK')*vec1;
    B = (QK')*vec2;
    f1 = 0;
    f2 = 0;
    for k=1:6
        xs = pad_size + floor(ROI(1,:)) + k - 3;
        for j=1:6
            ys = pad_size + floor(ROI(2,:)) + j - 3;
            inds = sub2ind(mn,xs,ys);
            thisC = B_coeff(inds);
            f1 = f1 + A(j)*thisC*B(k);
            f2 = f2 + B(j)*thisC*A(k);
        end
    end
    df = zeros(size(ROI));
    df(1,:) = f1;
    df(2,:) = f2;
end

function B = calc_B_coeffs(I,padding)
  PI = pad_image_w_border(I,padding);
  mn = size(PI);
  FKr = sample_quintic_kernel(mn(2));
  rB = convolve_for_spline_coeffs(PI, FKr);
  FKc = sample_quintic_kernel(mn(1));
  B = convolve_for_spline_coeffs(rB',FKc)';
end

function B = convolve_for_spline_coeffs(I, FK)
  mn = size(I);
  B = zeros(mn(1),mn(2));
  thisrow = zeros(1,mn(2));
  for i=1:mn(1)
    thisrow(1,:) = fft(I(i,:));
    B(i,:) = real(ifft(thisrow./FK));
  end
end

% function B = convolve_for_spline_coeffs_Fast(I, FK)
%     B = real(ifft(fft(I')./FK))';%This is wrong AND slower.  Dead end.
% end

function kernel = sample_quintic_kernel(N)
  kernel =  fft([11/20  13/60 1/120 0 zeros(1,N-6) 1/120 13/60 ]);
end

function QK = get_QK()
  QK = [1/120 13/60 11/20 13/60 1/120 0;
        -1/24 -5/12 0 5/12 1/24 0;
        1/12 1/6 -1/2 1/6 1/12 0;
        -1/12 1/6 0 -1/6 1/12 0
        1/24 -1/6 1/4 -1/6 1/24 0;
        -1/120 1/24 -1/12 1/12 -1/24 1/120];
end

function PI = pad_image_w_border(I,padding)
  mn = size(I);
  PI = zeros(mn(1)+2*padding, mn(2)+2*padding);
  PI(padding+1:padding+mn(1),padding+1:padding+mn(2)) = I;
  for i=1:padding
    PI(padding+1:padding+mn(1),i) = I(1:end,1);
    PI(padding+1:padding+mn(1),padding + mn(2) + i) = I(1:end,end);
  end
  for i=1:padding
    PI(i,:) = PI(padding+1,1:end);
    PI(padding + mn(1) + i,:) = PI(padding+mn(1),1:end);
  end
end

%% Reference frame transformations
function P_p = PC_to_phosphor_frame(P,m)
P_p = -m*[P(1);1-P(2); -P(3)];
end

function Iv = phosphor_frame_to_image_vec(Pv)
  Iv = [-Pv(2);-Pv(1)];
end

function Mi = rotate_to_image_frame(Mp)
  Qfix = [0 -1 0;-1 0 0;0 0 1];
  Mi = Qfix*Mp*(Qfix');
end

function Mp = rotate_to_phosframe_from_image(Mi)
  Qfix = [0 -1 0;-1 0 0;0 0 1];
  Mp = (Qfix')*Mi*Qfix;
end

%% Support functions
function ROI = AnnularROI(ROIinfo,m)
%ROIinfo contains the center point, inner and outer radius of the ROI in
%units of detector width.  m is the width of the detector in pixels
CenterPoint = round(m*[ROIinfo(1) ROIinfo(2)]);
Ri = m*ROIinfo(3);
Ro = m*ROIinfo(4);
Ro2 = Ro*Ro;
Ri2 = Ri*Ri;
count = 0;
ROI = zeros(2,ceil(1.1*pi*(Ro2-Ri2))+1);
for i=floor(CenterPoint(1)-Ro):ceil(CenterPoint(1) + Ro)
    i2 = (i-CenterPoint(1))*(i-CenterPoint(1));
    for j=floor(CenterPoint(2)-Ro):ceil(CenterPoint(2) + Ro)
        r2 = (i2 + (j-CenterPoint(2))*(j-CenterPoint(2)));
        if (Ro2 > r2) && (r2 > Ri2)
            count = count + 1;
            ROI(1,count) = i;
            ROI(2,count) = j;
        end
    end
end
ROI = ROI(:,1:count);
end

function ROI = AnnularROI_DED(ROIinfo,m)
%ROIinfo contains the center point, inner and outer radius of the ROI in
%units of detector width.  m is the width of the detector in pixels
CenterPoint = round(m*[ROIinfo(1) ROIinfo(2)]);
Ri = m*ROIinfo(3);
Ro = m*ROIinfo(4);
Ro2 = Ro*Ro;
Ri2 = Ri*Ri;
count = 0;
ROI = zeros(2,ceil(1.1*pi*(Ro2-Ri2))+1);
crossmin = round(.45*m);
crossmax = round(.55*m);
for i=floor(CenterPoint(1)-Ro):ceil(CenterPoint(1) + Ro)
    i2 = (i-CenterPoint(1))*(i-CenterPoint(1));
    for j=floor(CenterPoint(2)-Ro):ceil(CenterPoint(2) + Ro)
        r2 = (i2 + (j-CenterPoint(2))*(j-CenterPoint(2)));
        if (Ro2 > r2) && (r2 > Ri2)
            if ~((i>crossmin)&&(i<crossmax)) && ~((j>crossmin)&&(j<crossmax))
                count = count + 1;
                ROI(1,count) = i;
                ROI(2,count) = j;
            end
        end
    end
end
ROI = ROI(:,1:count);
end

function v =mattovec(M)
  v = [M(1,1),M(1,2),M(1,3),M(2,1),M(2,2),M(2,3),M(3,1),M(3,2),M(3,3)];
end

function M = vectomat(v)
  M = [v(1) v(2) v(3);v(4) v(5) v(6);v(7) v(8) v(9)];
end

function [V,R] = VR_poldec(A)
  %Assume square matrix
  [U,S,V] = svd(A);
  R = U*(V');
  V = U*S*(U');
end

function A_deviatoric = VR_deviatoric(A)
  [V,R] = VR_poldec(A);
  I = eye(size(A,1));
  A_deviatoric =  (I + V - trace(V)*I./3.0)*R;
end