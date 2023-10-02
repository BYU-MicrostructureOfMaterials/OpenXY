function [bedge,ledge, bscrew,lscrew,v, normals, crssfactor, type] = choosemat( mat )
switch mat
    case 'Mg'
        [bedge,ledge, bscrew,lscrew,v, normals, crssfactor, type]=mgsystems;
    case 'Ti'
        [bedge,ledge, bscrew,lscrew,v, normals, crssfactor, type]=tisystems;
    case 'Cu'
        [bedge,ledge, bscrew,lscrew,v, normals, crssfactor, type]=cusystems;
    case 'Mg (a systems only)'
        [bedge,ledge, bscrew,lscrew,v, normals, crssfactor, type]=mgAsystems;
    case 'Ta'
        [bedge,ledge, bscrew,lscrew,v, normals, crssfactor, type]=tasystems4;
    case 'Ta (with 112 planes)'
        [bedge,ledge, bscrew,lscrew,v, normals, crssfactor, type]=tasystems3;
    case 'Mg(no a-pyram)'
        [bedge,ledge, bscrew,lscrew,v, normals, crssfactor, type]=mgsystemsNoAPyram;
    case 'Ni'
        [bedge,ledge, bscrew,lscrew,v, normals, crssfactor, type]=nisystems;
    case 'Ni(18ss)'
        [bedge,ledge, bscrew,lscrew,v, normals, crssfactor, type]=nisystemsSLICK;
    case 'Al-18ss'
        [bedge,ledge, bscrew,lscrew,v, normals, crssfactor, type]=alsystems;
    case 'Fe'
        [bedge,ledge, bscrew,lscrew,v, normals, crssfactor, type]=ferritesystems;
    case 'Zr'
        [bedge,ledge, bscrew,lscrew,v, normals, crssfactor, type]=zrsystems;
    otherwise
        error('No other crystal systems defined');
end
end
