%% Setup
clear
m = mobiledev;  % Create connection with MATLAB Mobile

delete(instrfind({'Port'},{'COM5'}))    % Delete any device connected to COM5
ard = serial('COM5','BaudRate',9600);   % Create serial connection to Arduino board
fopen(ard); % Initialize connection

sampling_freq = 10;
m.SampleRate = sampling_freq;   % Select Sampling Frequency
m.AccelerationSensorEnabled = 1;    % Activate acceleration sensor
m.PositionSensorEnabled = 1;    % Activate position sensor
m.Logging = 1;  % Start the transmission of data
size_before = 0;    % Size of the accel vector, to see when the recording stops (if the size before and after is the same, no new data is being added)
size_after = 1;
amp=zeros(1,12);  % Initialize vector

seizure_log = [];   % Log of all past seizures

%% Loop (always run Setup section before runing Loop section)
while true

    % Record data sent from mobile device
    [accel, time_accel] = accellog(m); % Get acceleration data from mobile
    [lat, lon, time_pos, speed, course, alt, horizacc] = poslog(m); % Get position data from mobile
    
    counter1 = 0; % Counter 1 is used to detect when a seizure starts
    counter2 = 0; % Counter 2 is used to detect when a seizure ends
    flag = 0; % Flag signals that a seizure has started
    
    SIZE = size(accel); % Size of the acceleration data matrix

    if SIZE(1) > 50 % Wait for the first 50 samples to be taken
        while true
            
            size_before = size(accel(:)); %Get the size before the new data acquisition
            pause(1)
            
            % Record data sent from mobile device
            [accel, time_accel] = accellog(m);
            [lat, lon, time_pos, speed, course, alt, horizacc] = poslog(m);
            
            % Filter data from accelerometer using a high pass filter: we
            % attenuate low frequency movements as epileptic seizure
            % movements are high frequency
            f_accel = highpass(accel,4,sampling_freq);
            
            size_after = size(accel(:)); %Get the size after the data acquisition
            
            
            %Get the last 50 samples of filtered acceleration data
            f_last_X = f_accel(end-50:end,1);
            f_last_Y = f_accel(end-50:end,2);
            f_last_Z = f_accel(end-50:end,3);
            
            %With these samples, calculate the amplitude of the
            %filtered acceleration data
            amp = [amp max([mean(abs(f_last_X)) mean(abs(f_last_Y)) mean(abs(f_last_Z))])];
            fprintf("%f\n",amp(end))
            
            threshold = 6.5; % Threshold for epileptic movement

            % Plot the filtered acceleration data in real time
            figure(1)
            set(gcf,'position',[100,70,1100,550],'menubar','none')
            subplot(2,1,1)
            plot(time_accel,f_accel)
            legend('X accel','Y accel','Z accel');
            xlabel('Time (s)','interpreter','latex','fontsize',13);
            ylabel('Acceleration','interpreter','latex','fontsize',13);
            title('Filtered Acceleration vs. Time','interpreter','latex','fontsize',20);
            xlim([0 time_accel(end)])
            ylim([0 20])
            grid on
            subplot(2,1,2)
            plot(amp,'color','red','linewidth',1.5)
            hold on
            fplot(threshold,'b','linewidth',1.5)
            xlim([0 time_accel(end)])
            ylim([0 20])
            legend('Value','Threshold');
            xlabel('Time (s)','interpreter','latex','fontsize',13);
            title('Graphical Representation of the Detection Algorithm','interpreter','latex','fontsize',15);
            grid on
            hold off
            
            %If the numerical value of the detection algorithm surpasses
            %a certain threshold of what is considered normal movement, the
            %counter of seizure detection starts. Also, a speed between 10
            %and 40 km/h would not result in detection (for example,
            %vibrations when riding a bicycle would not result in
            %detection).
            if amp(end) > threshold && (speed(end) < 2.77 || speed(end) > 11.11) 
                counter1 = counter1 + 1;
                if counter1 > 5 % Once the abnormal movements have been maintained for 5 seconds, a seizure is considered detected
                    tic; % We count the duration time of an epileptic seizure
                    fprintf("SEIZURE DETECTED\n")
                    latitude = degrees2dms(lat(end)); % We convert the position data to degrees, minutes and seconds, and print it
                    longitude = degrees2dms(lon(end));
                    fprintf("Location: %dº %d' %.1f"" Latitude and %dº %d' %.1f"" Longitude\n",latitude(1), latitude(2), latitude(3), longitude(1), longitude(2), longitude(3))
                    flag = 1; % This signals that a seizure has been detected
                    fprintf(ard,'%d',flag); % Send info to Arduino board
                end
            elseif flag == 1 % The amplitude is less than the threshold (normal) and a seizure has been flagged previously
                counter2 = counter2 + 1;
                if counter2 > 5  % Once the normal movements have been maintained for 5 seconds, a seizure is considered finalized
                    T = toc;  % The duration of the seizure is recorded
                    counter1 = 0;  % The counter is reset for following seizures
                    counter2 = 0;
                    fprintf("Seizure lasted %.1f seconds\n",T)
                    flag = 0;  % The flag is reset for following seizures
                    fprintf(ard,'%d',flag); %
                    
                    seizure_log = [seizure_log; now, T, latitude(1), latitude(2), latitude(3), longitude(1), longitude(2), longitude(3)];
                end
            end
            
            
            if size_before == size_after  %When the device stops recording, get out of the loop
                break
            end
        
        end
        
    end
    
    if size_before == size_after %When the device stops recording, get out of the loop and finish the program
        break
    end
    
end

filename = 'mydata_accel.xlsx';
xlswrite(filename,[time_accel f_accel]);

filename1 = 'mydata_amp.xlsx';
xlswrite(filename1,amp(:));

filename2 = 'mydata_log.xlsx';
xlswrite(filename2,seizure_log);

