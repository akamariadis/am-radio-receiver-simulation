% Variables
fs = 2e6;
t = 0:1/fs:0.005;
fc = 1e6;
fm = 2e3;
Am = 0.8;
Ac = 3;

% AM Signal Generation
message_signal = Am * sin(2*pi*fm*t);
carrier_signal = Ac * cos(2*pi*fc*t);
am_signal = (1 + message_signal) .* carrier_signal;

% Tuning Circuit (Band-pass filter)
bpFilt = designfilt('bandpassiir','FilterOrder',4, ...
    'HalfPowerFrequency1', 990e3, 'HalfPowerFrequency2', 1010e3, ...
    'SampleRate', fs);
tuned_signal = filter(bpFilt, am_signal);

% Peak detector simulation
rectified_signal = max(tuned_signal, 0);
RC = 1 / (2*pi*fm);
[b, a] = butter(1, fm/(fs/2));
envelope_signal = filter(b, a, rectified_signal);

% 4. High-pass Filter (Removing DC offset)
hpFilt = designfilt('highpassiir','FilterOrder',4, ...
    'HalfPowerFrequency', 50, 'SampleRate', fs);
filtered_signal = filter(hpFilt, envelope_signal);

% 5. Amplification
amplified_signal = 10 * filtered_signal;

% Results
figure;
subplot(4,1,1);
plot(t, am_signal);
title('AM Signal'); xlabel('Time (s)'); ylabel('Amplitude');

subplot(4,1,2);
plot(t, tuned_signal);
title('Tuned Signal'); xlabel('Time (s)'); ylabel('Amplitude');

subplot(4,1,3);
plot(t, envelope_signal);
title('Demodulated Signal'); xlabel('Time (s)'); ylabel('Amplitude');

subplot(4,1,4);
plot(t, amplified_signal);
title('Amplified Audio Signal'); xlabel('Time (s)'); ylabel('Amplitude');

sound(amplified_signal, fs);
