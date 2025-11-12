clear;
close all;
clf;
clc;

fs = 48e3;
dur = 3;
t = (0:1/fs:dur-1/fs).';
fc = 729;
mu = 0.7;
SNRdB = 25;

m = 0.6*sin(2*pi*220*t) + 0.3*sin(2*pi*440*t) + 0.2*sin(2*pi*880*t);
m = m ./ max(abs(m)+1e-12);

s_tx = (1 + mu*m) .* cos(2*pi*fc*t);
s_rx = awgn(s_tx, SNRdB, 'measured');

rect = abs(s_rx);
lp_cut = 4e3;
Nfir = 200;
b = fir1(Nfir, lp_cut/(fs/2), 'low', hamming(Nfir+1));
y_env = filtfilt(b,1,rect);
y_env = y_env - mean(y_env);

lo = cos(2*pi*fc*t);
y_mix = 2*s_rx .* lo;
y_sync = filtfilt(b,1,y_mix);

m_n = m / max(abs(m)+1e-12);
y_env_n = y_env / max(abs(y_env)+1e-12);
y_sync_n = y_sync / max(abs(y_sync)+1e-12);

figure('Color','w','Position',[100 100 1200 800]);
subplot(3,1,1);
plot(t, s_tx); xlim([0 0.02]); grid on;
xlabel('Time [s]'); ylabel('Amplitude');
title('AM RF Signal @ 729 Hz (zoom)');

subplot(3,1,2);
plot(t, m_n, 'k'); hold on;
plot(t, y_env_n, '--'); plot(t, y_sync_n, ':'); grid on;
xlim([0 0.05]);
xlabel('Time [s]'); ylabel('Amplitude');
title('Baseband vs. Demodulated (Time)');
legend('Original m(t)','Envelope','Synchronous','Location','best');

fftmag = @(x)(20*log10(abs(fft(x))/numel(x) + 1e-12));
f = (0:numel(t)-1)'*fs/numel(t);
half = 1:floor(numel(f)/2);
M = fftmag(m_n);
ME = fftmag(y_env_n);
MS = fftmag(y_sync_n);
subplot(3,1,3);
plot(f(half), M(half)); hold on;
plot(f(half), ME(half), '--'); plot(f(half), MS(half), ':'); grid on;
xlim([0 5000]); xlabel('Frequency [Hz]'); ylabel('Magnitude [dB]');
title('Baseband vs. Demodulated (Spectra)');
legend('Original m(t)','Envelope','Synchronous','Location','best');
