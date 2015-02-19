% resolve dislocation density onto the actual crystal slip systems
% from dislocSep2c_a_dec13.m
% dtf 7/1/11
function [rho]=resolvedisloc(alphabeta,alphaorbeta,minscheme,matchoose,gmat,stress,smeararea, x0type)
% if alphaorbeta==1 then the algorithm will try and match the final column of alpha, and alpha is input in form
% [alpha(1,3);alpha(2,3);alpha(3,3)]
% otherwise the algorithm will try and match the measurable betas and beta is input in form
% [beta(1,1),2;beta(1,2),1;beta(1,3),1;beta(1,3),2;beta(2,1),2;beta(2,2),1;beta(2,3),1;beta(2,3),2;beta(3,1),2;beta(3,2),1;beta(3,3),1;beta(3,3),2]

[bedge,ledge, bscrew,lscrew,v, normals, crssfactor, type] = choosemat(matchoose);

% b=[bscrew;bedge];
% l=[lscrew;ledge];
b=[bscrew;bedge];
l=[lscrew;ledge];
crssfactor=[crssfactor;crssfactor];
b=b*gmat; % rotate into sample frame
l=l*gmat;
nedge=length(bedge);
ntypes=length(b); % number of dislocation types

min_e=1;
beta_e = 0;

if alphaorbeta==1 % use only alpha components in resolution scheme
    A=zeros(3,ntypes);
    for i=1:ntypes
        A(:,i)=b(i,:)*l(i,3);
        
    end
    %appxbulkrho = sum(abs(alphabeta))*3/mean(bnorms);

elseif alphaorbeta==2
    beta_e = 1;
    A=zeros(12,ntypes);
    disldist=sqrt(smeararea);%sqrt(smeararea);  % assumed dislocation region size (distance between dislocations) ****** need to think about this
    %step=1e-9+1e-15;  %step size for numerical derivative of betas; add small offset to prevent NaN in integral
    step=disldist/2 - 1e-15;
    for i=1:ntypes
        if i<=(ntypes - nedge)
            edge=0;
        else
            edge=1;
        end
        thisb=b(i,:);
        thisl=l(i,:);
        betaderiv1=(betanalcont(thisb',thisl',disldist,edge,v,[step;0;0])-betanalcont(thisb',thisl',disldist,edge,v,[-step;0;0]))/(2*step); % beta derivatives in 1 direction (betas (distortions) using equations from Lazar)
        betaderiv2=(betanalcont(thisb',thisl',disldist,edge,v,[0;step;0])-betanalcont(thisb',thisl',disldist,edge,v,[0;-step;0]))/(2*step); % beta derivatives in 2 direction (betas (distortions) using equations from Lazar)

%         betaderiv1=(antisymmpart(betanalcont(thisb',thisl',disldist,edge,v,[step;0;0]))-antisymmpart(betanalcont(thisb',thisl',disldist,edge,v,[-step;0;0])))/(2*step); % omega only
%         betaderiv2=(antisymmpart(betanalcont(thisb',thisl',disldist,edge,v,[0;step;0]))-antisymmpart(betanalcont(thisb',thisl',disldist,edge,v,[0;-step;0])))/(2*step); % omega only
        A(1,i)=betaderiv2(1,1);
        A(2,i)=betaderiv1(1,2);
        A(3,i)=betaderiv1(1,3);
        A(4,i)=betaderiv2(1,3);
        A(5,i)=betaderiv2(2,1);
        A(6,i)=betaderiv1(2,2);
        A(7,i)=betaderiv1(2,3);
        A(8,i)=betaderiv2(2,3);
        A(9,i)=betaderiv2(3,1);
        A(10,i)=betaderiv1(3,2);
        A(11,i)=betaderiv1(3,3);
        A(12,i)=betaderiv2(3,3);
        
        
    end
    %d = alphabeta;
    %appxbulkrho = 1.5*(abs(d(4)) + abs(d(8)) + abs(d(12)) + abs(d(3)) + abs(d(7)) + abs(d(11)) + abs(d(1)-d(2)) + abs(d(5)-d(6)) + abs(d(10)-d(9)));

elseif alphaorbeta==3
    A=zeros(5,ntypes);
    for i=1:ntypes
        A(1:3,i)=b(i,:)*l(i,3);
        A(4,i) = b(i,1)*l(i,2);
        A(5,i) = b(i,2)*l(i,1);
    end
    %appxbulkrho = sum(abs(alphabeta))*(15/7)/mean(bnorms);
elseif alphaorbeta==4
    A=zeros(9,ntypes);
    for i=1:ntypes
        A(1:3,i)= b(i,:)*l(i,3);
        A(4:6,i) = b(i,:)*l(i,2);
        A(7:9,i) = b(i,:)*l(i,1);
    end
