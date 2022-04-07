Code for 2022 MATLAB Hackaton

Toolboxes needed:

Digital Signal Processing Toolbox
Mapping Toolbox
MATLAB Support Package for Apple iOS Sensors
MATLAB Support Package for Android Sensors
MATLAB Support Package for Arduino Hardware
MATLAB App Designer Toolbox

Description of the Project:

Our team wanted to develop an algorithm capable of using the data given by the sensors of a mobile device to detect epilectic seizures. For this, MATLAB Mobile and MATLAB Drive were used: the output of the sensors of acceleration and position of the phone was sent in real time to the computer MATLAB. There, this data was processed and analyzed to conclude if the user was suffering from a seizure or not, and also to keep a record of some relevant information such as the duration of the epileptic episode, the position of the user at the time of the seizure and a graph representing the evolution of the user's movement data before, during and after the episode.

This project encompasses the Sustainable Development Goals of Health, Poverty and Sustainability:

- Health: this project is clearly health-oriented, as it is an epileptic seizure detector. It is useful to alert people of the user's condition and to keep a record of important imformation both for the user suffering from seizures and for health workers, as they can review the context in which the episode happended and hopefully shed some light on what situations may be possible triggers.

- Poverty: there are already some medical devices used to detect seizures, however many of them rely on electroencephalograms, are based on complex algorithms or are expensive to get. This algorithm can be used only with some basic sensors and a portable device, and it is also much more simple to understand and apply. Our algorithm can be easily used by the general public and it can also be implemented cheaply, which is important for less developed countries and users with poor acquisitive power.

- Sustainability: the hardware needed for this algorithm to work is minimal, as it only needs a couple sensors, a processor to run the algorithm and a screen to deploy the information. This heavily reduces the waste in the manufacturing process compared to more commercial medical devices, and any energy could be used to power the device.

Explanation of the Code:

First, the algorithm connects to the device, enables the required sensors, and starts the real-time transmission of data. The most relevant parameter for detecting a seizure is acceleration, then position and date are also acquired for information purposes.

The program starts plotting and processing the data once enough samples for a relevant analysis have been acquired (once 50 samples are obtained): the first while loop is tasked with acquiring the initial samples and the second while loop is tasked with acquiring the rest of the data, processing and plotting it.

Epileptic seizures are characterized for high frequency movements (tremors), so the signal received was filtered with a high pass of passband frequency 4 and sampling rate 10, to take into account only high frequency movements. Once filtered, the last 50 samples of the acceleration are studied, and when their mean acceleration surpasses the threshold of what is considered normal movements, the algorithm detects it and analyzes for how long this abnormal movement has been maintained. If the abnormal data surpasses 5 seconds, the algorithm considers that an epileptic seizure is taking place (this time criteria is to avoid false positives, there is also a speed criteria to only flag when the user is not moving or moving at high speeds - like having a seizure in a train, and not at speeds of running or biking, as the user could be having high frequency movements due to the activity). Then a warning and the location are printed in the command window, a counter is started to measure the duration of the episode, and a variable called flag changes value to signal the seizure. Once the algorithm detects that the variable flag has changed value (this is so the code only looks for normal data once a seizure has begun) and that normal magnitudes have been achieved again for 5 seconds, it prints a message saying that the epilectic seizure has ended, stops the counter, resets the counters and flag so that they can signal a seizure again, and prints the duration and date of the episode.

The code continually plots the acceleration vs time data received in real-time, so that the sensor's signal can be reviewed visually. It also plots the detection value (which depends on the frequency and magnitude of the last 50 samples) vs time, with the threshold for signalling a seizure printed in the plot, so it can be seen when a movement is approaching abnormal values.

The while loops keep the program running until the device stops recording, which the code detects by comparing the data matrix size before and after a loop (if it is the same, it means no new data has been recorded), therefore exiting the loops and finalizing the program.

MATLAB Application:

An application using the MATLAB App Designer Toolbox was created to visually display in a simple and comprehensive way the data recorded with the sensors. Once the recording has stopped, the data is loaded to the app and various information is represented: both graphs regarding the filtered acceleration vs time and the detection value vs time, and a table containing the data of each seizure detected in the recording: the date and location at which the seizure took place, and the duration of the episode. 

Arduino Hardware:

In order to display the seizure detections outside of the computer, we used an Arduino (Arduino UNO), and the LCD Display Shield. We established a serial connection between MATLAB and the Arduino in order to stream the data directly into the Arduino. The LCD shield also allows to signal that the seizure detection is a false positive. However, right now that is only for display purposes.
