clear; 
close all;
clf;
clc;

Fs = 100e3;
t = 0:1/Fs:0.01;

fm = 1e3;
Am = 1;
message = Am * cos(2*pi*fm*t);

fc = 20e3;
Ac = 2;
carrier = Ac * cos(2*pi*fc*t);

am_signal = (1 + message / Ac) .* carrier;

bpFilt = designfilt('bandpassiir','FilterOrder',6, ...
         'HalfPowerFrequency1',fc-5e3,'HalfPowerFrequency2',fc+5e3, ...
         'SampleRate',Fs);
rf_signal = filter(bpFilt, am_signal);

rectified = abs(rf_signal); % Emulates germanium diode behavior

lpFilt = designfilt('lowpassiir','FilterOrder',8, ...
         'HalfPowerFrequency', 3e3, ...
         'SampleRate',Fs);
audio_recovered = filter(lpFilt, rectified);

preamp_gain = 5;
audio_amplified = preamp_gain * audio_recovered;

speaker_gain = 10;
speaker_output = speaker_gain * audio_amplified;

figure;
subplot(5,1,1);
plot(t*1e3, am_signal);
title('AM Signal (Transmitted)');
xlabel('Time (ms)'); ylabel('Amplitude');

subplot(5,1,2);
plot(t*1e3, rf_signal);
title('After RF Tuning (Bandpass Filter)');
xlabel('Time (ms)');

subplot(5,1,3);
plot(t*1e3, rectified);
title('Envelope Detection (Diode Stage)');
xlabel('Time (ms)');

subplot(5,1,4);
plot(t*1e3, audio_recovered);
title('Low-Pass Filtered Audio (Demodulated)');
xlabel('Time (ms)');

subplot(5,1,5);
plot(t*1e3, speaker_output);
title('Final Audio Output to Speaker');
xlabel('Time (ms)');

sgtitle('AM Radio Receiver Simulation (Digital Equivalent of Your Circuit)');
