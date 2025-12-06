function [x,y] = allpointxy(X,Y)
% ALLPOINTXY Summary of this function 
% take starting and ending points and return 
% all the points between ginven points

% accept array like 
% X = [3,5];
% Y = [8,9];

% return array like this
% x = [3,3,4,4,5,5]
% y = [8,9,8,9,8,9]

startx=X(1);
starty=Y(1);
endx=X(2);
endy=Y(2);

difx = abs(startx-endx)+1;
dify = abs(starty-endy)+1;


if startx>endx
    d=1;
else
    d=-1;
end
k=1;
for i=1:difx
    for j=1:dify
        x(k)=startx;
        k=k+1;
    end
    newx=startx - d;
    startx=newx;
end

if starty>endy
    d=1;
else
    d=-1;
end

k=1;
oldy=starty;
for i=1:difx
    starty = oldy;
    for j=1:dify
        y(k)=starty;
        k=k+1;
        newy=starty - d;
        starty=newy;
    end
end