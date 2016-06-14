function map = vec2map(vec,width,Type)
switch Type
    case 'Square'
        height = length(vec)/width;
        map = reshape(vec,width,height)';
    case 'Hexagonal'
        map = Hex2Array(vec,width);
end