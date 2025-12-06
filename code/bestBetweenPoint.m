function [x,y] = bestBetweenPoint(X,Y)
% BESTBETWEENPOINT Summary of this function 
% take starting and ending points 
% return best path points between ginven points

% accept array like 
% X = [3,5];
% Y = [8,9];

% return array like this
% x = [3,4,4,5]
% y = [9,8,9,8]
% remove starting and ending points

[X,Y] = allpointxy(X,Y);

moves = zeros(length(X),length(Y));

m_p(:,1)=X;
m_p(:,2)=Y;
m_p(:,3)=(1:length(X));
p=1;
for i=1:length(X)
    for j=1:length(X)
        if i~=j && ( m_p(i,1) == m_p(j,1) || m_p(i,2) == m_p(j,2) )
            if m_p(i,1) == m_p(j,1)
                moves(m_p(i,3),m_p(j,3)) = 1;
            end
            if m_p(i,2) == m_p(j,2)
                moves(m_p(i,3),m_p(j,3)) = 1;
            end
        end
    end
end
initial_node = 1;
destination_node = length(X);

for i=1:length(X)
    ptot(i).x = X(i);
    ptot(i).y = Y(i);
    ptot(i).tipo = 1;
end

[graph] = crearGrafico(ptot,moves);

maxIter = 100;
antNo = 6;
tau0 = 0.01;
tau = tau0 * ones(graph.n, graph.n);
eta = 1./graph.edges;
rho = 0.1;
alpha = 0.8;
beta = 0.8;

%aco loop
bestPath = [];
bestFitness = zeros(maxIter,1); 
iterFoundAbs = 0;
iterFoundRel = 0;
bestFitness(1) = Inf;
iterAntsFitness = zeros(maxIter,antNo);

for t=1:maxIter
    colonia = [];
    colonia = crearColonia( graph, colonia, antNo, tau, eta, alpha, beta, initial_node,destination_node);

    for i=1:antNo
      colonia.ant(i).fitness = fitnessFunction( colonia.ant(i).path,graph ); 
    end
    allAntsFitness = [ colonia.ant(:).fitness ];
    [minVal, minIndex] = min( allAntsFitness );
    iterAntsFitness(t,:) = allAntsFitness;

    if t == 1
       bestFitness(t) = minVal;
       bestPath = colonia.ant( minIndex ).path;
    elseif minVal < bestFitness(t-1)
       bestFitness(t) = minVal;
       bestPath = colonia.ant( minIndex ).path;
       iterFoundAbs = t;
       iterFoundRel = t - iterFoundRel;
    else
        bestFitness(t) = bestFitness(t-1);
    end

    colonia.queen.path = bestPath;
    colonia.queen.fitness = bestFitness(t);
    tau = actualizarFerom( tau , colonia );
    tau = ( 1 - rho ) .* tau;

end

    newBestPath = bestPath(2:end-1);
    x(:,1)=m_p(newBestPath,1);
    y(:,1)=m_p(newBestPath,2);
end