elseif alphaorbeta==5
    beta_e = 1;
    A=zeros(13,ntypes);
    disldist=sqrt(smeararea);%sqrt(smeararea);  % assumed dislocation region size (distance between dislocations) ****** need to think about this
    %step=1e-9+1e-15;  %step size for numerical derivative of betas; add small offset to prevent NaN in integral
    step=disldist/2 - 1e-15;
    for i=1:ntypes
        if i<=(ntypes - nedge)
            edge=0;
        else
            edge=1;
        end
        thisb=b(i,:);
        thisl=l(i,:);
        betaderiv1=(betanalcont(thisb',thisl',disldist,edge,v,[step;0;0])-betanalcont(thisb',thisl',disldist,edge,v,[-step;0;0]))/(2*step); % beta derivatives in 1 direction (betas (distortions) using equations from Lazar)
        betaderiv2=(betanalcont(thisb',thisl',disldist,edge,v,[0;step;0])-betanalcont(thisb',thisl',disldist,edge,v,[0;-step;0]))/(2*step); % beta derivatives in 2 direction (betas (distortions) using equations from Lazar)

        A(1,i)=betaderiv2(1,1);
        A(2,i)=betaderiv1(1,2);
        A(3,i)=betaderiv1(1,3);
        A(4,i)=betaderiv2(1,3);
        A(5,i)=betaderiv2(2,1);
        A(6,i)=betaderiv1(2,2);
        A(7,i)=betaderiv1(2,3);
        A(8,i)=betaderiv2(2,3);
        A(9,i)=betaderiv2(3,1);
        A(10,i)=betaderiv1(3,2);
        A(11,i)=betaderiv1(3,3);
        A(12,i)=betaderiv2(3,3);
        A(13,i) = thisb(3)/smeararea;
    end
    alphabeta(13) = 0;
elseif alphaorbeta==6
    A=zeros(4,ntypes);
    for i=1:ntypes
        A(1:3,i)=b(i,:)*l(i,3);
        A(4,i) = b(i,3)/smeararea;
    end
    alphabeta(4) = 0;
elseif alphaorbeta==7
    beta_e = 1;
    min_e = 0;
    normb=sqrt(sum(b.^2,2));
    m=zeros(size(b));
    for i = 1:length(b)
        m(i,:) = b(i,:)/normb(i);
    end
    schmid = zeros(size(crssfactor));
    n=[normals;normals];
    n = n*gmat;
    for i=1:length(b)
        schmid(i) = abs([m(i,1) m(i,2) m(i,3)]*stress*[n(i,1); n(i,2); n(i,3)]);
    end
    schmidcopy = schmid;
    
    
    
    A=zeros(12);
    disldist=sqrt(smeararea);%sqrt(smeararea);  % assumed dislocation region size (distance between dislocations) ****** need to think about this
    %step=1e-9+1e-15;  %step size for numerical derivative of betas; add small offset to prevent NaN in integral
    step=disldist/2 - 1e-15;
    
    keepers = zeros(12,1);
    for j=1:12
        
        [useless, i] = max(schmidcopy);
        schmidcopy(i(1)) = 0;
        
        keepers(j) = i;
        
        if i<=(ntypes - nedge)
            edge=0;
        else
            edge=1;
        end
        thisb=b(i,:);
        thisl=l(i,:);
        betaderiv1=(betanalcont(thisb',thisl',disldist,edge,v,[step;0;0])-betanalcont(thisb',thisl',disldist,edge,v,[-step;0;0]))/(2*step); % beta derivatives in 1 direction (betas (distortions) using equations from Lazar)
        betaderiv2=(betanalcont(thisb',thisl',disldist,edge,v,[0;step;0])-betanalcont(thisb',thisl',disldist,edge,v,[0;-step;0]))/(2*step); % beta derivatives in 2 direction (betas (distortions) using equations from Lazar)
        
        A(1,i)=betaderiv2(1,1);
        A(2,i)=betaderiv1(1,2);
        A(3,i)=betaderiv1(1,3);
        A(4,i)=betaderiv2(1,3);
        A(5,i)=betaderiv2(2,1);
        A(6,i)=betaderiv1(2,2);
        A(7,i)=betaderiv1(2,3);
        A(8,i)=betaderiv2(2,3);
        A(9,i)=betaderiv2(3,1);
        A(10,i)=betaderiv1(3,2);
        A(11,i)=betaderiv1(3,3);
        A(12,i)=betaderiv2(3,3);
    end
    
    rhotemp = A\alphabeta;
    rho = zeros(1,ntypes);
    for i=1:ntypes
        j = find(keepers==i);
        if isempty(j)
            rho(i) = 0;
        else
            rho(i) = rhotemp(j);
        end
    end  
    
