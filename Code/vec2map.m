function map = vec2map(vec,width,Type)
switch Type
    case 'Square'
        sze = size(vec,2);
        height = length(vec)/width;
        map = permute(reshape(vec(:),width,height,sze),[2 1 3]);
    case 'Hexagonal'
        map = Hex2Array(vec,width);
    otherwise
        error('vec2map:input', "%s is not a valid scan type.\n Expected 'Square' or 'Hexagonal'", Type);
end
