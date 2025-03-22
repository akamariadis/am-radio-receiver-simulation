import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import butter, lfilter

# AM Signal
fs = 2500000  # Sampling Frequency
f_carrier = 950000  # Radio Frequency Signal
f_signal = 2000  # Information Signal
duration = 0.02
t = np.linspace(0, duration, int(fs * duration), endpoint = False)

message = np.sin(2 * np.pi * f_signal * t)

# AM Configuration
carrier = np.cos(2 * np.pi * f_carrier * t)
am_signal = (1 + 0.7 * message) * carrier

# Demodulation
rectified_signal = np.abs(am_signal)
rectified_signal -= np.mean(rectified_signal)  # Remove DC Offset

# Filtering (Low-pass filter)
def butter_lowpass(cutoff, fs, order=3):
    nyq = 0.5 * fs
    normal_cutoff = cutoff / nyq
    b, a = butter(order, normal_cutoff, btype='low', analog=False)
    return b, a

def lowpass_filter(data, cutoff, fs, order=3):
    b, a = butter_lowpass(cutoff, fs, order=order)
    y = lfilter(b, a, data)
    return y

cutoff_freq = 3000  # Adjusted cutoff frequency
filtered_signal = lowpass_filter(rectified_signal, cutoff_freq, fs)

plt.figure(figsize=(12, 8))
plt.subplot(3, 1, 1)
plt.plot(t, am_signal)
plt.title('AM Signal')

plt.subplot(3, 1, 2)
plt.plot(t, rectified_signal)
plt.title('Demodulated Signal (Envelope Detector)')

plt.subplot(3, 1, 3)
plt.plot(t, filtered_signal)
plt.title('Filtered Signal (Recovered Information)')
plt.xlabel('Time (s)')

plt.tight_layout()
plt.show()
