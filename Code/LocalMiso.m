function [misomax,miso] = LocalMiso(Angles,mapsize,lattice,map)
if nargin < 4
    map = false;
end

if length(Angles)==prod(mapsize)
    type = 'Square';
else
    type = 'Hexagonal';
end
q = euler2quat(Angles);
qmap = vec2map(q,mapsize(1),type);
top  = circshift(qmap,1,1);
bot  = circshift(qmap,-1,1);
lft  = circshift(qmap,1,2);
rht  = circshift(qmap,-1,2);
top(1,:) = Inf;
bot(end,:) = Inf;
lft(:,1) = Inf;
rht(:,end) = Inf;
top = map2vec(top,type);
bot = map2vec(bot,type);
lft = map2vec(lft,type);
rht = map2vec(rht,type);

switch lattice
    case 'cubic'
        q_symops = rmat2quat(permute(gensymops,[3 2 1]));
    case 'hexagonal'
        q_symops = rmat2quat(permute(gensymopsHex,[3 2 1]));
    case 'tetragonal'
        q_symops = rmat2quat(permute(gensymopsTet(3),[3 2 1]));
end

misotop = real(quatMisoSym(q,top,q_symops,'element'));
misobot = real(quatMisoSym(q,bot,q_symops,'element'));
misolft = real(quatMisoSym(q,lft,q_symops,'element'));
misorht = real(quatMisoSym(q,rht,q_symops,'element'));
misomax = max(misotop,misobot);
misomax = max(misomax,misolft);
misomax = max(misomax,misorht);

if map
    misomax = vec2map(misomax,mapsize(1),type);
    misotop = vec2map(misotop,mapsize(1),type);
    misobot = vec2map(misobot,mapsize(1),type);
    misolft = vec2map(misolft,mapsize(1),type);
    misorht = vec2map(misorht,mapsize(1),type);
    dims = 3;
else
    dims = 2;
end
miso = cat(dims,misotop,misobot,misolft,misorht);
