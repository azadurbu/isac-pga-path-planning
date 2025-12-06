function PlotSolution(tour,model,shift)

    tour=[tour tour(1)];
    
%     plot(model.x(tour),model.y(tour),'k-o',...
%         'MarkerSize',10,...
%         'MarkerFaceColor','y',...
%         'LineWidth',1.5);
    
%     xlabel('x');
%     ylabel('y');

% offset making
    for i= 1 : model.n
        ii=tour(i);
        iii = model.z(ii);
        if iii>=7
            z(i)=model.z(ii)+1;
        elseif iii<6 && iii>5
            z(i)=model.z(ii)+2;
        else
            z(i)=model.z(ii)+3;
        end
    end
    shift = shift*10;
    p = plot3(model.x(tour)+shift,model.y(tour),model.z(tour));
    p.LineWidth = 2;
    p.Color="blue";
    axis equal;
    grid on;
    
% 	alpha = 0.1;
% 	
%     xmin = min(model.x);
%     xmax = max(model.x);
%     dx = xmax - xmin;
%     xmin = floor((xmin - alpha*dx)/10)*10;
%     xmax = ceil((xmax + alpha*dx)/10)*10;
%     xlim([xmin xmax]);
%     
%     ymin = min(model.y);
%     ymax = max(model.y);
%     dy = ymax - ymin;
%     ymin = floor((ymin - alpha*dy)/10)*10;
%     ymax = ceil((ymax + alpha*dy)/10)*10;
%     ylim([ymin ymax]);
    
    
end