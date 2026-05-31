%% ADALM1000 Real-Time DSO or Bode Plot
clear; clc; close all;

%% -------------------------
% --- USER SETTINGS --------
% -------------------------
mode = "BODE";   % "DSO" or "BODE"

Fs_m1k   = 100000;      % ADALM1000 sample rate (100 kHz)
blockSize = 1024;       % samples per block
refreshRate = 0.03;     % ~33 FPS (human perception)

% --- Test signal (Channel A output for DSO)
f_sines = [60 285 1300];  % test freqs
amp     = 1;              % amplitude
offset  = 2.5;            % DC offset
inputSignal = buildSignal(Fs_m1k, f_sines, amp, offset);

%% --- Configure ADALM1000 ---
dq = daq("adi");
device_id = "SMU1";
addoutput(dq, device_id, "A", "Voltage"); % CH A output
addinput(dq, device_id, "B", "Voltage");  % CH B input

%% -------------------------
% --- MODE SELECTION -------
% -------------------------
if mode == "DSO"
    %% --- GUI SETUP ---
    fig = uifigure('Name','ADALM1000 DSO','Color','k','Position',[100 100 1200 600]);

    axA = uiaxes(fig,'Position',[50 300 500 250],'XColor','w','YColor','w','GridColor',[0.5 0.5 0.5],'Color','k');
    title(axA,'Channel A (Output)','Color','w');
    ylabel(axA,'Voltage (V)','Color','w'); xlabel(axA,'Time (s)','Color','w');
    grid(axA,'on'); hold(axA,'on');
    hA = plot(axA,nan,nan,'y','LineWidth',1.5); % YELLOW for CH A

    axB = uiaxes(fig,'Position',[650 300 500 250],'XColor','w','YColor','w','GridColor',[0.5 0.5 0.5],'Color','k');
    title(axB,'Channel B (Input)','Color','w');
    ylabel(axB,'Voltage (V)','Color','w'); xlabel(axB,'Time (s)','Color','w');
    grid(axB,'on'); hold(axB,'on');
    hB = plot(axB,nan,nan,'g','LineWidth',1.5); % GREEN for CH B

    % Measurement window (bottom-right)
    txt = uitextarea(fig,'Position',[800 50 300 200], ...
        'Editable','off','FontSize',12,'FontColor','w','BackgroundColor',[0.1 0.1 0.1]);

    % Run/Stop button
    btn = uibutton(fig,'state','Text','Run/Stop','Position',[200 80 100 40], ...
        'Value',true,'BackgroundColor',[0.3 0.3 0.3],'FontColor','w');

    % Timebase slider
    sl_time = uislider(fig,'Position',[100 250 300 3],'Limits',[0.5 10],'Value',1);
    lbl_time = uilabel(fig,'Position',[420 240 120 30],'Text','Timebase: 1x','FontColor','w','BackgroundColor','k');

    % Volt/div slider
    sl_volt = uislider(fig,'Position',[100 200 300 3],'Limits',[0.5 5],'Value',1);
    lbl_volt = uilabel(fig,'Position',[420 190 120 30],'Text','Volt/div: 1x','FontColor','w','BackgroundColor','k');

    % Update slider labels live
    sl_time.ValueChangingFcn = @(src,event) set(lbl_time,'Text',sprintf('Timebase: %.1fx',event.Value));
    sl_volt.ValueChangingFcn = @(src,event) set(lbl_volt,'Text',sprintf('Volt/div: %.1fx',event.Value));

    %% --- Real-Time Continuous Loop ---
    t_buffer = []; A_buffer = []; B_buffer = [];
    maxPoints = 5000;  % rolling window (~0.05s at Fs=100k)

    while isvalid(fig)
        if btn.Value  % RUN mode
            blockOut = inputSignal(1:blockSize);
            dataIn_tt = readwrite(dq, blockOut);
            blockIn = dataIn_tt{:,:};

            % Append to rolling buffer
            t_new = (0:blockSize-1)/Fs_m1k;
            if isempty(t_buffer), t_offset = 0; else, t_offset = t_buffer(end)+1/Fs_m1k; end
            t_new = t_new + t_offset;

            t_buffer = [t_buffer; t_new'];
            A_buffer = [A_buffer; blockOut];
            B_buffer = [B_buffer; blockIn];

            % Limit buffer size
            if numel(t_buffer) > maxPoints
                t_buffer = t_buffer(end-maxPoints+1:end);
                A_buffer = A_buffer(end-maxPoints+1:end);
                B_buffer = B_buffer(end-maxPoints+1:end);
            end

            % Apply scaling
            t_disp = (t_buffer - t_buffer(1)) * sl_time.Value;
            A_disp = A_buffer * sl_volt.Value;
            B_disp = B_buffer * sl_volt.Value;

            % Update plots
            set(hA,'XData',t_disp,'YData',A_disp);
            set(hB,'XData',t_disp,'YData',B_disp);

            % Adjust axes
            xlim(axA,[t_disp(1) t_disp(end)]);
            ylim(axA,[0 5]*sl_volt.Value);
            xlim(axB,[t_disp(1) t_disp(end)]);
            ylim(axB,[0 5]*sl_volt.Value);

            % --- Update measurements ---
            A_pkpk = max(A_buffer)-min(A_buffer);
            B_pkpk = max(B_buffer)-min(B_buffer);
            A_freq = estimateFreq(A_buffer, Fs_m1k);
            B_freq = estimateFreq(B_buffer, Fs_m1k);

            txt.Value = {
                sprintf('CH A: %.2f Vpp, %.1f Hz',A_pkpk,A_freq)
                sprintf('CH B: %.2f Vpp, %.1f Hz',B_pkpk,B_freq)
                sprintf('Timebase: %.1fx',sl_time.Value)
                sprintf('Volt/div: %.1fx',sl_volt.Value)
            };
        end

        drawnow limitrate;
        pause(refreshRate);
    end

elseif mode == "BODE"
    %% --- Bode Plot Measurement ---
    freqs = logspace(1,4,30);   % 10 Hz to 10 kHz
    gain = zeros(size(freqs));
    phase = zeros(size(freqs));

    for k = 1:numel(freqs)
        f = freqs(k);
        t = (0:blockSize-1)/Fs_m1k;
        sig = sin(2*pi*f*t)';  % test sine

        % Send + capture
        data = readwrite(dq,sig);
        A = sig;
        B = data{:,:};

        % Gain
        gain(k) = rms(B)/rms(A);

        % Phase (estimate via xcorr)
        [c,lags] = xcorr(A,B);
        [~,idx] = max(abs(c));
        lag = lags(idx);
        phase(k) = -360*lag/(Fs_m1k/f);
    end

    % Plot Bode
    figure('Name','Bode Plot','Position',[100 100 800 600]);
    subplot(2,1,1);
    semilogx(freqs,20*log10(gain),'b','LineWidth',1.5);
    grid on; ylabel('Magnitude (dB)');

    subplot(2,1,2);
    semilogx(freqs,phase,'r','LineWidth',1.5);
    grid on; xlabel('Frequency (Hz)'); ylabel('Phase (deg)');
end

%% --- Cleanup
stop(dq);
clear dq;

%% =============================
% --- Functions ---
%% =============================
function sig = buildSignal(Fs, f_sines, amp, offset)
    dur = 10; % long duration for continuous streaming
    t = (0:1/Fs:dur-1/Fs)';

    f_nonzero = f_sines(f_sines > 0);
    if isempty(f_nonzero)
        sig = offset * ones(size(t));
    elseif numel(f_nonzero) == 1
        sig = offset + amp * sin(2*pi*f_nonzero*t);
    else
        sig = zeros(size(t));
        for k = 1:numel(f_nonzero)
            sig = sig + amp * sin(2*pi*f_nonzero(k)*t);
        end
        sig = sig / numel(f_nonzero);
        sig = offset + sig;
    end
end

function f = estimateFreq(sig, Fs)
    sig = sig - mean(sig);
    zc = find(diff(sign(sig))~=0);
    if length(zc)<2, f=0; return; end
    period = mean(diff(zc))/Fs;
    f = 1/period;
end
