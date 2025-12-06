clear
clc
% clf
close all

%% initialization
% sensor generation in random positino
U = 3;
M = 10; %number_of_sensor
jjj=0;
ax=30;

for iii=1:U
    var = "UAV"+iii;
    shift = 10*(iii-1);
    x = randi([1+shift,10+shift],M, 1);
    y = randi([1,30],M, 1);
%     if(iii==1) sp=1;
%     elseif(iii==2) sp=3;
%     elseif(iii==3) sp=5;
%     end
%     x=sensor_position(:,sp);
%     y=sensor_position(:,sp+1);

    SIG_cell(:,0+iii+jjj) = round(x);
    SIG_cell(:,1+iii+jjj) = round(y);
    jjj=jjj+1;
s=1;
%% Problem Definition
model=CreateModel(SIG_cell.*s);
CostFunction=@(tour) TourLength(tour,model);

nVar=M;

%% ACO Parameters

MaxIt=250;      % Maximum Number of Iterations
nAnt=2;        % Number of Ants (Population Size) 8

Q=1;

tau0=10*Q/(nVar*mean(model.D(:)));	% Initial Phromone
alpha=1;        % Pheromone Exponential Weight
beta=1;         % Heuristic Exponential Weight
rho=0.05;       % Evaporation Rate

%% Initialization

eta=1./model.D;             % Heuristic Information Matrix
tau=tau0*ones(nVar,nVar);   % Phromone Matrix
BestCost=zeros(MaxIt,1);    % Array to Hold Best Cost Values

% Empty Ant
empty_ant.Tour=[];
empty_ant.Cost=[];

% for ii=1:length(nAnt)
    % Ant Colony Matrix
    ant=repmat(empty_ant,nAnt,1);
    % Best Ant
    BestSol.Cost=inf;
    
    %% ACO Main Loop
    for it=1:MaxIt
        % Move Ants
        for k=1:nAnt
            
            ant(k).Tour=randi([1 nVar]);
            
            for l=2:nVar
                
                i=ant(k).Tour(end);
                
                P=tau(i,:).^alpha.*eta(i,:).^beta;
                
                P(ant(k).Tour)=0;
                
                P=P/sum(P);
                
                j=RouletteWheelSelection(P);
                
                ant(k).Tour=[ant(k).Tour j];
                
            end
            [L,EC] = TourLength(ant(k).Tour,model);

            ant(k).Cost = L;
            
            if ant(k).Cost<BestSol.Cost
                BestSol=ant(k);
            end
        end
        
        % Update Phromones
        for k=1:nAnt
            
            tour=ant(k).Tour;
            
            tour=[tour tour(1)]; %#ok
            
            for l=1:nVar
                
                i=tour(l);
                j=tour(length(tour));
                tau(i,j)=tau(i,j)+Q/ant(k).Cost;
            end
        end
        % Evaporation
        tau=(1-rho)*tau;
        
        % Store Best Cost
        BestCost(it)=BestSol.Cost;
%         BestCost(2,it)=BestSol.Tour;
    end
lengthAntArray = length(nAnt);

if iii==1
%% size of 3d environment
Pre = [ax*s,ax*s,10]; 
ax1 = nexttile;

%environment positioning 
for i = 1:ax*s
    for j = 1:ax*s
        height(i,j) = plotcube([1 1 randi([4 8],1)],[ i-.5  j-.5  0],.9,[1 1 1]);
    end
end
hold on
end

zz = 1 + (100-1) * rand(M, 1);
%% best neighbour serial

model.z = zz;

bestNeighbourSerial.(var).x=model.x(BestSol.Tour);
bestNeighbourSerial.(var).y=model.y(BestSol.Tour);
bestNeighbourSerial.(var).z=model.z(BestSol.Tour);

%% Plot Solution
% sensor positioning 
% r = 0.1;
% [x,y,z] = sphere(ax1);
% for si = 1 : M
%     for sj = 1 : M
%         surf(x*r + SIG_cell(si,1), y*r + SIG_cell(si,2), z*r);
%         axis equal
%         hold on
%     end
%     text(bestNeighbourSerial.x(si),bestNeighbourSerial.y(si), 10,[' ' num2str(si)],'HorizontalAlignment','left','FontSize',10);
%     if si>1
%         
%     end
% end

bestNeighbourSerial.(var).tour=(1:M);
bestNeighbourSerial.(var).n=M;

bnsx = bestNeighbourSerial.(var).x;
bnsy = bestNeighbourSerial.(var).y;
% making a loop path by making starting point and ending point
bnsx(end+1) = bnsx(1);
bnsy(end+1) = bnsy(1);
k=1;
resultArrayX = bnsx;
resultArrayY = bnsy;
index=0;
for i=1:length(resultArrayX)-1
   cond=((bnsx(i)==bnsx(i+1) || bnsx(i)+1 == bnsx(i+1) || bnsx(i) == bnsx(i+1)+1) && ...
       (bnsy(i)==bnsy(i+1) || bnsy(i)+1 == bnsy(i+1) || bnsy(i) == bnsy(i+1)+1));
   disp( ['i: ' num2str(i) ': ' num2str(bnsx(i)) ', ' num2str(bnsy(i))...
        ' TO ' num2str(bnsx(i+1)) ', ' num2str(bnsy(i+1)) '    ,   ' num2str(cond)])
   if cond == 0
       X=[bnsx(i),bnsx(i+1)];
       Y=[bnsy(i),bnsy(i+1)];
    
       [x,y] = bestBetweenPoint(X,Y);
        
        if ~isempty(x)
            for j=1:length(x)
                newBNS.x(k,:) = x(j);
                newBNS.y(k,:) = y(j);
                newBNS.n(k,:) = i;
                newBNS.c(k,:) = length(x);
                k=k+1;
            end
    
            resultArrayX_ = cat(1, resultArrayX(1:i+index), x, resultArrayX(i+index+1:end));
            resultArrayX = resultArrayX_;
            resultArrayY_ = cat(1, resultArrayY(1:i+index), y, resultArrayY(i+index+1:end));
            resultArrayY = resultArrayY_;
    
            index = index+length(x);
        end
   end
end
resultArray.(var).x=resultArrayX;
resultArray.(var).y=resultArrayY;

%geting height
length_x = length(resultArray.(var).x);
zz=zeros(length_x,1);
for i=1:length_x
    z=height(round(resultArray.(var).x(i)), round(resultArray.(var).y(i)));
    if(z>6)
        zz(i)=6+4;
    elseif(z>4)
        zz(i)=6+3;
    else
        zz(i)=6+2;
    end
end

resultArray.(var).z=zz;
resultArray.(var).tour=(1:length_x);
resultArray.(var).n=length_x;

uav.(var).x = resultArray.(var).x;
uav.(var).y = resultArray.(var).y;
uav.(var).z = resultArray.(var).z;

sensor.(var).x = bestNeighbourSerial.(var).x;
sensor.(var).y = bestNeighbourSerial.(var).y;
sensor.(var).z = bestNeighbourSerial.(var).z;
end
save('UAV_Sensor_multi_uav','uav');
save('UAV_Sensor_multi_uav','sensor','-append');
PlotSolution(resultArray.UAV1.tour,resultArray.UAV1,0);
PlotSolution(resultArray.UAV2.tour,resultArray.UAV2,1);
PlotSolution(resultArray.UAV3.tour,resultArray.UAV3,2);

xlabel('X axis')
ylabel('Y axis')
zlabel('Z axis')