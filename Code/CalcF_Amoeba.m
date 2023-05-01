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

function F = CalcF_Amoeba(RefImage,ScanImage, RefInd, Ind, Settings)

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

if isfield(Settings,'AmoebaOptions')
    AmoebaOptions = Settings.AmoebaOptions;
else
    AmoebaOptions.F_guess = eye(3);
    AmoebaOptions.StartingStep = .05;
    AmoebaOptions.TerminationCondition = 1e-5;
    AmoebaOptions.maxfcalls = 1000;
end
if isfield(Settings,'DoShowPlot')
    AmoebaOptions.DoShowPlot = Settings.DoShowPlot;
else
    AmoebaOptions.DoShowPlot = 0;
end

F_p = OneOffAmoeba(RefPat,DefPat, ROIinfo, AmoebaOptions)
F_s = Qps*F_p*(Qps');
F = DefPat.g*F_s*(DefPat.g');

end

function [F_out] = OneOffAmoeba(RefPat,DefPat, ROIinfo, AmoebaOptions)
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

f = double(GetRefF(ROI,RefI));

f_m = mean(f);


%Unpack DefPat (start the loop here for grain level calc)
DefI = DefPat.Image;
PD = DefPat.P;

PD_p_px = PC_to_phosphor_frame(PD,m);
Delta_p_px =  PD_p_px - PR_p_px;
DeltaDD = Delta_p_px(3);
Delta_ivec = phosphor_frame_to_image_vec(Delta_p_px);

%Run calc
F_guess = AmoebaOptions.F_guess;
Fgi = rotate_to_image_frame(F_guess);
AmoebaOptions.StartingPoint = mattovec(Fgi);
Fvec = AmoebaOptPackage(DefI, pad_size, f, f_m, ROI, P_ivec, DD, Delta_ivec, DeltaDD, AmoebaOptions);
F = VR_deviatoric(vectomat(Fvec));
F_out = rotate_to_phosframe_from_image(F);

end

%% ICGN optimization
function p_old = AmoebaOptPackage(G, pad_size, f, f_m, ROI, P_ivec, DD, Delta_ivec, DeltaDD, AmoebaOptions)
%   ShowPlot = 0;
  G_coeff = calc_B_coeffs(G, pad_size);
  
  if AmoebaOptions.DoShowPlot
    g = EvaluateWarpedImagePatternDistortion_Fast_NoOB(G_coeff, ROI, eye(3), pad_size, P_ivec, DD, Delta_ivec, DeltaDD);
    g_m = mean(g);
    Plotfandg(f, f_m, g, g_m, ROI, size(G_coeff,1)-2*pad_size, 0)
  end
  fitfun = @(p) CCObjectiveFunction(p, f, f_m, G_coeff, ROI, pad_size, P_ivec, DD, Delta_ivec, DeltaDD);
  [p_old, bestFval, numfcalls] = AmoebaOpt(fitfun, AmoebaOptions);
  
  if AmoebaOptions.DoShowPlot
    g = EvaluateWarpedImagePatternDistortion_Fast_NoOB(G_coeff, ROI, p_old, pad_size, P_ivec, DD, Delta_ivec, DeltaDD);
    g_m = mean(g);
    Plotfandg(f, f_m, g, g_m, ROI, size(G_coeff,1)-2*pad_size, numfcalls)
  end
  
end

function C = CCObjectiveFunction(p, f, f_m, G_coeff, ROI, pad_size, P_ivec, DD, Delta_ivec, DeltaDD)
    g = EvaluateWarpedImagePatternDistortion_Fast_NoOB(G_coeff, ROI, p, pad_size, P_ivec, DD, Delta_ivec, DeltaDD);
    g_m = mean(g);
    C = ComputeCorrelationCriteria(f, f_m, g, g_m);
end

function C = ComputeCorrelationCriteria(f, f_m, g, g_m)
  norm_f = sum((f-f_m).^2).^0.5;
  norm_g = sum((g-g_m).^2).^0.5;
  C = 0;
  for i = 1:length(f)
    C = C + ((f(i)-f_m)/norm_f - (g(i)-g_m)/norm_g)^2;
  end
end

function C = ComputeCorrelationCriteria_Fast(f, f_m, g, g_m) %This is actually slower for some reason
  norm_f = sum((f-f_m).^2).^0.5;
  norm_g = sum((g-g_m).^2).^0.5;
  nf = (f - f_m)/norm_f;
  ng = (g - g_m)/norm_g;
  C = sum((nf - ng).^2);
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
%   figure(102)
    figure
  subplot(1,3,1); imagesc(fnsq); axis equal; axis off
  subplot(1,3,2); imagesc(gnsq); axis equal; axis off
  subplot(1,3,3); imagesc(fnsq - gnsq); axis equal; axis off
%   figure(100); imagesc(fnsq); axis equal; axis off
%   figure(101); imagesc(gnsq); axis equal; axis off
%   figure(102); imagesc(fnsq - gnsq); axis equal; axis off
  title(num_iterations)
%   figure; imagesc(fnsq./gnsq); axis equal; axis off
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

%% Quintic B-spline for pattern inerpolation
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