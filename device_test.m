% Diagnostic script for ADALM-1000
clear; clc;

% Check vendors
fprintf('=== DAQ Vendor Check ===\n');
vendors = daqvendorlist;
disp(vendors);

% Check ADI devices specifically  
fprintf('\n=== Checking ADI Devices ===\n');
try
    adi_devices = daqlist('adi');
    if isempty(adi_devices)
        fprintf('No ADI devices found.\n');
    else
        fprintf('Found ADI devices:\n');
        disp(adi_devices);
        
        % Try to create a DAQ session
        fprintf('\n=== Testing DAQ Session Creation ===\n');
        dq = daq('adi');
        fprintf('DAQ session created successfully.\n');
        
        % Get the first device ID
        device_id = adi_devices.DeviceID{1};
        fprintf('Using device ID: %s\n', device_id);
        
        % Try to get device info
        fprintf('\n=== Device Information ===\n');
        try
            device_info = daqhwinfo(dq, device_id);
            disp(device_info);
        catch
            fprintf('Could not get detailed device info.\n');
        end
    end
catch ME
    fprintf('Error: %s\n', ME.message);
end