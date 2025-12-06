function [colonia] = crearColonia(graph, colonia, antNo, tau, eta, alpha, beta, startnode, endnode)
%Generates paths for all the ants in the colony defined in antNo.
%Each offset calculates the probability (if there is any node
%available), otherwise it loops back until one is available. when the
%next node is destination, go to next ant until it has finished
%performed this operation on all.

destinationNode = endnode;
%Run loop for all ants. In the while loop we draw a
%full path from start to end.
for i=1:antNo
   % variable in case you have to go back
   retroceder = 0;
   colonia.ant(i).path(1) = startnode;
   %Ant i .path property, includes visited nodes in the path
    %From the first, the following will be chosen by probability
    %We go through the rest of the nodes until the break (destination)
   while 1
       %We select the last node of the .tour of the ant
       currentNode = colonia.ant(i).path(end);

       %Calculate the probabilities of the nodes available to move with
        %the formula of the algorithm
        %Initialization of the probability matrix according to the number of
        %nodes
       P_allNodes = zeros(1,graph.n); 
       %Traverses the vector moves available to the currentNode and only
        %calculates the probability of moving to the nodes that appear.
       for j = 1:length(graph.node(currentNode).move)
        P_allNodes(graph.node(currentNode).move(j)) = tau( currentNode, graph.node(currentNode).move(j) ).^alpha .* eta( currentNode, graph.node(currentNode).move(j) ).^beta;
       end

       %To avoid moving backwards on the route, the probability of
        %tour nodes is 0:
       P_allNodes(colonia.ant(i).path) = 0;
       
       %We fit probabilities by cumulative addition.
       P = P_allNodes ./sum(P_allNodes);
       %Roulette to select the movement.
        %Check that at least 1 node has P different from NaN
       if isnan(P)
           %if there is no node available to travel (NaN) it goes back in
            %the path until one is available
           nextNode = colonia.ant(i).path(end-(2*retroceder+1));
           retroceder = retroceder +1;
       else
           %if there is at least 1 node with P different from NaN we use the function
            %spinner to select the next node
           nextNode = ruleta(P);
           %reset backcounter
           retroceder = 0;
       end
       %If there is no node available, it returns to the previous one
        % We add the node to the path
       colonia.ant(i).path = [colonia.ant(i).path, nextNode];
       %If we have reached the next one, the loop of the ant i ends,
        %y goes to the next
       if nextNode == destinationNode
           break
       end
   end
end

end