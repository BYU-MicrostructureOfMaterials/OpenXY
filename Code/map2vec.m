function vec = map2vec(map)
width = size(map,3);
vec = permute(map,[2 1 3]);
vec = reshape(vec,[],width);