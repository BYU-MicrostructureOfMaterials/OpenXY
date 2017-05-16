function vec = map2vec(map,Type)
if strcmp(Type,'Square')
    width = size(map,3);
    vec = permute(map,[2 1 3]);
    vec = reshape(vec,[],width);
else
    vec = Array2Hex(map);
end