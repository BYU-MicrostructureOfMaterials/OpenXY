function [bedge,ledge, bscrew,lscrew,v, normals, crssfactor, type] = choosemat( mat )

if mat==1
    [bedge,ledge, bscrew,lscrew,v, normals, crssfactor, type]=mgsystems;
elseif mat==2
    [bedge,ledge, bscrew,lscrew,v, normals, crssfactor, type]=cusystems;
elseif mat==3
    [bedge,ledge, bscrew,lscrew,v, normals, crssfactor, type]=mgAsystems;
elseif mat==4
    [bedge,ledge, bscrew,lscrew,v, normals, crssfactor, type]=tasystems4;
elseif mat==5
    [bedge,ledge, bscrew,lscrew,v, normals, crssfactor, type]=tasystems3;
elseif mat==6
    [bedge,ledge, bscrew,lscrew,v, normals, crssfactor, type]=mgsystemsNoAPyram;
elseif mat==7
    [bedge,ledge, bscrew,lscrew,v, normals, crssfactor, type]=nisystems;
elseif mat==8
    [bedge,ledge, bscrew,lscrew,v, normals, crssfactor, type]=nisystemsSLICK;
elseif mat==9
    [bedge,ledge, bscrew,lscrew,v, normals, crssfactor, type]=alsystems;
else
    error('No other crystal systems defined');
end

end

