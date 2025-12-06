clear
clc
% clf
close all
% Parameters
height_UAV = 100; % UAV altitude in meters

a=load('UAV_Sensor_multi_uav.mat');
x_uav = reshape([a.uav.UAV1.x' a.uav.UAV2.x' a.uav.UAV3.x'].',[],1)';
y_uav = reshape([a.uav.UAV1.y' a.uav.UAV2.y' a.uav.UAV3.y'].',[],1)';
z_uav = reshape([a.uav.UAV1.z' a.uav.UAV2.z' a.uav.UAV3.z'].',[],1)';

x_sensor = reshape([a.sensor.UAV1.x a.sensor.UAV2.x a.sensor.UAV3.x].',[],1)';
y_sensor = reshape([a.sensor.UAV1.y a.sensor.UAV2.y a.sensor.UAV3.y].',[],1)';
z_sensor = reshape([a.sensor.UAV1.z a.sensor.UAV2.z a.sensor.UAV3.z].',[],1)';


d=z_sensor.*10*rand;

hBS = 1.5; % Height of sensors in meters
freq = 2.4e9; % Frequency in Hz
B = 10e6; % Bandwidth in Hz
% noisePower = -100; % Noise power in dBm
speed = 50; % UAV speed in m/s
noise_fig = 5; % Noise figure in dB
shadowingStdDev = 4; % Standard deviation of shadowing in dB
outageThreshold = -10; % Outage threshold in dB

L = 1; % System loss factor
K = 1.38e-23; % Boltzmann constant
T = 300; % Temperature in Kelvin
N0 = 10*log10(K*T*B) - noise_fig; % Noise power spectral density in dBm/Hz

Ptx = 23; % Transmit power in dBm

% Compute noise power
noisePower = N0 + 10*log10(B) + L;

% Channel parameters
sampleRate = 1e6; % Sample rate in Hz
delaySpread = 1e-6; % Delay spread in seconds

% Initialize Rician channel object
channel = comm.RicianChannel('SampleRate', sampleRate, 'PathDelays', delaySpread, ...
                             'AveragePathGains', 0, 'KFactor', 10, 'MaximumDopplerShift', speed/3e8*freq);

tdl = nrTDLChannel;
tdl.NumTransmitAntennas = 1;
tdl.DelayProfile = 'Custom';
tdl.FadingDistribution = 'Rician';
tdl.KFactorFirstTap = 10.0;
tdl.PathDelays = [0.0 45e-9];
tdl.AveragePathGains = [0.0 -5.0];
SR = 30.72e6;
T = sampleRate * 1e-3;
tdl.SampleRate = sampleRate;
tdlinfo = info(tdl);
Nt = tdlinfo.NumTransmitAntennas;

txWaveform = complex(randn(T,Nt),randn(T,Nt));

% rxWaveform = tdl(txWaveform);
reset(tdl);
% Initialize shadowing
shadowing = shadowingStdDev*randn(1,length(d)); % Log-normal shadowing

% Assume all sensors transmit with the same power
txPower = db2pow(Ptx); % Transmit power in linear scale

% Calculate path loss and received power
pl_db = 20*log10(d) + 20*log10(4*pi*freq/3e8) + 20*log10(height_UAV^2) + shadowing;
receivedPower = txPower - pl_db;

% Simulate transmission over the channel
txSignal = ones(sampleRate, 1); % Transmit a constant signal for 1 second
rxSignal = zeros(sampleRate, 3); % Initialize received signal
for i = 1:3
    reset(channel); % Reset channel state
    attenuatedSignal = txSignal * 10^((txPower - pl_db(i))/20); % Apply path loss and shadowing
    rxSignal(:,i) = channel(attenuatedSignal); % Pass signal through channel
end

dist = d;

% 2x2 MIMO channel model
d = pdist2([x_uav' y_uav' z_uav'], [x_sensor' y_sensor' hBS*ones(length(x_sensor),1)]); % Compute distances
lambda = physconst('LightSpeed')/freq; % Wavelength
PL = 20*log10(4*pi*d/lambda); % Free space path loss
SF = shadowingStdDev*randn(length(x_sensor),1); % Shadow fading
H = sqrt(10.^((PL+SF'+ L)/10))*sqrt(0.5)*complex(randn(length(x_sensor),2),randn(length(x_sensor),2)); % Channel matrix
H = H'; % Transpose for proper MIMO operation

% Compute SINR with co-channel interference
tx_power = db2pow(Ptx); % Transmit power in linear scale
rx_power = abs(H.*(diag(sqrt(tx_power))*[1;1])).^2; % Received power
% interference = rx_power-repmat(diag(rx_power),1,length(x_sensor)); 
interference_ = rx_power-repmat(diag(rx_power),1,length(x_uav));% Interference matrix

% Calculate SINR
interference = sum(receivedPower) - receivedPower;
sinr = receivedPower - 10*log10(interference + 10^(noisePower/10));

% sinr = 10 * log10(receivedPower ./ ((interference+noisePower).*dist));

% Display results
% disp('Path loss (dB): ');
% disp(pl_db);
% disp('SINR (dB): ');
% disp(sinr);
% figure('Name','1');
% bar(sinr); 
% grid on
% xlabel("Number of Sensor");
% ylabel("SINR");

% Calculate throughput
throughput = log2(1 + 10.^(sinr/10));

% Calculate latency (propagation delay)
propagation_speed = 3e8; % Speed of propagation in the medium (m/s)
processing_delay = randi([1,10],1,30).*0.01; % Processing delay in seconds
data_size = randi([1,20],1,30).*0.01.*1e6; % Data size in bits [0.1 to 2 MB]

% Calculate propagation delay
propagation_delay = dist ./ propagation_speed;

% Calculate transmission time
transmission_time = data_size ./ B;

% Calculate total latency
total_latency = propagation_delay + processing_delay + transmission_time;
% figure('Name','Latency')
% bar(total_latency);
% title('Latency according to the sensor');
% xlabel('Sensor Number');
% ylabel('Latency (Second)');

% Calculate reliability (outage probability)
reliability = mean(sinr < outageThreshold);

% Define the grid of points onto which you want to interpolate
xi = linspace(min(x_sensor), max(x_sensor), 100);
yi = linspace(min(y_sensor), max(y_sensor), 100);
[X, Y] = meshgrid(xi, yi);

% Use griddata to interpolate onto the grid
Z = griddata(x_sensor, y_sensor, sinr, X, Y);

% Create the surface plot
figure('Name','2');
surf(X, Y, Z)
hold on % Allows to overlay plots

% Now scatter the original points onto the plot
scatter3(x_sensor, y_sensor, sinr, 'filled', 'MarkerEdgeColor','k', 'MarkerFaceColor','r');
title('3D SINR Sensor Data');
xlabel('Sensor X (M)');
ylabel('Sensor Y (M)');
zlabel('SINR (dB)');

% Annotate the points with their SINR values
text(x_sensor, y_sensor, sinr, num2str(sinr'), 'VerticalAlignment','bottom', 'HorizontalAlignment','right')
hold off % Done with the overlay
colorbar;

figure('Name','3');
% Now scatter the original points onto the plot
scatter3(x_sensor, y_sensor, sinr, 'filled', 'MarkerEdgeColor','k', 'MarkerFaceColor','r');
title(' SINR intersection points ');
xlabel('Sensor X (M)');
ylabel('Sensor Y (M)');
zlabel('SINR (dB)');

% Annotate the points with their SINR values
text(x_sensor, y_sensor, sinr, num2str(sinr'), 'VerticalAlignment','bottom', 'HorizontalAlignment','right')

% sinr_st = [min(sinr) min(sinr) min(sinr) sort(sinr) max(sinr) max(sinr) max(sinr) max(sinr) max(sinr) max(sinr) max(sinr) max(sinr)];
% throughput_st = [min(throughput) min(throughput) min(throughput) sort(throughput) max(throughput) max(throughput) max(throughput) max(throughput) max(throughput) max(throughput) max(throughput) max(throughput)];
% figure('Name','SINR VS Throughput');
% p=plot(1:length(throughput_st), throughput_st);
% p.LineWidth=2;
% grid on
% title('SINR VS Throughput');
% xlabel('SINR in dB');
% ylabel('Throughput in bps');