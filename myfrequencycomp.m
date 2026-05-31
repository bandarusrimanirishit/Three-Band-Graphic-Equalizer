%% ADALM1000 Real-time Oscilloscope + Audio @ ~42 kHz (Dual IIR Filtered)
% Requirements: Data Acquisition Toolbox (adi adaptor) and Audio Toolbox
clear; clc; close all;

% -------------------------
% --- User parameters -----
% -------------------------
mp3path = 'C:\Users\srima\Downloads\Suzume no TojimariSuzumeTheme Song.mp3';
Fs_audio = 48000;        % PC speaker sample rate (Hz)
Fs_m1k   = 48000;        % ADALM1000 update rate (Hz)
blockSize = 2048;        % ~43 ms per block
hpCutoff = 400;          % high-pass cutoff for DC removal (Hz)
lpCutoff = 12000;        % low-pass cutoff for noise suppression (Hz)

% -------------------------

%% --- Load & prepare MP3 ---
[inputSignal, Fs_orig] = audioread(mp3path);
if size(inputSignal,2) > 1
    inputSignal = mean(inputSignal,2); % convert to mono
end

% Normalize and scale for M1K output (0.1 - 4.9 V)
inputSignal = inputSignal ./ max(abs(inputSignal));
inputSignal = 2.5 + 2.4 * inputSignal;  % center 2.5V, swing ~0.1..4.9V

% Resample to M1K rate
[inputSignal, ~] = resample(inputSignal, Fs_m1k, Fs_orig);
N = length(inputSignal);
timeFull = (0:N-1)/Fs_m1k;

%% --- Configure DAQ (ADALM1000) ---
dq = daq("adi");
device_id = "SMU1";  % your M1K device ID
addoutput(dq, device_id, "A", "Voltage"); % CH A output
addinput(dq, device_id, "B", "Voltage");  % CH B input

%% --- Setup realtime audio streaming ---
deviceWriter = audioDeviceWriter('SampleRate', Fs_audio);

%% --- Design dual IIR filters ---
% High-pass filter (for DC removal)
[b_hp, a_hp] = butter(2, hpCutoff/(Fs_m1k/2), 'high');
zi_hp = zeros(max(length(a_hp),length(b_hp))-1,1);

% Low-pass filter (for noise suppression)
[b_lp, a_lp] = butter(4, lpCutoff/(Fs_m1k/2), 'low');
zi_lp = zeros(max(length(a_lp),length(b_lp))-1,1);

%% --- Real-time oscilloscope setup ---
numBlocks = ceil(N / blockSize);
figure('Name','Realtime Scope (CH A red, CH B blue)','NumberTitle','off');
hA = plot(nan, nan, 'r', 'LineWidth', 1.2); hold on;
hB = plot(nan, nan, 'b', 'LineWidth', 1.0);
xlabel('Time (s)');
ylabel('Voltage (V)');
title('Real-Time Oscilloscope: CH A (red) vs CH B (blue)');
ylim([0 5]); grid on;
legend('CH A (Output)','CH B (Measured)');
drawnow;

% Preallocate buffers
storeIn  = zeros(N,1);
storeOut = zeros(N,1);
fprintf('Starting playback at %.0f Hz, %d blocks (~%.1f s total)\n', Fs_m1k, numBlocks, N/Fs_m1k);

%% --- Main realtime loop ---
for blk = 1:numBlocks
    sidx = (blk-1)*blockSize + 1;
    eidx = min(blk*blockSize, N);
    blockOut = inputSignal(sidx:eidx);

    % Output + simultaneous read
    dataIn_tt = readwrite(dq, blockOut);
    blockMeasured = dataIn_tt{:,:};

    % Store for analysis
    storeOut(sidx:eidx) = blockOut;
    storeIn (sidx:eidx) = blockMeasured;

    % --- Step 1: DC offset removal (HP filter) ---
    blockAudio = blockMeasured - 2.5; % remove DC offset
    [blockAudioHP, zi_hp] = filter(b_hp, a_hp, blockAudio, zi_hp);

    % --- Step 2: Noise suppression (LP filter) ---
    [blockAudioClean, zi_lp] = filter(b_lp, a_lp, blockAudioHP, zi_lp);

    % Soft clip (avoid distortion)
    blockAudioClean = max(min(blockAudioClean, 1), -1);

    % Direct playback
    deviceWriter(blockAudioClean);

    % --- Update plot ---
    t_block = (0:length(blockOut)-1)/Fs_m1k + (sidx-1)/Fs_m1k;
    set(hA, 'XData', t_block, 'YData', blockOut);
    set(hB, 'XData', t_block, 'YData', blockMeasured);
    drawnow limitrate;
end

fprintf('Playback finished.\n');

%% --- Cleanup ---
release(deviceWriter);
release(dq);

%% --- Final Plots ---
figure('Name','Full Waveforms','NumberTitle','off');
subplot(3,1,1);
plot(timeFull, storeOut, 'r');
xlabel('Time (s)'); ylabel('Voltage (V)');
title('Full Output (CH A)');
ylim([0 5]); grid on;

subplot(3,1,2);
plot(timeFull, storeIn, 'b');
xlabel('Time (s)'); ylabel('Voltage (V)');
title('Full Measured (CH B)');
ylim([0 5]); grid on;

subplot(3,1,3);
plot(timeFull, storeOut, 'r'); hold on;
plot(timeFull, storeIn, 'b');
xlabel('Time (s)'); ylabel('Voltage (V)');
title('Comparison: CH A vs CH B');
ylim([0 5]); grid on;
legend('CH A','CH B');
