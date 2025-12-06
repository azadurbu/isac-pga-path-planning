function [fitness] = fitnessFunction (path, graph)
%Calculates the cost of moving between start and end.

fitness = 0;
% we add all the distances between nodes of the ant's path.
for i=1:length(path)-1
    currentNode = path(i);
    nextNode = path(i+1);
    
    fitness = fitness + graph.edges(currentNode,nextNode);
    
end