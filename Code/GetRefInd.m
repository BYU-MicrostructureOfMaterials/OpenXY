function RefInd = GetRefInd(Inds,IQ,Fit,CI)
[MaxCI,CIInd] = max(CI(Inds));
[MaxIQ,IQInd] = max(IQ(Inds));
[MinFit,FitInd] = min(Fit(Inds));

MinFitTradeOff = MaxIQ/IQ(Inds(FitInd)) + MaxCI/CI(Inds(FitInd));
MaxCITradeOff = Fit(Inds(CIInd))/MinFit + MaxIQ/IQ(Inds(CIInd));
MaxIQTradeOff = Fit(Inds(IQInd))/MinFit + MaxCI/CI(Inds(IQInd));

Votes = [CIInd FitInd IQInd];
[~, VoteInd] = min([MaxCITradeOff MinFitTradeOff MaxIQTradeOff]);

BestInd = Votes(VoteInd);
RefInd = Inds(BestInd);