elseif alphaorbeta==8
    beta_e = 1;
    min_e=0;
    A=zeros(18,ntypes);
    disldist=sqrt(smeararea);%sqrt(smeararea);  % assumed dislocation region size (distance between dislocations) ****** need to think about this
    %step=1e-9+1e-15;  %step size for numerical derivative of betas; add small offset to prevent NaN in integral
    step=disldist/2 - 1e-15;
    for i=1:ntypes
        if i<=(ntypes - nedge)
            edge=0;
        else
            edge=1;
        end
        thisb=b(i,:);
        thisl=l(i,:);
        betaderiv1=(betanalcont(thisb',thisl',disldist,edge,v,[step;0;0])-betanalcont(thisb',thisl',disldist,edge,v,[-step;0;0]))/(2*step); % beta derivatives in 1 direction (betas (distortions) using equations from Lazar)
        betaderiv2=(betanalcont(thisb',thisl',disldist,edge,v,[0;step;0])-betanalcont(thisb',thisl',disldist,edge,v,[0;-step;0]))/(2*step); % beta derivatives in 2 direction (betas (distortions) using equations from Lazar)
        betaderiv3=(betanalcont(thisb',thisl',disldist,edge,v,[0;0;step])-betanalcont(thisb',thisl',disldist,edge,v,[0;0;-step]))/(2*step);
        
        A(1,i)=betaderiv2(1,1);
        A(2,i)=betaderiv1(1,2);
        A(3,i)=betaderiv1(1,3);
        A(4,i)=betaderiv2(1,3);
        A(5,i)=betaderiv2(2,1);
        A(6,i)=betaderiv1(2,2);
        A(7,i)=betaderiv1(2,3);
        A(8,i)=betaderiv2(2,3);
        A(9,i)=betaderiv2(3,1);
        A(10,i)=betaderiv1(3,2);
        A(11,i)=betaderiv1(3,3);
        A(12,i)=betaderiv2(3,3);
        A(13,i)=betaderiv3(1,2);
        A(14,i)=betaderiv3(1,1);
        A(15,i)=betaderiv3(2,2);
        A(16,i)=betaderiv3(2,1);
        A(17,i)=betaderiv3(3,2);
        A(18,i)=betaderiv3(3,1);
        
        
        
    end
    alphabeta(13) = -alphabeta(4);
    alphabeta(14) = -alphabeta(3);
    alphabeta(15) = -alphabeta(8);
    alphabeta(16) = -alphabeta(7);
    alphabeta(17) = -alphabeta(12);
    alphabeta(18) = -alphabeta(11);
    
    rho = A\alphabeta;
elseif alphaorbeta == 9
    A=zeros(6,ntypes);
    for i=1:ntypes
        A(1:3,i)=b(i,:)*l(i,3);
        A(4,i) = b(i,1)*l(i,2);
        A(5,i) = b(i,2)*l(i,1);
        A(6,i) = (b(i,1)*l(i,1) - b(i,2)*l(i,2));
    end
    
elseif alphaorbeta == 10
    min_e = 0;
    A=zeros(6,ntypes);
    for i=1:ntypes
        A(1:3,i)=b(i,:)*l(i,3);
        A(4,i) = b(i,1)*l(i,2);
        A(5,i) = b(i,2)*l(i,1);
        A(6,i) = (b(i,1)*l(i,1) - b(i,2)*l(i,2));
    end
    
    rho = A\alphabeta;
    
elseif alphaorbeta==11
    beta_e = 1;
    A=zeros(6,ntypes);
    disldist=sqrt(smeararea);%sqrt(smeararea);  % assumed dislocation region size (distance between dislocations) ****** need to think about this
    %step=1e-9+1e-15;  %step size for numerical derivative of betas; add small offset to prevent NaN in integral
    step=disldist/2 - 1e-15;
    for i=1:ntypes
        if i<=(ntypes - nedge)
            edge=0;
        else
            edge=1;
        end
        thisb=b(i,:);
        thisl=l(i,:);
        betaderiv1=(betanalcont(thisb',thisl',disldist,edge,v,[step;0;0])-betanalcont(thisb',thisl',disldist,edge,v,[-step;0;0]))/(2*step); % beta derivatives in 1 direction (betas (distortions) using equations from Lazar)
        betaderiv2=(betanalcont(thisb',thisl',disldist,edge,v,[0;step;0])-betanalcont(thisb',thisl',disldist,edge,v,[0;-step;0]))/(2*step); % beta derivatives in 2 direction (betas (distortions) using equations from Lazar)

