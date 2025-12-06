function [nextNode] = ruleta(P)
%Choose a node based on probability.

%Calculation of the cumulative sum of P
cumsumP = cumsum(P);
%Random number
r = rand();
%We look for the node that meets:
nextNode = find( r <= cumsumP);
%We are left with the first
nextNode = nextNode(1);
end