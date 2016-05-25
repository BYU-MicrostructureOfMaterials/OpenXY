function IM_filt = PoissonNoise(I,lambda)
IM_filt = I .* poissrnd(lambda,size(I))/lambda;