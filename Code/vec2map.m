function [map,y] = vec2map(vec,width,Type)
switch Type
    case 'Square'
        sze = size(vec,2);
        height = length(vec)/width;

        isInteger =~ mod(height, 1); %added for issues

        if ~isInteger
            height = cast(floor(height), 'uint64'); %added this line to hopefully truncate random decimals
            %map = permute(reshape(vec(:),width,height,sze),[2 1 3]);
            len = height * width;
            vec = vec(1:len,:);
        end
        map = permute(reshape(vec(:),width,height,sze),[2 1 3]);
        y = height;
    case 'Hexagonal'
        [map, y] = Hex2Array(vec,width);
    otherwise
        error('vec2map:input', "%s is not a valid scan type.\n Expected 'Square' or 'Hexagonal'", Type);
end
