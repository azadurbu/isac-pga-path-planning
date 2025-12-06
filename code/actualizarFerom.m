function [tau] = actualizarFerom(tau,colonia)
% Execute the update of pheromone levels of the paths that have
%been traveled by ants based on the cost of the journey.

%We calculate the number of nodes of the path of each ant.
antNo = length(colonia.ant(:));
for i=1:antNo
    nodeNo = length(colonia.ant(i).path);
    for j=1:nodeNo-1
        currentNode = colonia.ant(i).path(j);
        nextNode = colonia.ant(i).path(j+1);
        
        %update tau:
        %Add to the previous tau (still not evaporated) the inverse of the
        %path length = fitness.
        tau(currentNode,nextNode) = tau(currentNode,nextNode)+1./colonia.ant(i).fitness;
        tau(nextNode,currentNode) = tau(nextNode,currentNode)+1./colonia.ant(i).fitness;
        %The Tau matrix has to be symmetrical (same level of pheromine of
        %3 to 4 than from 4 to 3).
    end
end

end