clear; clc;
% Detect available devices
devInfo = daq.getDevices;
devID = devInfo(1).ID; % Usually 'SMU1'
disp(['Using DeviceID: ', devID]);

% Parameters
sampleRate = 100000;   % Hz
interval = 0.5;         % Seconds for each average block
totalTime = 10;        % Total logging time in seconds
numReadings = totalTime / interval;

voltagesA = zeros(numReadings, 1);
voltagesB = zeros(numReadings, 1);
timestamps = datetime.empty(numReadings, 0);

for i = 1:numReadings
    % Create DAQ session with both channels
    dev = daq.createSession('adi');
    addAnalogInputChannel(dev, devID, 'A', 'Voltage');
    addAnalogInputChannel(dev, devID, 'B', 'Voltage');
    
    dev.Rate = sampleRate;
    dev.DurationInSeconds = interval; % Capture full 10 seconds

    % Acquire data
    [data, ~] = dev.startForeground();
    release(dev);

    % Store average voltages for this interval
    voltagesA(i) = mean(data(:, 1)); % Channel A
    voltagesB(i) = mean(data(:, 2)); % Channel B
    timestamps(i) = datetime('now');

    fprintf('Interval %d: ChA = %.4f V, ChB = %.4f V\n', ...
        i, voltagesA(i), voltagesB(i));
end

% Save to CSV
filename = 'voltage_avg_30mins.csv';
dataOut = table(timestamps', voltagesA, voltagesB, ...
    'VariableNames', {'Timestamp', 'ChannelA_V', 'ChannelB_V'});
writetable(dataOut, filename);

disp(['Voltage log saved to ', filename]);
disp('Overall Average Voltage:');
disp(['Channel A: ', num2str(mean(voltagesA)), ' V']);
disp(['Channel B: ', num2str(mean(voltagesB)), ' V']);

% Plot results
figure;
plot(timestamps, voltagesA, '-o', timestamps, voltagesB, '-o');
xlabel('Time');
ylabel('Voltage (V)');
legend('Channel A', 'Channel B');
title('Average Voltage over 10-second intervals');
grid on;
