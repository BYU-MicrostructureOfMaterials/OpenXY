function [NewP] = PermuteHKL(hkl,lattice)
% Adaptation of Stuart Wright's TSL code for removing redundant symmetries
% for a given hkl.
% permutation of Miller indices according to symmetry
% The permutations correspond only to TRUE rotations
% no inversions - rotations as given in SymElements.h
% This means the sum of the # of permutations and # of
% negations must be even.
% clear all; clc;
% lattice = 'cubic'
% hkl = [1 -1 -1]

if ~strcmp(lattice,'cubic') && ~strcmp(lattice,'hexagonal')
    
    error('Permutations not supported for this crystal lattice type');
end

in = 1;

%        int i,j,k,h,l,ii,jj,kk,ll,in=0,numpossible,tag;

%        h = hkl(1); k = hkl(2); l = hkl(3); i = -(h+k);
switch (lattice)
    
    case 'cubic'
        for l = 0:5
            
            if l < 3
                i = l;
                j = mod(i+1,3);
                k = mod(i+2,3);
                ll = 1;
            else
                j = l-3;
                i = mod(j+1,3);
                k = mod(j+2,3);
                ll = -1;
            end
            
            for ii = 1:-2:-1
                for jj = 1:-2:-1
                    for kk = 1:-2:-1
                        
                        if ii*jj*kk*ll < 0
                            continue
                        end
                        p(in,1) = ii * hkl(i+1);
                        p(in,2) = jj * hkl(j+1);
                        p(in,3) = kk * hkl(k+1);
                        in = in + 1;
                        
                    end
                end
            end
        end
        NewP = unique(p,'rows');
        KeepList = [];
        if strcmp(lattice,'cubic')
            keepcnt = 1;
            for gg = 1:size(NewP,1)
                
                BadEgg = 0;
                for hh = gg+1:size(NewP,1)
                    %               [NewP(gg,:) ; NewP(hh,:)]
                    
                    if (NewP(gg,:) == -NewP(hh,:))
                        BadEgg = 1;
                    end
                end
                if ~BadEgg
                    KeepList(keepcnt) = gg;
                    keepcnt = keepcnt + 1;
                end
            end
        end
%         NewP(1:size(KeepList,1),:);% This loop doesn't apear to be doing anything
        NewP = NewP(KeepList,:);
        
        
    case 'hexagonal'
        h = hkl(1); k = hkl(2); l = hkl(3); i = -(h+k);
        p(in,1) =  h; p(in,2) =  k; p(in,3) =  l; in = in + 1;
        p(in,1) =  k; p(in,2) =  i; p(in,3) =  l; in = in + 1;
        p(in,1) =  i; p(in,2) =  h; p(in,3) =  l; in = in + 1;
        p(in,1) = -h; p(in,2) = -k; p(in,3) =  l; in = in + 1;
        p(in,1) = -k; p(in,2) = -i; p(in,3) =  l; in = in + 1;
        p(in,1) = -i; p(in,2) = -h; p(in,3) =  l; in = in + 1;
        p(in,1) =  k; p(in,2) =  h; p(in,3) = -l; in = in + 1;
        p(in,1) =  i; p(in,2) =  k; p(in,3) = -l; in = in + 1;
        p(in,1) =  h; p(in,2) =  i; p(in,3) = -l; in = in + 1;
        p(in,1) = -k; p(in,2) = -h; p(in,3) = -l; in = in + 1;
        p(in,1) = -i; p(in,2) = -k; p(in,3) = -l; in = in + 1;
        p(in,1) = -h; p(in,2) = -i; p(in,3) = -l; in = in + 1;
        
        
        SymOps = gensymopsHex;
       
        
        for jj = 1:size(p,1)
            NewP(jj,:) = squeeze(SymOps(jj,1:3,1:3))*p(jj,:)';
        end
        
        
end

%         numpossible = in;
%         in = 1;
%         for i=1:numpossible-1
%
%             tag = 0;
%             for k = 1:i
%                 if (p(k,1) == p(i,1) && p(k,2) == p(i,2) && p(k,3) == p(i,3)) ||...
%                         (p(k,1) ==-p(i,1) && p(k,2) ==-p(i,2) && p(k,3) ==-p(i,3))
%
%                     tag = 1;
%                     break;
%                 end
%                 if ~tag
%                     pp(in,:) = p(i,:);
%                     in = in + 1;
%                 end
%             end
%         end
%
%        NewP = pp;

