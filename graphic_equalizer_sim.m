%% 3-Band Audio Equalizer using Sallen-Key Butterworth BPF (Digital Equivalent)
clear; clc; close all;

% --- Load Audio ---
mp3path = 'C:\Users\srima\Downloads\Suzume no TojimariSuzumeTheme Song.mp3';
[x, Fs] = audioread(mp3path);
if size(x,2)>1, x=x(:,1); end   % mono
x = x ./ max(abs(x));           % normalize
N = length(x);
t = (0:N-1)/Fs;
f = (0:N-1)*(Fs/N);

% --- Band specifications [f0, BW, Gain] ---
bands = [   60   80   4;     % f0=60 Hz,   BW=80 Hz
           280  370   9.5;   % f0=280 Hz,  BW=370 Hz
          1200 1470   11.5]; % f0=1200 Hz, BW=1470 Hz

% --- Output accumulator ---
y_eq = zeros(size(x));

%% === Loop over each band ===
for k = 1:size(bands,1)
    f0 = bands(k,1); 
    BW = bands(k,2);
    G  = bands(k,3);

    % Band edges (approx for Butterworth BP design)
    f1 = f0 - BW/2;
    f2 = f0 + BW/2;
    if f1 <= 0, f1 = 1; end   % avoid negative
    
    % Normalize to Nyquist
    Wn = [f1 f2]/(Fs/2);

    % --- Design 2nd-order Butterworth band-pass filter (digital) ---
    [b,a] = butter(2, Wn, 'bandpass');

    % Apply filter
    y_band = filter(b,a,x) * G;
    y_eq = y_eq + y_band;

    % === Plot for each band ===
    figure('Name',['Band ' num2str(k)]);
    
    % Filter response
    subplot(3,1,1);
    [h,w] = freqz(b,a,2048,Fs);
    plot(w,20*log10(abs(h)),'LineWidth',1.5);
    xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
    title(sprintf('Band %d Butterworth BPF (f0=%d Hz, BW=%d Hz)',k,f0,BW));
    grid on; xlim([0 2000]);

    % Time-domain output of this band (first 5s for clarity)
    subplot(3,1,2);
    plot(t,y_band);
    xlabel('Time (s)'); ylabel('Amplitude');
    title(sprintf('Band %d Output (Time Domain)',k));
    grid on; xlim([0 5]);

    % Frequency-domain output of this band
    subplot(3,1,3);
    Yband = abs(fft(y_band));
    plot(f(1:N/2),Yband(1:N/2));
    xlabel('Frequency (Hz)'); ylabel('Magnitude');
    title(sprintf('Band %d Output (Frequency Domain)',k));
    grid on; xlim([0 2000]);
end

%% === Normalize Equalized Output ===
y_eq = y_eq ./ max(abs(y_eq));

%% --- Play Equalized Audio ---
disp('Playing Equalized Audio...');
clear sound;            % stop any previous playback
sound(y_eq, Fs);        % play new equalized audio

%% --- Separate FFT Figures ---
% Original
figure('Name','Original Audio FFT');
X = abs(fft(x));
plot(f(1:N/2),X(1:N/2));
xlabel('Frequency (Hz)'); ylabel('Magnitude');
title('Original Audio Spectrum'); grid on; xlim([0 2000]);

% Equalized
figure('Name','Equalized Audio FFT');
Y = abs(fft(y_eq));
plot(f(1:N/2),Y(1:N/2));
xlabel('Frequency (Hz)'); ylabel('Magnitude');
title('Equalized Audio Spectrum'); grid on; xlim([0 2000]);

%% === Combined Frequency Response (Adder) ===
nfft = 2048;
H_total = zeros(1,nfft);

figure('Name','Individual + Combined Frequency Response');
hold on;

for k = 1:size(bands,1)
    f0 = bands(k,1); 
    BW = bands(k,2);
    G  = bands(k,3);

    f1 = f0 - BW/2;
    f2 = f0 + BW/2;
    if f1 <= 0, f1 = 1; end
    Wn = [f1 f2]/(Fs/2);

    [b,a] = butter(2,Wn,'bandpass');
    [h,w] = freqz(b,a,nfft,Fs);

    % Add to combined response
    H_total = H_total + G*h.';
end

% Plot combined response
plot(w,20*log10(abs(H_total)),'r','LineWidth',2.0,'DisplayName','Combined');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('Combined Frequency Response of 3-Band Equalizer');
legend show; grid on; xlim([0 2000]);
