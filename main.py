import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import butter, lfilter

# AM Signal
fs = 1000000  # Sampling Frequency
f_carrier = 950000  # RF Signal (950 kHz)
f_signal = 2000  # Information Signal (2 kHz)
duration = 0.02
t = np.linspace(0, duration, int(fs * duration), endpoint=False)

message = np.sin(2 * np.pi * f_signal * t)

# AM Configuration
carrier = np.cos(2 * np.pi * f_carrier * t)
am_signal = (1 + 0.7 * message) * carrier

# Demodulation
rectified_signal = np.abs(am_signal)

# Filtering (Low-pass filter)
def butter_lowpass(cutoff, fs, order=5):
    nyq = 0.5 * fs
    normal_cutoff = cutoff / nyq
    b, a = butter(order, normal_cutoff, btype='low', analog=False)
    return b, a

def lowpass_filter(data, cutoff, fs, order=5):
    b, a = butter_lowpass(cutoff, fs, order=order)
    y = lfilter(b, a, data)
    return y

cutoff_freq = 8000  # 8 kHz
filtered_signal = lowpass_filter(rectified_signal, cutoff_freq, fs)

plt.figure(figsize=(12, 8))
plt.subplot(3, 1, 1)
plt.plot(t, am_signal)
plt.title('AM Σήμα')
plt.subplot(3, 1, 2)
plt.plot(t, rectified_signal)
plt.title('Αποδιαμορφωμένο Σήμα (Ανιχνευτής Κορυφής)')
plt.subplot(3, 1, 3)
plt.plot(t, filtered_signal)
plt.title('Φιλτραρισμένο Σήμα (Ανάκτηση Πληροφορίας)')
plt.xlabel('Χρόνος (s)')
plt.tight_layout()
plt.show()