%%

%       %%
% ORIGINAL C++ CODE
%        / permutation of Miller indices according to symmetry
% // The permutations correspond only to TRUE rotations
% // no inversions - rotations as given in SymElements.h
% // This means the sum of the # of permutations and # of
% // negations must be even.
% int CPhase::Permute(int mil[3],int p[24][3])
% {
%        int i,j,k,h,l,ii,jj,kk,ll,in=0,numpossible,tag;
%
%        h = mil[0]; k = mil[1]; l = mil[2]; i = -(h+k);
%        switch (SYMMETRY)
%        {
%                case OH:
%                        for (l=0; l<6; ++l)
%                        {
%                                if (l<3) { i=l; j=(i+1)%3; k=(i+2)%3; ll=  1; }
%                                else   { j=l-3; i=(j+1)%3; k=(j+2)%3; ll= -1; }
%                                for (ii=1; ii>=-1; ii-=2)
%                                for (jj=1; jj>=-1; jj-=2)
%                                for (kk=1; kk>=-1; kk-=2)
%                                {
%                                        if ((ii*jj*kk*ll)<0) continue;
%                                        p[in][0]=ii*mil[i];
%                                        p[in][1]=jj*mil[j];
%                                        p[in][2]=kk*mil[k];
%                                        ++in;
%                                }
%                        }
%                        break;
%                case TH:
%                        p[in][0] =  h; p[in][1] =  k; p[in][2] =  l; ++in;
%                        p[in][0] = -h; p[in][1] = -k; p[in][2] =  l; ++in;
%                        p[in][0] = -h; p[in][1] =  k; p[in][2] = -l; ++in;
%                        p[in][0] =  h; p[in][1] = -k; p[in][2] = -l; ++in;
%                        p[in][0] =  k; p[in][1] =  l; p[in][2] =  h; ++in;
%                        p[in][0] = -k; p[in][1] = -l; p[in][2] =  h; ++in;
%                        p[in][0] = -k; p[in][1] =  l; p[in][2] = -h; ++in;
%                        p[in][0] =  k; p[in][1] = -l; p[in][2] = -h; ++in;
%                        p[in][0] =  l; p[in][1] =  h; p[in][2] =  k; ++in;
%                        p[in][0] = -l; p[in][1] = -h; p[in][2] =  k; ++in;
%                        p[in][0] = -l; p[in][1] =  h; p[in][2] = -k; ++in;
%                        p[in][0] =  l; p[in][1] = -h; p[in][2] = -k; ++in;
%                        break;
%                case D4H:
%                        p[in][0] =  h; p[in][1] =  k; p[in][2] =  l; ++in;
%                        p[in][0] = -h; p[in][1] = -k; p[in][2] =  l; ++in;
%                        p[in][0] =  k; p[in][1] = -h; p[in][2] =  l; ++in;
%                        p[in][0] = -k; p[in][1] =  h; p[in][2] =  l; ++in;
%                        p[in][0] = -h; p[in][1] =  k; p[in][2] = -l; ++in;
%                        p[in][0] =  h; p[in][1] = -k; p[in][2] = -l; ++in;
%                        p[in][0] = -k; p[in][1] = -h; p[in][2] = -l; ++in;
%                        p[in][0] =  k; p[in][1] =  h; p[in][2] = -l; ++in;
%                        break;
%                case C4H:
%                        p[in][0] =  h; p[in][1] =  k; p[in][2] =  l; ++in;
%                        p[in][0] = -h; p[in][1] = -k; p[in][2] =  l; ++in;
%                        p[in][0] =  k; p[in][1] = -h; p[in][2] =  l; ++in;
%                        p[in][0] = -k; p[in][1] =  h; p[in][2] =  l; ++in;
%                        break;
%                case D2H:
%                        p[in][0] =  h; p[in][1] =  k; p[in][2] =  l; ++in;
%                        p[in][0] = -h; p[in][1] = -k; p[in][2] =  l; ++in;
%                        p[in][0] = -h; p[in][1] =  k; p[in][2] = -l; ++in;
%                        p[in][0] =  h; p[in][1] = -k; p[in][2] = -l; ++in;
%                        break;
%                case C2H_c:
%                        p[in][0] =  h; p[in][1] =  k; p[in][2] =  l; ++in;
%                        p[in][0] = -h; p[in][1] = -k; p[in][2] =  l; ++in;
%                        break;
%                case C2H_b:
%                        p[in][0] =  h; p[in][1] =  k; p[in][2] =  l; ++in;
%                        p[in][0] = -h; p[in][1] =  k; p[in][2] = -l; ++in;
%                        break;
%                case C2H_a:
%                        p[in][0] =  h; p[in][1] =  k; p[in][2] =  l; ++in;
%                        p[in][0] =  h; p[in][1] = -k; p[in][2] = -l; ++in;
%                        break;
%                case D6H:
%                        p[in][0] =  h; p[in][1] =  k; p[in][2] =  l; ++in;
%                        p[in][0] =  k; p[in][1] =  i; p[in][2] =  l; ++in;
%                        p[in][0] =  i; p[in][1] =  h; p[in][2] =  l; ++in;
%                        p[in][0] = -h; p[in][1] = -k; p[in][2] =  l; ++in;
%                        p[in][0] = -k; p[in][1] = -i; p[in][2] =  l; ++in;
%                        p[in][0] = -i; p[in][1] = -h; p[in][2] =  l; ++in;
%                        p[in][0] =  k; p[in][1] =  h; p[in][2] = -l; ++in;
%                        p[in][0] =  i; p[in][1] =  k; p[in][2] = -l; ++in;
%                        p[in][0] =  h; p[in][1] =  i; p[in][2] = -l; ++in;
%                        p[in][0] = -k; p[in][1] = -h; p[in][2] = -l; ++in;
%                        p[in][0] = -i; p[in][1] = -k; p[in][2] = -l; ++in;
%                        p[in][0] = -h; p[in][1] = -i; p[in][2] = -l; ++in;
%                        break;
%                case C6H:
%                        p[in][0] =  h; p[in][1] =  k; p[in][2] =  l; ++in;
%                        p[in][0] =  k; p[in][1] =  i; p[in][2] =  l; ++in;
%                        p[in][0] =  i; p[in][1] =  h; p[in][2] =  l; ++in;
%                        p[in][0] = -h; p[in][1] = -k; p[in][2] =  l; ++in;
%                        p[in][0] = -k; p[in][1] = -i; p[in][2] =  l; ++in;
%                        p[in][0] = -i; p[in][1] = -h; p[in][2] =  l; ++in;
%                        break;
%                case D3D:
%                        p[in][0] =  h; p[in][1] =  k; p[in][2] =  l; ++in;
%                        p[in][0] =  k; p[in][1] =  i; p[in][2] =  l; ++in;
%                        p[in][0] =  i; p[in][1] =  h; p[in][2] =  l; ++in;
%                        p[in][0] =  k; p[in][1] =  h; p[in][2] = -l; ++in;
%                        p[in][0] =  i; p[in][1] =  k; p[in][2] = -l; ++in;
%                        p[in][0] =  h; p[in][1] =  i; p[in][2] = -l; ++in;
%                        break;
%                case C3I:
%                        p[in][0] =  h; p[in][1] =  k; p[in][2] =  l; ++in;
%                        p[in][0] =  k; p[in][1] =  i; p[in][2] =  l; ++in;
%                        p[in][0] =  i; p[in][1] =  h; p[in][2] =  l; ++in;
%                        break;
%                case CIs:
%                        p[in][0] =  h; p[in][1] =  k; p[in][2] =  l; ++in;
%                        break;
%        }
%        numpossible = in;
%        in = 1;
%        for (i=1; i<numpossible; ++i)
%        {
%                tag = 0;
%                for (k=0; k<i; ++k)
%                if ((p[k][0]== p[i][0] && p[k][1]== p[i][1] && p[k][2]== p[i][2]) ||
% (p[k][0]==-p[i][0] && p[k][1]==-p[i][1] && p[k][2]==-p[i][2]))
%                {
%                        tag = 1;
%                        break;
%                }
%                if (!tag)
%                {
%                        for (j=0; j<3; ++j) p[in][j] = p[i][j];
%                        ++in;
%                }
%        }
%        return in;
% }