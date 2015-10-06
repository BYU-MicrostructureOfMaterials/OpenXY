function [rho]=resolvedislocBritton(alphavec,threeorsix, minscheme,matchoose,gmat, L1, x0type)
% if alphaorbeta==1 then the algorithm will try and match the final column of alpha, and alpha is input in form
% [alpha(1,3);alpha(2,3);alpha(3,3)]
% otherwise the algorithm will try and match the measurable betas and beta is input in form
% [beta(1,1),2;beta(1,2),1;beta(1,3),1;beta(1,3),2;beta(2,1),2;beta(2,2),1;beta(2,3),1;beta(2,3),2;beta(3,1),2;beta(3,2),1;beta(3,3),1;beta(3,3),2]

[bedge,ledge, bscrew,lscrew,v, normals, crssfactor, type] = choosemat(matchoose);

% b=[bscrew;bedge];
% l=[lscrew;ledge];
b=[bscrew;bedge];
l=[lscrew;ledge];
b=b*gmat; % rotate into sample frame
l=l*gmat;
nedge=length(bedge);
ntypes=length(b); % number of dislocation types



if threeorsix==1
    A=zeros(6,ntypes);
    for i=1:ntypes
        A(1:3,i)=b(i,:)*l(i,3);
        A(4,i) = b(i,1)*l(i,2);
        A(5,i) = b(i,2)*l(i,1);
        A(6,i) = (b(i,1)*l(i,1) - b(i,2)*l(i,2));
    end

    A = [A -A];

else
    A = zeros(3,ntypes);
    for i=1:ntypes
        A(1:3,i)=b(i,:)*l(i,3);

    end

    A = [A -A];
    
end


if L1

    % minimizer=ones(1,2*ntypes);

    switch minscheme
        case 1 % minimize total dislocation density
            minimizer=ones(1,2*ntypes);
        case 2  % minimize energy in dislocations
            minimizer=sum(b.^2,2)'; %use squared-norm of each burger's vector
            bavg = norm(shiftdim(b(1,:)));
            minimizer = minimizer/bavg^2;
            energy = [ones(1,ntypes-nedge) (1/(1-v))*ones(1,nedge)];
            minimizer = minimizer.*energy;
            minimizer = [minimizer minimizer];
        case 3  % use CRSS of each system
            minimizer=crssfactor';
            minimizer = [minimizer minimizer];
        otherwise
            error('only types 1-3 defined')
    end

    options = optimset('TolCon', 1e3, 'Algorithm', 'active-set', 'display','off');%'MaxFunEvals',3000, 

    
    if x0type
        x0 = A\alphavec;
    else
        x0 = zeros(length(minimizer),1);
    end

    rhopm = linprog(minimizer,[],[],A,alphavec,zeros(2*ntypes,1),1e16*ones(2*ntypes,1), x0, options);


    
    
else
    rhopm = A\alphavec;

end

rho = rhopm(1:ntypes) - rhopm(ntypes+1:2*ntypes);
