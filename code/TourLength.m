function [L,EC]=TourLength(tour,model)
    n=numel(tour);
    tour=[tour tour(1) tour(2)];
    % Energy Consumption (EC) 
    ec=0;
    pu=20; % UAV power (watt)
    ve=10; % UAV velocity (m/sec)
    maxec=(n-1)*pu* sqrt(20^2+20^2+1.5^2)/ve;
    
    %Flight Risk (FR)
    fr=0;
    wer=1/2;
    war=1/2;
    maxz=1.5;
    maxrisk=5;
    maxfr=(n-1)*(0.5*maxz+maxrisk); 

    % Turning Angle Constraint (TAC)
    TAC=0;
    thmax=135;  % from zheng et al. paper

    L=0;
    for i=1:n
        L=L+model.D(tour(i),tour(i+1));

        % ec calculation
        d=sqrt((tour(i)-tour(i+1))^2+( tour(i+1)-tour(i))^2);
        e=pu*d/ve;
        ec=ec+e;
        EC{i}=ec;
        %fr calculation
        re=tour(i)+tour(i+1);
        ra=tour(i+1)-tour(i);
        a=wer*re+war*ra ;
        fr=fr+a;
        
        %TAC calculation
        q1=tour(i)-tour(i+1);
        q2=tour(i+1)-tour(i+2);
        num=dot(q1,q2);
        deno=norm(q1)*norm(q2);       % fenmu denominator
        theta=acosd(num/deno);
        if theta<thmax
            tac=0;
        else
            tac=-1;
        end
        TAC=TAC+tac;
    end
fec=ec/maxec;
ffr=fr/maxfr;

L=L+fec+ffr+TAC;
L=L*18 -180;
end