clear
clc
close all
s=load('UAV_Sensor_multi_uav.mat', 'sensor');
ss=s.sensor;

plot(0,0); hold on
uav1 = s.sensor.UAV1;
plot(uav1.x,uav1.y,'r*'); hold on
uav2 = s.sensor.UAV2;
plot(10+uav2.x,uav2.y,'g*'); hold on
uav3 = s.sensor.UAV3;
plot(20+uav3.x,uav3.y,'b*'); hold on