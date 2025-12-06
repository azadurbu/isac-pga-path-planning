function [graph] = crearGrafico(puntos,moves)
%Function that generates the environment of the problem to the Matlab workspace. gets
%a structure that contains all the information of each node (coordinates
%X, Y, node type and available moves). It also calculates the
%Euclidean distances between nodes.

%Graph Size = total nodes.
graph.n = length(puntos);

% We add the coordinates of each point to the graph.
for i=1:graph.n
    graph.node(i).x = puntos(i).x; %Add x-coord to i node
    graph.node(i).y = puntos(i).y; %Add y-coord to i node
    graph.node(i).tipo = puntos(i).tipo; %add node type
    %We add the 1s to the possible moves.
    graph.node(i).move = find(moves(i,:));
end
%Flag that indicates when displaying the results that there are no names
graph.ciu = 'no';

% Array parameter that contains the distances between nodes.
graph.edges = zeros(graph.n, graph.n);

%Distances
for i=1:graph.n
    for j=1:graph.n
        % Calculation of the Euclidean distance between each point
        x1 = graph.node(i).x;
        x2 = graph.node(j).x;
        
        y1 = graph.node(i).y;
        y2 = graph.node(j).y;
        
        %distance between i(1) and j(2) = root((ix-jx)^2 + (iy-jy)^2)
        graph.edges(i,j) = sqrt( (x1-x2)^2 + (y1-y2)^2 );
    end
end

end