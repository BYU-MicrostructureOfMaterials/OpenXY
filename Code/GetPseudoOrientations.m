function pseudo = GetPseudoOrientations(orientation)
g = euler2gmat(orientation(1),orientation(2),orientation(3));
R = rotation2gmat(120,[1,1,1]);
g_pseudo(:,:,1) = R*g;
g_pseudo(:,:,2) = R'*g;
[pseudo(1,1),pseudo(2,1),pseudo(3,1)] = gmat2euler(g_pseudo(:,:,1));
[pseudo(1,2),pseudo(2,2),pseudo(3,2)] = gmat2euler(g_pseudo(:,:,2));
pseudo = pseudo';
