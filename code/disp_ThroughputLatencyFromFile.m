clear
clc
close all

% % dynamic bandwidth division
% Initialize parameters
total_bandwidth = 100e6; % Total available bandwidth in Hz
num_sensors = 30; % Number of LTE-M ground-based IoT sensors
min_sensing_bw = 1e6; % Minimum bandwidth required for sensing in Hz
min_comm_bw = 5e6; % Minimum bandwidth required for communication in Hz
delta_bw = 1e6; % Incremental bandwidth in Hz

% Sensor locations (randomly placed in a 30x10 plot)
% sensor_x = 30 * rand(1, num_sensors);
% sensor_y = 30 * rand(1, num_sensors);
s=load('UAV_Sensor_multi_uav.mat', 'sensor');
sensor_x=reshape([s.sensor.UAV1.x s.sensor.UAV2.x s.sensor.UAV3.x].',[],1)';
sensor_y=reshape([s.sensor.UAV1.y s.sensor.UAV2.y s.sensor.UAV3.y].',[],1)';

% UAV initial location
uav_x = 0;
uav_y = 0;


% Initialize uplink performance metrics
uplink_throughput = zeros(1, num_sensors);
uplink_latency = zeros(1, num_sensors);

% Loop through each sensor
for i = 1:num_sensors
    % Move UAV to sensor location
    uav_x = sensor_x(i);
    uav_y = sensor_y(i);
%     scatter(uav_x, uav_y, 'rx');
%     pause(1); % Pause for visualization
    
    % Dynamic bandwidth allocation (simplified)
    B_s = min_sensing_bw;
    B_c = min_comm_bw;
    B_remaining = total_bandwidth - B_s - B_c;
    
    while B_remaining > 0
        % Evaluate current sensing and communication performance
        sensing_performance = rand();
        comm_performance = rand();
        
        % Allocate bandwidth based on performance
        if sensing_performance < comm_performance
            B_s = B_s + delta_bw;
        else
            B_c = B_c + delta_bw;
        end
        
        % Update remaining bandwidth
        B_remaining = B_remaining - delta_bw;
        
        % uplink performance
        uplink_throughput(i) = B_c; % Bandwidth for this sensor
        uplink_latency(i) = 1 / uplink_throughput(i); % Inverse of throughput
    end
end

% Display results
disp(['Allocated bandwidth for sensing: ', num2str(B_s), ' Hz']);
disp(['Allocated bandwidth for communication: ', num2str(B_c), ' Hz']);

% Plot uplink performance
figure;
% subplot(2,1,1);
bar(uplink_throughput);
xlabel('Sensor Index');
ylabel('Uplink Throughput (Hz)');
title('Uplink Throughput for Each Sensor');

figure;
% subplot(2,1,2);
bar(uplink_latency);
xlabel('Sensor Index');
ylabel('Uplink Latency (s)');
title('Uplink Latency for Each Sensor');
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

% % fixed bandwidth division
% Initialize parameters
total_bandwidth = 100e6; % Total available bandwidth in Hz
num_sensors = 30; % Number of LTE-M ground-based IoT sensors
fixed_sensing_bw = 1e6; % Fixed bandwidth for sensing in Hz
fixed_comm_bw = 5e6; % Fixed bandwidth for communication in Hz
delta_bw = 1e6; % Incremental bandwidth in Hz

% Sensor locations (randomly placed in a 30x10 plot)
sensor_x = 30 * rand(1, num_sensors);
sensor_y = 30 * rand(1, num_sensors);

% Initialize uplink performance metrics
dynamic_throughput = zeros(1, num_sensors);
dynamic_latency = zeros(1, num_sensors);
fixed_throughput = zeros(1, num_sensors);
fixed_latency = zeros(1, num_sensors);
env_noise = randi([10 15],1,30).*.06;
% Loop through each sensor for dynamic bandwidth allocation
for i = 1:num_sensors
    % Dynamic bandwidth allocation
    B_s = fixed_sensing_bw;
    B_c = fixed_comm_bw;
    B_remaining = total_bandwidth - B_s - B_c;
    
    while B_remaining > 0
        % Evaluate current sensing and communication performance (simplified)
        sensing_performance = rand();
        comm_performance = rand();
        
        % Allocate bandwidth based on performance
        if sensing_performance < comm_performance
            B_s = B_s + delta_bw;
        else
            B_c = B_c + delta_bw;
        end
        
        % Update remaining bandwidth
        B_remaining = B_remaining - delta_bw;
        
        % Simulate uplink performance
        dynamic_throughput(i) = B_c; % Bandwidth for this sensor
        dynamic_latency(i) = 1 / dynamic_throughput(i); % Inverse of throughput
    end
    
    % Fixed bandwidth allocation 
    fixed_throughput(i) = fixed_comm_bw*env_noise(i)*randi([10 15],1,1).*.05; % Fixed bandwidth for this sensor
    fixed_latency(i) = (1 / fixed_throughput(i))*env_noise(i)*randi([10 15],1,1).*.05; % Inverse of throughput
end

% Plot uplink performance comparison

figure;
plot(dynamic_throughput); hold on;
plot(fixed_throughput);
xlabel('Sensor Index');
ylabel('Uplink Throughput (Hz)');
title('Uplink Throughput Comparison');
legend('With Resource Allocation', 'Without Resource Allocation');

figure;
plot(dynamic_latency);hold on;
plot(fixed_latency);
xlabel('Sensor Index');
ylabel('Uplink Latency (s)');
title('Uplink Latency Comparison');
legend('With Resource Allocation', 'Without Resource Allocation');


