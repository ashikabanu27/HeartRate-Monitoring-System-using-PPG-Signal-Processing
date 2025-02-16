clc;
clear all;
close all;

% Load the PPG signal
[ppg_signal, Fs] = audioread('/MATLAB Drive/bidmc11m.mat');
% Sampling frequency in Hz
Fs = 100; 

% Ensure the signal is a column vector
ppg_signal = ppg_signal(:);

% Design IIR filter
iir_order = 7;
iir_cutoff = 5; % Cutoff frequency in Hz
[iir_b, iir_a] = butter(iir_order, iir_cutoff/(Fs/2), 'low');

% Filter the PPG signal
filtered_iir = filtfilt(iir_b, iir_a, ppg_signal);

% Detect peaks in the filtered signal
min_peakdistance = round(Fs/2);
[~, locs_iir] = findpeaks(filtered_iir, 'MinPeakDistance', min_peakdistance, 'MinPeakHeight', 0.2);

% Calculate instantaneous heart rate in beats per minute (bpm)
inst_hr = 60 * Fs ./ diff(locs_iir);
time_inst_hr = locs_iir(2:end) / Fs; % Time vector for instantaneous heart rate

% Calculate average heart rate
hr_iir = mean(inst_hr);

% Plot original and filtered signals with detected peaks
t = (0:length(filtered_iir)-1) / Fs; % Time vector
figure;
subplot(3, 1, 1);
plot(t, ppg_signal);
title('Original PPG Signal');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(3, 1, 2);
plot(t, filtered_iir);
hold on;
plot(t(locs_iir), filtered_iir(locs_iir), 'ro', 'MarkerFaceColor', 'r');
title('IIR Filtered PPG Signal with Detected Peaks');
xlabel('Time (s)');
ylabel('Amplitude');
legend('Filtered Signal', 'Detected Peaks');

subplot(3, 1, 3);
plot(time_inst_hr, inst_hr);
title('Instantaneous Heart Rate (bpm)');
xlabel('Time (s)');
ylabel('Heart Rate (bpm)');

% Display calculated heart rate
disp(['Estimated Heart Rate: ', num2str(hr_iir), ' bpm']);
