clear
cd '/Users/david/MATLAB Drive/MobileSensorData' %change directory to MATLAB Drive
load test1
cd /Users/david/Desktop/MATHACK

Xacc = Acceleration.X;
Yacc = Acceleration.Y;
Zacc = Acceleration.Z;
accelTime=Acceleration.Timestamp;

plot(accelTime,Xacc);
hold on;
plot(accelTime,Yacc); 
plot(accelTime,Zacc);
hold off