%         betaderiv1=(antisymmpart(betanalcont(thisb',thisl',disldist,edge,v,[step;0;0]))-antisymmpart(betanalcont(thisb',thisl',disldist,edge,v,[-step;0;0])))/(2*step); % omega only
%         betaderiv2=(antisymmpart(betanalcont(thisb',thisl',disldist,edge,v,[0;step;0]))-antisymmpart(betanalcont(thisb',thisl',disldist,edge,v,[0;-step;0])))/(2*step); % omega only
        A(1,i)=betaderiv2(1,1);
        A(2,i)=betaderiv1(1,2);
        A(3,i)=betaderiv2(2,1);
        A(4,i)=betaderiv1(2,2);
        A(5,i)=betaderiv2(3,1);
        A(6,i)=betaderiv1(3,2);
        
        
        
    end
    
end

if min_e == 1;
    
    switch minscheme
        case 1 % minimize total dislocation density
        minimizer=ones(1,ntypes);
        case 2  % minimize energy in dislocations
            minimizer=sum(b.^2,2)'; %use squared-norm of each burger's vector
        case 3  % use CRSS of each system
            minimizer=crssfactor';
        case 4 % use schmid and CRSS
            normb=sqrt(sum(b.^2,2));
            m=zeros(size(b));
            for i = 1:length(b)
                m(i,:) = b(i,:)/normb(i);
            end
            schmid = zeros(size(crssfactor));
            n=[normals;normals];
            n = n*gmat;
            for i=1:length(b)
                schmid(i) = abs([m(i,1) m(i,2) m(i,3)]*stress*[n(i,1); n(i,2); n(i,3)]);
            end
            %schmid=abs((force(1)*normals(:,1)+force(2)*normals(:,2)+force(3)*normals(:,3)).*(force(1)*b(:,1)/normb+force(2)*b(:,2)/normb+force(3)*b(:,3)/normb));

            minimizer=((ones(size(schmid)) - schmid).*crssfactor)';
        case 5
            minimizer = zeros(1, ntypes);
            for i=1:ntypes
                minimizer(i) = crssfactor(i)*l(i,3);
            end
        otherwise
            error('only types 1-5 defined')
    end

    

    
    if x0type ==1
        x0=A\alphabeta;
    else
        x0 = zeros(ntypes,1);
    end


    %LB = -1*bound*ones(size(x0));
    %UB = bound*ones(size(x0));
    swarm=0;
    if swarm==0
    % fun=@(x) (minimizer*abs(x));
    % ex=1;
    % fun=@(x) (minimizer*(abs(x).^ex))^(1/ex);
    fun=@(x) (minimizer*(abs(x)));
    options=optimset('ScaleProblem', 'obj-and-constr','LargeScale','on', 'Algorithm', 'sqp','TolCon',(1e-4)/sqrt(smeararea),'Hessian', 'bfgs','display','off');%'Algorithm', 'sqp',,'TolCon',(1e-4)/sqrt(smeararea),'ScaleProblem', 'obj-and-constr','Hessian', 'bfgs','display','off',
    % rho = fmincon(fun,x0,[],[],A,alphabeta,zeros(size(x0)),[],[],options); % enforce
    % DD > 0 else the required DD can be achieved by all sorts of + / -
    % combinations - but is this correct?????????************
    % rho = fmincon(fun,x0,[],[],A,alphabeta,[],[],[],options); % allow negative DD*****
    % rho = fmincon(fun,x0,[],[],A,alphabeta,LB,UB,[],options);
    % maxrho = max(abs(rho));
    %     if 1.1*maxrho > bound

            rho = fmincon(fun,x0,[],[],A,alphabeta,[],[],[],options);
            %rho = x0;
    %     end
%     cond(A);
    else
    fun=@(x) (minimizer*abs(x'));
    options = psooptimset('Parallel','off','Generations',60);%,'display','off'
    rho = pso(fun,length(x0),[],[],A,alphabeta,[],[],[],options)'; %swarm algorithm option
%     options=optimset('ScaleProblem', 'obj-and-constr','LargeScale','on', 'Algorithm', 'sqp','display','off','TolCon',(1e-4)/sqrt(smeararea),'Hessian', 'bfgs');
%     fun=@(x) (minimizer*(abs(x)));
%     rho = fmincon(fun,rho,[],[],A,alphabeta,[],[],[],options);
    end

    %rho=x0; %if you want a fast approximate


% keyboard
    
end

if beta_e == 1
    rho=rho./smeararea;
end