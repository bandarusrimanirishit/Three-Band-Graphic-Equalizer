# Three-Band Graphic Audio Equalizer

A complete analog-to-digital audio signal processing system implementing a three-band graphic equalizer using operational amplifiers and MATLAB digital signal processing. This project bridges analog circuit design with real-time digital implementation using the ADALM1000 test and measurement device.

**Project Contributors:** Bandaru Srimani Rishit (23f3000436), Harsha Vardhan (23f3000126), Sivaraman S

---

## Table of Contents

1. [Theoretical Foundation](#theoretical-foundation)
2. [Implementation Details](#implementation-details)
3. [System Architecture](#system-architecture)
4. [Circuit Components](#circuit-components)
5. [Software Implementation](#software-implementation)
6. [ADALM1000 Setup Guide](#adalm1000-setup-guide)
7. [How to Use](#how-to-use)
8. [MATLAB Code Documentation](#matlab-code-documentation)
9. [Specifications](#specifications)

---

## Theoretical Foundation

### What is an Audio Equalizer?

An audio equalizer is a signal processing device that modifies the frequency content of an audio signal by amplifying or attenuating specific frequency ranges. A graphic equalizer specifically allows independent control of predefined frequency bands, making it intuitive for users to adjust audio characteristics visually.

### Three-Band Architecture

This project implements a **three-band graphic equalizer** that divides the audible spectrum into three distinct frequency bands:

- **Band 1 (Low Frequencies):** ~60 Hz - Bass/Sub-bass range
- **Band 2 (Mid Frequencies):** ~280 Hz - Midrange/Vocals
- **Band 3 (High Frequencies):** ~1200 Hz - Treble/Presence range

### Bandpass Filter Theory

The core of the equalizer relies on **bandpass filters** - filters that allow frequencies within a specific range to pass while attenuating frequencies outside that range.

#### Transfer Function of a Bandpass Filter

A second-order bandpass filter can be described by:

```
H(f) = (ωₙ × Q × jω) / (s² + (ωₙ/Q)s + ωₙ²)
```

Where:
- **ωₙ** = Natural frequency (center frequency)
- **Q** = Quality factor (determines bandwidth)
- **Bandwidth = ωₙ / Q**

Higher Q values create narrower passbands, while lower Q values create wider passbands.

#### Key Parameters for Each Band

| Band | Center Frequency (Hz) | Bandwidth (Hz) | Q Factor |
|------|----------------------|-----------------|----------|
| 1    | 60                   | 80              | 0.75     |
| 2    | 280                  | 370             | 0.76     |
| 3    | 1200                 | 1470            | 0.82     |

### Operational Amplifier (Op-Amp) Configuration

The equalizer uses **active filters** based on op-amp topology:

1. **Inverting Configuration:** High input impedance and controlled gain
2. **Summing Amplifier:** Combines outputs from all three bands
3. **Non-inverting Amplifier:** Final output stage for impedance matching

#### Basic Op-Amp Bandpass Filter Gain

```
Gain(f) = -Rf × (jωC) / (1 + jω(R + Rf×C))
```

Where:
- **Rf** = Feedback resistance
- **C** = Feedback capacitance
- **ω** = Angular frequency (2πf)

### Signal Flow Principle

The system operates on the principle of **superposition:** each frequency band is independently processed, then the outputs are algebraically summed to produce the final filtered output.

```
V_out = Gain₁(f) × V_in(Band1) + Gain₂(f) × V_in(Band2) + Gain₃(f) × V_in(Band3)
```

This allows users to independently adjust the amplitude of each frequency band, effectively "shaping" the audio spectrum.

---

## Implementation Details

### Analog Circuit Design Approach

The equalizer uses a **cascade of independent active bandpass filters** followed by a **summing amplifier** to combine the outputs. This modular approach provides:

- Independent frequency band control
- Minimal interaction between bands
- Stable and predictable frequency response
- Easy component adjustments for custom frequencies

### Bandpass Filter Implementation (Each Stage)

Each of the three frequency bands uses a **multi-stage active filter** consisting of:

1. **Input Coupling Network:**
   - High-pass section to remove DC and very low frequencies
   - Prevents biasing issues in the op-amp stage

2. **Active Bandpass Filter (Op-Amp Based):**
   - Uses a single op-amp in inverting configuration
   - Provides both filtering and gain amplification
   - Center frequency determined by RC components

3. **Output Coupling Network:**
   - Capacitor-based high-pass filter
   - Removes any DC offset from the output
   - Protects subsequent stages

#### Stage 1: Low-Frequency Band (60 Hz) Components

```
Component Values:
- R1a = 20 kΩ (Input resistor)
- R2a = 40 kΩ (Feedback resistor)
- R3a = 160 kΩ (Frequency-setting resistor)
- Ca = 100 nF (Frequency-setting capacitor)

Design Equation:
f₀ = 1 / (2π × √(R2a × R3a) × Ca)
f₀ ≈ 60 Hz
```

#### Stage 2: Mid-Frequency Band (280 Hz) Components

```
Component Values:
- R1b = 4 kΩ (Input resistor)
- R2b = 9 kΩ (Feedback resistor)
- R3b = 30 kΩ (Frequency-setting resistor)
- Cb = 0.1 µF (Frequency-setting capacitor)

Design Equation:
f₀ = 1 / (2π × √(R2b × R3b) × Cb)
f₀ ≈ 280 Hz
```

#### Stage 3: High-Frequency Band (1200 Hz) Components

```
Component Values:
- R1c = 1 kΩ (Input resistor)
- R2c = 2 kΩ (Feedback resistor)
- R3c = 3 kΩ (Frequency-setting resistor)
- Cc = 0.1 µF (Frequency-setting capacitor)

Design Equation:
f₀ = 1 / (2π × √(R2c × R3c) × Cc)
f₀ ≈ 1200 Hz
```

### Gain Control Mechanism

The ratio of resistors (R1/R2) in each stage determines the maximum gain of that band:

```
Gain = -R2 / R1

Stage 1: Gain = -40k / 20k = -2 (6 dB amplification)
Stage 2: Gain = -9k / 4k = -2.25 (7 dB amplification)
Stage 3: Gain = -2k / 1k = -2 (6 dB amplification)
```

The negative sign indicates phase inversion, which is corrected by the summing amplifier stage.

### Summing Amplifier (Output Stage)

The three bandpass outputs are combined using a **weighted summing amplifier**:

```
V_out = -Rf × (V1/R1 + V2/R2 + V3/R3)
```

**Implementation Components:**
- R15 = 2.5 kΩ (Band 1 input weight)
- R16 = 1 kΩ (Band 2 input weight)
- R17 = 900 Ω (Band 3 input weight)
- Rf (Op-Amp Feedback) = 10 kΩ
- Op-Amp: AD8648 (Low-noise, rail-to-rail)

### Digital Signal Processing (DSP) Implementation

The digital equivalent uses **Sallen-Key Butterworth bandpass filters** implemented via MATLAB's Signal Processing Toolbox. This provides:

```matlab
% Design 2nd-order Butterworth bandpass filter
f1 = f0 - BW/2;
f2 = f0 + BW/2;
Wn = [f1 f2]/(Fs/2);  % Normalized frequencies
[b, a] = butter(2, Wn, 'bandpass');  % 2nd-order filter design
y_band = filter(b, a, x) * G;  % Apply filter with gain G
```

---

## System Architecture

### Block Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│          THREE-BAND GRAPHIC EQUALIZER SYSTEM ARCHITECTURE           │
└─────────────────────────────────────────────────────────────────────┘

                    ANALOG CIRCUIT LAYER
    ┌──────────────────────────────────────────────────────────┐
    │  Hardware: LTSpice Simulation (project_demo.asc)         │
    │                                                          │
    │     Audio Input ──► Preamp ──► 3 Bandpass Filters ──►  │
    │                                (60Hz, 280Hz, 1200Hz)     │
    │                                      ▼                   │
    │                              Summing Amplifier ──►       │
    │                                      ▼                   │
    │                              Output Buffer ──►           │
    │                              Audio Output                │
    └──────────────────────────────────────────────────────────┘
                                │
                                │ (Interface)
                                ▼
                 DIGITAL PROCESSING LAYER
    ┌──────────────────────────────────────────────────────────┐
    │ ADALM1000 + MATLAB Real-Time Processing                  │
    │                                                          │
    │  Audio File ──► Digital Filter Bank ──►                 │
    │  (MP3/WAV)       (Butterworth BPF)                       │
    │                          │                              │
    │                   ┌──────┼──────┐                        │
    │                   ▼      ▼      ▼                        │
    │                 Band1  Band2  Band3                      │
    │                          │                              │
    │                          ▼                              │
    │                    Gain Adjustment                       │
    │                          │                              │
    │                          ▼                              │
    │                  Signal Summation                        │
    │                          │                              │
    │      ┌────────────────────┼────────────────────┐         │
    │      │                    │                    │         │
    │      ▼                    ▼                    ▼         │
    │   ADALM1000          PC Speaker           Plots         │
    │   Output (ChA)      Real-time Audio    Visualization    │
    │                                                          │
    │      Real-time Oscilloscope (project.m)                │
    │      - Dual channel monitoring                          │
    │      - Adjustable timebase & volt/div                   │
    │      - DSO or Bode plot modes                          │
    └──────────────────────────────────────────────────────────┘
```

### Information Flow

1. **Input Stage:** Audio signal (MP3/WAV) loaded into MATLAB
2. **Preprocessing:** Signal resampled to ADALM1000 rate (~48-100 kHz)
3. **Parallel Processing:** Three independent Butterworth bandpass filters
4. **Gain Control:** Independent amplitude adjustment per band
5. **Signal Combination:** Outputs summed for final equalized signal
6. **Output Routing:** 
   - ADALM1000 Channel A: Equalized signal to analog circuit
   - ADALM1000 Channel B: Feedback/measurement from analog hardware
   - PC Speaker: Real-time audio playback
7. **Visualization:** Real-time oscilloscope or Bode plots

---

## Circuit Components

### Active Components (Operational Amplifiers)

| Component | Type | Purpose | Quantity |
|-----------|------|---------|----------|
| U1 | UniversalOpAmp2 | Band 1 Filter (60 Hz) | 1 |
| U2 | UniversalOpAmp2 | Band 2 Filter (280 Hz) | 1 |
| U3 | UniversalOpAmp2 | Band 3 Filter (1200 Hz) | 1 |
| U4 | AD8648 | Input Buffer/Preamp | 1 |
| U5 | AD8648 | Summing Amplifier | 1 |
| U6 | AD8648 | Source Combination | 1 |

### Passive Components Summary

#### Resistors
- **Input/Frequency Setting:** 1 kΩ - 160 kΩ range
- **Feedback/Gain Control:** 2 kΩ - 40 kΩ range
- **Impedance Matching:** 50 Ω - 620 kΩ range

#### Capacitors
- **Frequency Setting (Bandpass):** 100 nF - 0.1 µF
- **Coupling/Decoupling:** 1 nF - 1 µF range
- **Output Coupling:** 1 µF

### Power Supply

| Component | Specification |
|-----------|----------------|
| V1 | 5V DC Source |
| Vcom | 2.5V (Mid-supply reference) |
| Vdd | +2.5V (Relative to ground) |
| GND | 0V (Ground reference) |

---

## Software Implementation

### MATLAB Scripts Overview

The project includes five comprehensive MATLAB scripts that progressively build from basic device testing to complete real-time audio processing:

#### 1. **device_test.m** - ADALM1000 Device Detection & Diagnostics
**Purpose:** Verify ADALM1000 hardware connection and driver installation

```matlab
% Check DAQ vendor availability
vendors = daqvendorlist;

% Detect ADI-specific devices
adi_devices = daqlist('adi');

% Create DAQ session
dq = daq('adi');

% Query device information
device_id = adi_devices.DeviceID{1};
device_info = daqhwinfo(dq, device_id);
```

**Usage:**
```bash
>> device_test
```

**Expected Output:**
```
=== DAQ Vendor Check ===
adi

=== Checking ADI Devices ===
Found ADI devices:
  DeviceID  DeviceModel
  ________  ____________
  'SMU1'    'ADALM1000'

=== Testing DAQ Session Creation ===
DAQ session created successfully.
```

---

#### 2. **voltage_reader_code.m** - Continuous Voltage Logging
**Purpose:** Capture and log voltage measurements from both ADALM1000 channels over time

**Key Features:**
- Dual-channel synchronous acquisition
- Configurable sample rate (100 kHz)
- Interval-based averaging
- CSV export for data analysis
- Real-time plotting

```matlab
% Parameters
sampleRate = 100000;   % Hz
interval = 0.5;        % Seconds per block
totalTime = 10;        % Total acquisition time

% Create DAQ session
dev = daq.createSession('adi');
addAnalogInputChannel(dev, 'SMU1', 'A', 'Voltage');
addAnalogInputChannel(dev, 'SMU1', 'B', 'Voltage');

% Acquire data
[data, timestamps] = dev.startForeground();
```

**Usage:**
```bash
>> voltage_reader_code
```

**Output Files:**
- `voltage_avg_30mins.csv` - Time-stamped voltage data

---

#### 3. **device_test.m** - DSO and Bode Plot Measurement
**Purpose:** Real-time oscilloscope and frequency response analysis

**Two Modes:**

**Mode A: Real-Time Digital Oscilloscope (DSO)**
- Dual-channel display (Yellow = Ch A output, Green = Ch B input)
- Adjustable timebase (0.5x - 10x scaling)
- Adjustable volt/div (0.5V - 5V per division)
- Live measurement statistics (Peak-to-peak, frequency estimation)
- Run/Stop control button
- ~33 FPS refresh rate for smooth visualization

```matlab
mode = "DSO";
% GUI features:
% - Interactive waveform display
% - Real-time measurements
% - Timebase and volt/div sliders
% - Run/Stop button
```

**Mode B: Bode Plot Analysis**
- Logarithmic frequency sweep (10 Hz - 10 kHz)
- Magnitude response (dB)
- Phase response (degrees)
- Cross-correlation phase estimation

```matlab
mode = "BODE";
% Generates frequency response plots
% 30 frequency points across decade range
```

**Usage:**
```bash
>> project  % Runs with default mode "BODE"
```

---

#### 4. **graphic_equalizer_sim.m** - Digital Audio Equalization
**Purpose:** Load MP3/WAV audio and apply digital three-band equalization

**Process Flow:**
1. Load audio file (MP3 format)
2. Normalize to [-1, 1] range
3. Design Butterworth bandpass filters for each band
4. Apply filters with independent gains
5. Sum equalized outputs
6. Play audio through PC speakers
7. Generate visualization plots

**Key Functions:**
```matlab
% Load audio
[x, Fs] = audioread(mp3path);

% Design filters for each band
f0 = 60; BW = 80; G = 4;  % Band 1
f1 = f0 - BW/2;
f2 = f0 + BW/2;
Wn = [f1 f2]/(Fs/2);
[b, a] = butter(2, Wn, 'bandpass');

% Apply filter with gain
y_band = filter(b, a, x) * G;

% Play audio
sound(y_eq, Fs);
```

**Visualization Output:**
- Individual band frequency responses
- Time-domain waveforms per band
- Frequency-domain spectra (original vs equalized)
- Combined frequency response

**Usage:**
```bash
>> graphic_equalizer_sim
```

**Configuration:**
Edit the MP3 file path:
```matlab
mp3path = 'C:\Users\YOUR_NAME\path\to\audio.mp3';
```

---

#### 5. **myfrequencycomp.m** - Real-Time Hybrid Oscilloscope + Audio
**Purpose:** Simultaneous real-time oscilloscope monitoring with audio playback

**Advanced Features:**
- Dual IIR filtering for signal conditioning
- High-pass filter (DC removal, default 400 Hz)
- Low-pass filter (noise suppression, default 12 kHz)
- Real-time soft clipping to prevent distortion
- Synchronized audio playback via PC speakers
- Block-by-block processing (~43 ms blocks at 48 kHz)
- Rolling buffer waveform display
- MP3 input to analog output chain

**Signal Flow:**
```
MP3 Input ──► Resample to ADALM1000 rate (48 kHz)
    ▼
Output to ADALM1000 Ch A ──► Analog Circuit
    ▼
Read Back from ADALM1000 Ch B
    ▼
High-Pass Filter (DC removal) ──► Low-Pass Filter (noise)
    ▼
Soft Clipping ──► PC Speaker Playback
    ▼
Real-Time Oscilloscope Display
```

**Key Parameters:**
```matlab
Fs_audio = 48000;          % PC speaker sample rate
Fs_m1k   = 48000;          % ADALM1000 rate
blockSize = 2048;          % ~43 ms per block
hpCutoff = 400;            % High-pass DC removal
lpCutoff = 12000;          % Low-pass noise suppression
```

**Usage:**
```bash
>> myfrequencycomp
```

**Output:**
- Real-time oscilloscope display
- CSV data files for post-analysis
- MP3 audio played through speakers

---

## ADALM1000 Setup Guide

### What is ADALM1000?

The **ADALM1000** (Analog Discovery Lite Module 1000) is a portable electronic test and measurement device developed by Analog Devices. It provides:

- **2 Analog Output Channels:** Generate test signals (±5V range)
- **2 Analog Input Channels:** Measure signals with 12-bit resolution
- **High Sample Rate:** Up to 100 kHz per channel
- **USB Interface:** Simple plug-and-play connectivity
- **Low Cost:** Affordable for educational and prototyping use

**Key Specs:**
```
Resolution: 12-bit
Sample Rate: 0-100 kHz per channel
Voltage Range: 0-5V (typical), ±5V with biasing
USB Power: Single USB connection to PC
Impedance: ~1 MΩ input, ~100 Ω output
```

---

### Step-by-Step ADALM1000 Setup

#### **Step 1: Hardware Connection**

1. **Locate the ADALM1000 device**
   - Small USB device approximately 3" × 2"
   - Includes SMU (Source Measurement Unit) ports

2. **Connect to PC**
   - Use a USB 2.0 or higher cable
   - Connect to a powered USB port (powered hub recommended for stability)
   - LED indicators should light up

3. **Channel Identification**
   - **Channel A:** Primary output channel (orange/yellow terminals)
   - **Channel B:** Secondary input channel (blue/green terminals)
   - **GND:** Ground reference (black terminal)

```
Physical Connection:
┌─────────────────────┐
│   ADALM1000         │
├─────────────────────┤
│ CH A Output │ ●●●   │──► To analog circuit input
│ CH B Input  │ ●●●   │◄── From analog circuit output
│ GND         │ ●     │──► Ground reference
└─────────────────────┘
         │
    USB Cable
         │
         ▼
   Computer USB Port
```

---

#### **Step 2: Driver Installation**

**Windows 10/11:**

1. **Download Required Software**
   - Visit: https://github.com/analogdevicesinc/libiio
   - Download the latest Windows installer (`.exe`)
   - Alternative: Download from Analog Devices official site

2. **Install Device Drivers**
   ```bash
   # Option A: Automatic (Recommended)
   - Run: libiio-installer.exe
   - Follow on-screen prompts
   - Accept all recommended components
   - Restart computer when prompted
   
   # Option B: Manual USB Device Setup
   - Windows: Device Manager → Universal Serial Bus
   - Right-click ADALM1000 → Update driver
   - Select "Browse my computer for driver software"
   - Navigate to driver folder and install
   ```

3. **Verify Installation**
   - Device Manager should show: **Analog Devices ADALM1000**
   - No yellow warning triangles should appear

**Linux:**

```bash
# Install libiio
sudo apt-get install libiio-dev libiio-utils

# Verify device detection
iio_info
```

**macOS:**

```bash
# Using Homebrew
brew install libiio

# Verify
iio_info
```

---

#### **Step 3: MATLAB Configuration**

**A. Install Required MATLAB Toolboxes**

1. **Data Acquisition Toolbox**
   - Open MATLAB
   - Click: Home → Add-Ons → Get Add-Ons
   - Search: "Data Acquisition Toolbox"
   - Install latest version

2. **ADI Hardware Support Package**
   - Home → Add-Ons → Get Add-Ons
   - Search: "ADI Hardware Support"
   - Install the ADALM package

3. **Signal Processing Toolbox** (for filters)
   - Required for filter design and DSP
   - Home → Add-Ons → Get Add-Ons

4. **Audio Toolbox** (optional, for audio playback)
   - For real-time audio processing

**B. Verify MATLAB Recognition**

```matlab
% In MATLAB Command Window:

% Check installed vendors
vendors = daqvendorlist;
disp(vendors);

% Expected output: includes 'adi'

% List connected ADI devices
devices = daqlist('adi');
disp(devices);

% Expected output:
%    DeviceID      DeviceModel
%    _________     ____________
%    'SMU1'        'ADALM1000'
```

**C. Create Test DAQ Session**

```matlab
% Create DAQ session
dq = daq("adi");

% Add output channel (Channel A)
addoutput(dq, "SMU1", "A", "Voltage");

% Add input channel (Channel B)
addinput(dq, "SMU1", "B", "Voltage");

% Set sample rate
dq.Rate = 100000;  % 100 kHz

disp('ADALM1000 Ready!');
```

---

#### **Step 4: Basic I/O Verification**

**A. Output Test - Generate DC Voltage**

```matlab
% Test DC output on Channel A
dq = daq("adi");
addoutput(dq, "SMU1", "A", "Voltage");

% Set 2.5V output
outputVoltage = 2.5;
write(dq, outputVoltage);

% Measure with multimeter on Channel A terminals
fprintf('Outputting %.2f V\n', outputVoltage);
pause(5);
```

**B. Input Test - Measure Applied Voltage**

```matlab
% Test voltage measurement on Channel B
dq = daq("adi");
addinput(dq, "SMU1", "B", "Voltage");

% Take 10 samples at 1 kHz
dq.Rate = 1000;
dq.DurationInSeconds = 0.01;
data = read(dq);

% Display measured voltage
measuredVoltage = mean(data);
fprintf('Measured Voltage on Ch B: %.3f V\n', measuredVoltage);
```

**C. Simultaneous Read/Write Test**

```matlab
% Generate sine wave and measure
dq = daq("adi");
addoutput(dq, "SMU1", "A", "Voltage");
addinput(dq, "SMU1", "B", "Voltage");

Fs = 10000;  % 10 kHz
dq.Rate = Fs;
duration = 1;  % 1 second
t = (0:1/Fs:duration-1/Fs)';

% Create test signal: 1 kHz sine wave, offset to 2.5V DC
sig = 2.5 + 1.5*sin(2*pi*1000*t);

% Acquire data while outputting
[dataIn, ~] = readwrite(dq, sig);

% Plot results
figure;
plot(t, sig, 'r', 'DisplayName', 'Output (Ch A)');
hold on;
plot(t, dataIn, 'b', 'DisplayName', 'Measured (Ch B)');
legend; grid on;
xlabel('Time (s)'); ylabel('Voltage (V)');
title('ADALM1000 Output vs Input');
```

---

#### **Step 5: Troubleshooting Connection Issues**

**Problem: Device not recognized in MATLAB**

**Solution:**
```matlab
% Step 1: Force vendor reset
clear all; clear classes;

% Step 2: Re-list devices
vendors = daqvendorlist;
adi_devices = daqlist('adi');

% Step 3: If still empty, reinstall driver:
% - Windows: Device Manager → Uninstall device driver
% - Restart computer
% - Reinstall ADALM driver from Analog Devices
```

**Problem: Timeout errors during data acquisition**

**Solution:**
```matlab
% Increase timeout threshold
dq = daq("adi");
dq.ScansAvailableOutputFcn = [];  % Disable callbacks

% Use smaller block sizes
blockSize = 512;  % Instead of 2048

% Or increase DAQ timeout in older versions:
% setproperty(dq, 'Timeout', 5);  % 5 second timeout
```

**Problem: Noise or jitter in measurements**

**Solution:**
```matlab
% Use averaging filters
dq = daq("adi");
addinput(dq, "SMU1", "B", "Voltage");

% Acquire multiple reads and average
numReads = 10;
measurements = zeros(1000, numReads);
for i = 1:numReads
    data = read(dq);
    measurements(:,i) = data;
end

% Moving average
smoothed = mean(measurements, 2);
```

---

### Running the MATLAB Scripts with ADALM1000

#### **For graphic_equalizer_sim.m (Pure Digital DSP)**
```matlab
% No ADALM1000 required - works with audio files only
% Simulates the analog circuit behavior digitally

>> graphic_equalizer_sim

% Adjust audio file path in script:
mp3path = 'C:\Users\YourUsername\Music\song.mp3';
```

#### **For project.m (Real-Time Oscilloscope)**
```matlab
% Requires ADALM1000 connected

% Start DSO mode (real-time oscilloscope)
>> project

% Controls:
% - Run/Stop button: Pause acquisition
% - Timebase slider: Adjust time scale
% - Volt/div slider: Adjust voltage scale
% - Adjustable refresh rate: ~33 FPS

% For Bode plot mode, edit:
% mode = "BODE";  % Change from "DSO"
```

#### **For myfrequencycomp.m (Hybrid Audio + Oscilloscope)**
```matlab
% Requires ADALM1000 + Audio Toolbox

% Start real-time audio processing
>> myfrequencycomp

% Adjust audio file:
mp3path = 'C:\Users\YourUsername\Music\song.mp3';

% Monitor real-time oscilloscope display
% Audio plays through PC speakers simultaneously

% Output: voltage_measurements.csv for analysis
```

#### **For voltage_reader_code.m (Data Logging)**
```matlab
% Requires ADALM1000 connected

% Start 10-second voltage logging
>> voltage_reader_code

% Outputs: voltage_avg_30mins.csv
% Contains timestamped Ch A and Ch B voltages
```

---

## System Architecture (Detailed)

### Complete System Integration

```
┌────────────────────────────────────────────────────────────────────┐
│                    COMPLETE SYSTEM ARCHITECTURE                    │
└────────────────────────────────────────────────────────────────────┘

DIGITAL DOMAIN (MATLAB + ADALM1000)
┌──────────────────────────────────────────────────────────┐
│  Audio Source                                            │
│  ├─ MP3/WAV file                                         │
│  └─ Simulated signals (sine combinations)                │
│          ▼                                               │
│  MATLAB Audio Processing                                │
│  ├─ Load & normalize audio                              │
│  ├─ Resample to ADALM1000 rate (48-100 kHz)            │
│  └─ Scale to output range (0.1V - 4.9V)                │
│          ▼                                               │
│  ADALM1000 Output (Channel A)                           │
│  └─ 12-bit DAC → Analog voltage signal                  │
└──────────────────────────────────────────────────────────┘
                      │ USB
                      ▼
ANALOG DOMAIN (Circuit Hardware)
┌──────────────────────────────────────────────────────────┐
│  Input Buffer (U4: AD8648)                               │
│  ├─ Input impedance: ~620 kΩ                            │
│  ├─ Source impedance matching                           │
│  └─ Preamp gain stage                                   │
│          ▼                                               │
│  Three-Band Filter Bank                                 │
│  ├─ Band 1 (60 Hz): U1 + RC components                  │
│  ├─ Band 2 (280 Hz): U2 + RC components                 │
│  └─ Band 3 (1200 Hz): U3 + RC components                │
│          ▼      ▼      ▼                                 │
│     Independent gain control (variable resistors)       │
│          ▼      ▼      ▼                                 │
│  Summing Amplifier (U5: AD8648)                         │
│  ├─ Combine three filtered signals                      │
│  ├─ Apply final gain adjustment                         │
│  └─ Output buffering                                    │
│          ▼                                               │
│  Output Stage (U6: AD8648)                              │
│  ├─ Low impedance buffering                             │
│  ├─ Filter coupling capacitor                           │
│  └─ Protection resistor                                 │
│          ▼                                               │
│  Equalized Audio Output                                 │
│  └─ To speakers or external equipment                   │
└──────────────────────────────────────────────────────────┘
                      │ Feedback
                      ▼
ADALM1000 Input (Channel B)
└─ 12-bit ADC → Measures filtered output
                      │ USB
                      ▼
DIGITAL FEEDBACK LOOP (MATLAB)
├─ Real-time oscilloscope display
├─ Frequency response analysis
├─ Data logging & CSV export
└─ Performance metrics calculation
```

---

## How to Use

### Complete Workflow Example

#### **Stage 1: Verify Hardware Setup**

```bash
# Run diagnostic script
>> device_test
```

Expected output confirms ADALM1000 detection.

---

#### **Stage 2: Test Basic Connectivity**

```bash
# Run voltage logging for 10 seconds
>> voltage_reader_code
```

Verifies that both channels can acquire data.

---

#### **Stage 3: Simulate Equalization (Digital Only)**

```bash
# Run digital equalizer without hardware
>> graphic_equalizer_sim
```

This demonstrates:
- Butterworth filter design
- Band separation effectiveness
- Frequency response plots
- Audio playback through PC speakers

---

#### **Stage 4: Real-Time Hardware Monitoring**

```bash
# Option A: DSO Mode (Real-time oscilloscope)
% Edit project.m: mode = "DSO";
>> project

% Option B: Bode Mode (Frequency response)
% Edit project.m: mode = "BODE";
>> project
```

---

#### **Stage 5: Full Integration (Hybrid Operation)**

```bash
# Run complete real-time system
>> myfrequencycomp
```

This simultaneously:
- Outputs equalized audio to ADALM1000 Channel A
- Measures feedback on Channel B
- Displays real-time oscilloscope
- Plays audio through PC speakers
- Logs data to CSV

---

### Practical Implementation Steps

**For Testing the Analog Circuit with ADALM1000:**

1. Build the three-band equalizer circuit on breadboard
2. Connect ADALM1000 Channel A output to circuit input
3. Connect ADALM1000 Channel B input to circuit output
4. Run `myfrequencycomp.m`
5. Monitor waveforms in real-time
6. Observe frequency response in oscilloscope display
7. Analyze data in generated CSV files

---

## MATLAB Code Documentation

### Function Reference

#### **graphic_equalizer_sim.m Functions**

```matlab
% Design Butterworth bandpass filter
[b, a] = butter(2, [f1 f2]/(Fs/2), 'bandpass');

% Frequency response analysis
[h, w] = freqz(b, a, 2048, Fs);
plot(w, 20*log10(abs(h)));

% FFT analysis
X = abs(fft(x));
plot(f(1:N/2), X(1:N/2));

% Audio playback
sound(audio, Fs);
```

#### **project.m Functions**

```matlab
% Build multi-sine test signal
sig = buildSignal(Fs, f_sines, amp, offset);

% Frequency estimation via zero crossing
f = estimateFreq(sig, Fs);

% Bode plot measurement
[gain, phase] = measureBode(freqs, Fs_m1k, blockSize);
```

#### **myfrequencycomp.m Functions**

```matlab
% High-pass filter design (DC removal)
[b_hp, a_hp] = butter(2, hpCutoff/(Fs/2), 'high');

% Low-pass filter design (noise suppression)
[b_lp, a_lp] = butter(4, lpCutoff/(Fs/2), 'low');

% Stateful filter with initial conditions
[y, zi] = filter(b, a, x, zi);

% Simultaneous read/write
[data_in, ~] = readwrite(dq, data_out);
```

---

## Specifications

### Frequency Response

| Parameter | Value | Notes |
|-----------|-------|-------|
| Band 1 Center Frequency | 60 Hz | Bass/Sub-bass |
| Band 1 Bandwidth | 80 Hz | -3dB points: ~20-100 Hz |
| Band 2 Center Frequency | 280 Hz | Midrange/Vocals |
| Band 2 Bandwidth | 370 Hz | -3dB points: ~95-465 Hz |
| Band 3 Center Frequency | 1200 Hz | Treble/Presence |
| Band 3 Bandwidth | 1470 Hz | -3dB points: ~465-1935 Hz |

### Gain Specifications

| Stage | Voltage Gain | Power Gain | dB Gain |
|-------|-------------|-----------|---------|
| Band 1 | 2 V/V | 4 W/W | +6.02 dB |
| Band 2 | 2.25 V/V | 5.06 W/W | +7.04 dB |
| Band 3 | 2 V/V | 4 W/W | +6.02 dB |
| Summing Stage | Variable | Variable | Variable |

### ADALM1000 Specifications

| Parameter | Value |
|-----------|-------|
| Resolution | 12-bit |
| Sample Rate | 0-100 kHz |
| Voltage Range | 0-5V (typical) |
| Channels | 2 simultaneous input/output |
| USB Interface | USB 2.0/3.0 |
| Power Consumption | ~500 mW |
| Temperature Range | 0-70°C |

### MATLAB Requirements

| Component | Minimum Version |
|-----------|-----------------|
| MATLAB | R2020b or newer |
| Data Acquisition Toolbox | R2021a+ |
| Signal Processing Toolbox | R2020b+ |
| Audio Toolbox | R2021b+ (optional) |

### Computer Requirements

- **OS:** Windows 10/11, Linux, macOS
- **RAM:** 4 GB minimum (8 GB recommended)
- **CPU:** Multi-core processor (Intel i5 or equivalent)
- **USB:** USB 2.0 or higher port with 500 mA available current
- **Audio:** Speakers or headphones for playback

---

## Files in This Repository

| File | Type | Purpose |
|------|------|---------|
| **README.md** | Documentation | Comprehensive system documentation |
| **project_demo.asc** | LTSpice Schematic | Analog circuit design |
| **graphic_equalizer_sim.m** | MATLAB Script | Digital equalizer simulation |
| **project.m** | MATLAB Script | Real-time DSO & Bode plot |
| **myfrequencycomp.m** | MATLAB Script | Hybrid audio + oscilloscope |
| **device_test.m** | MATLAB Script | Hardware diagnostics |
| **voltage_reader_code.m** | MATLAB Script | Data logging |
| **Three-Band Graphic...pdf** | Report | Detailed project report |

---

## Additional Resources

### Useful References

1. **ADALM1000 Official Documentation:**
   - https://wiki.analog.com/resources/eval/user-guides/adalm1000

2. **Data Acquisition Toolbox:**
   - https://www.mathworks.com/help/daq/

3. **Signal Processing Design:**
   - Filter design tools: `fdatool` in MATLAB
   - Bode plot analysis: `bodeplot` function

4. **Audio Processing:**
   - Audio Toolbox documentation
   - Digital Signal Processing fundamentals

### Design Enhancements

1. **Variable Frequency Bands:**
   - Modify center frequencies via resistor/capacitor values
   - Create parametric equalizer

2. **Additional Bands:**
   - Extend to 5-band or 10-band equalizer
   - Replicate filter stages in circuit

3. **Graphic Interface:**
   - Create MATLAB GUI sliders for real-time gain control
   - Implement visual frequency response display

4. **Advanced Filtering:**
   - Implement higher-order Butterworth filters (4th, 6th order)
   - Add parametric EQ capabilities

5. **Hardware Implementation:**
   - Design PCB layout for compact implementation
   - Add potentiometers for analog gain control
   - Implement microcontroller-based digital control

---

**Last Updated:** May 31, 2026  
**Status:** Complete - With MATLAB Implementation & ADALM1000 Setup Guide  
**Languages:** MATLAB (DSP), AGS Script (Simulation), VHDL (future)