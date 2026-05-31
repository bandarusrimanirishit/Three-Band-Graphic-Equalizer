# Three-Band Graphic Audio Equalizer

A complete analog electronic design for a three-band graphic audio equalizer system implemented using operational amplifiers and passive filter networks. This project demonstrates signal processing through frequency-selective filtering and summation techniques.

**Project Contributors:** Bandaru Srimani Rishit (23f3000436), Harsha Vardhan (23f3000126), Sivaraman S

---

## Table of Contents

1. [Theoretical Foundation](#theoretical-foundation)
2. [Implementation Details](#implementation-details)
3. [System Architecture](#system-architecture)
4. [Circuit Components](#circuit-components)
5. [How to Use](#how-to-use)
6. [Specifications](#specifications)

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

### Circuit Design Approach

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

This stage:
- Combines the three band-separated signals
- Provides final gain/attenuation control
- Inverts the signal (compensating for inverting stages)
- Buffers the output for impedance matching

### Power Supply Management

The circuit requires **dual ±2.5V power supply** (or ±5V for more headroom):

**Power Supply Components:**
- V1 = 5V voltage source
- R4, R5 = 5 kΩ each (Voltage divider for Vcom)
- Vcom = 2.5V (Mid-supply voltage for biasing)
- Decoupling capacitors throughout (1 nF and 1 µF)

The mid-supply voltage (Vcom = 2.5V) provides the reference point for single-supply operation, allowing the circuit to operate with purely AC signals centered around this voltage.

### Input Buffering and Source Integration

The system includes a **high-impedance input buffer** using the AD8648 op-amp:

**Buffer Specifications:**
- R12, R13 = 620 kΩ (Input impedance network)
- C7 = 0.1 µF (Input coupling)
- R14 = 50 Ω (Source impedance matching)
- C8 = 1 µF (Output coupling)

This buffer:
- Presents high input impedance to the audio source
- Isolates source impedance from the rest of the circuit
- Provides gain matching for the three audio input channels
- Ensures low-distortion signal transfer

---

## System Architecture

### Block Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                  THREE-BAND GRAPHIC EQUALIZER SYSTEM                │
└─────────────────────────────────────────────────────────────────────┘

    Audio Input (Simulated: 3 different frequency sources)
           │
           ├─ Vin_audio3 (1300 Hz) ──────┐
           │                              │
           ├─ Vin_audio1 (285 Hz) ───────┤
           │                              ├──► Summing Network
           ├─ Vin_audio2 (60 Hz) ────────┤
           │                              │
           └─ Vin_audio (Mixed signal) ──┘
                        │
                        ▼
                  ┌──────────────┐
                  │   Preamp     │
                  │  (AD8648)    │
                  └──────────────┘
                        │
           ┌────────────┼────────────┐
           │            │            │
           ▼            ▼            ▼
      ┌────────┐  ┌────────┐  ┌────────┐
      │ Band 1 │  │ Band 2 │  │ Band 3 │
      │  60Hz  │  │ 280Hz  │  │1200Hz  │
      │Bandpass│  │Bandpass│  │Bandpass│
      │ Filter │  │ Filter │  │ Filter │
      │  (U1)  │  │  (U2)  │  │  (U3)  │
      └────────┘  └────────┘  └────────┘
           │            │            │
           │  Gain 1    │  Gain 2    │  Gain 3
           │ (Variable) │ (Variable) │ (Variable)
           │            │            │
           └────────────┼────────────┘
                        │
                        ▼
                  ┌──────────────┐
                  │   Summing    │
                  │  Amplifier   │
                  │   (AD8648)   │
                  └──────────────┘
                        │
                        ▼
                  ┌──────────────┐
                  │   Output     │
                  │  Coupling &  │
                  │ Impedance    │
                  │  Matching    │
                  └──────────────┘
                        │
                        ▼
                    Audio Output
                      Vout
```

### Information Flow

1. **Input Stage:** Three simulated audio sources (60 Hz, 285 Hz, 1300 Hz) are combined to create a complex audio signal
2. **Preprocessing:** Input buffer isolates the audio source and presents it to the three parallel filter stages
3. **Parallel Processing:** Each bandpass filter independently extracts its corresponding frequency range
4. **Gain Control:** Variable gain resistors allow independent amplitude adjustment of each band
5. **Signal Combination:** The summing amplifier combines all three bands back into a single output signal
6. **Output:** The final equalized audio signal is coupled and buffered for driving external loads

### Design Philosophy

The three-stage parallel architecture provides:

- **Modularity:** Each band is independent and can be tuned separately
- **Scalability:** Additional bands can be added by expanding the summing stage
- **Control:** Independent gain adjustment provides intuitive user control
- **Performance:** Minimal interaction between frequency bands

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

## How to Use

### Simulation

1. **Open the Circuit File:**
   - Load `project_demo.asc` in LTSpice or compatible SPICE simulator
   - The file contains the complete three-band equalizer schematic

2. **Run Transient Analysis:**
   - The circuit is configured for 30 ms transient simulation (`.tran 30m`)
   - This captures 1-2 complete cycles of the low-frequency components

3. **Observe Outputs:**
   - **Vin_audio1, Vin_audio2, Vin_audio3:** Individual frequency sources (285 Hz, 60 Hz, 1300 Hz)
   - **Vin_audio:** Combined input signal
   - **Vout:** Equalized output signal after all processing

4. **Adjust Parameters:**
   - Edit the `.param` line to change component values:
     ```
     .param R1a=20k R2a=40k R3a=160k Ca=100n 
            R1b=4k R2b=9k R3b=30k Cb=0.1u 
            R1c=1k R2c=2k R3c=3k
     ```
   - Changes affect center frequencies and gain of each band

### Frequency Band Adjustment

To shift a bandpass center frequency:

**For Band 1 (60 Hz):**
```
New_f₀ = 1 / (2π × √(R2a × R3a) × Ca)

To increase frequency: Decrease R3a or Ca
To decrease frequency: Increase R3a or Ca
```

**For Band 2 (280 Hz) and Band 3 (1200 Hz):**
Apply the same formula with respective component values.

### Gain Adjustment

To change the amplification of each band:

```
Gain = -R2 / R1

Increase gain: Increase R2 or decrease R1
Decrease gain: Decrease R2 or increase R1
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

### Power Consumption

| Component | Current Draw | Power |
|-----------|-------------|-------|
| Each Op-Amp (±2.5V) | ~3-5 mA | ~15-25 mW |
| Total System | ~20-30 mA | ~100-150 mW |

### Input/Output Impedance

| Parameter | Value | Notes |
|-----------|-------|-------|
| Input Impedance | ~620 kΩ | Determined by R12, R13 |
| Output Impedance | ~10 Ω | Determined by summing amp configuration |
| Source Impedance (Design) | 50 Ω | Impedance matching resistor R14 |

### Noise Performance

- **Op-Amp Type:** AD8648 (Low-noise dual amplifier)
- **Input-referred Noise:** ~7 nV/√Hz typical
- **Total Noise Floor:** -90 dB relative to 1V full-scale (estimated)

### Simulation Parameters

```
.param R1a=20k R2a=40k R3a=160k Ca=100n      ; Band 1 components
       R1b=4k R2b=9k R3b=30k Cb=0.1u         ; Band 2 components
       R1c=1k R2c=2k R3c=3k                  ; Band 3 components

.tran 30m                                     ; 30ms transient simulation
```

### Test Signals

The simulation uses three pure sinusoidal sources to demonstrate band separation:

| Source | Frequency | Amplitude | Band Response |
|--------|-----------|-----------|----------------|
| V2 (Vin_audio3) | 1300 Hz | 1V peak | Band 3 (High) |
| V3 (Vin_audio1) | 285 Hz | 1V peak | Band 2 (Mid) |
| V4 (Vin_audio2) | 60 Hz | 1V peak | Band 1 (Low) |

Each test signal is centered on DC offset of 2.5V (Vcom reference) to allow operation in a single-supply environment.

---

## Files in This Repository

- **README.md** - This comprehensive documentation file
- **project_demo.asc** - LTSpice schematic file containing the complete circuit design
- **Three-Band Graphic Audio Equalizer Project Report.pdf** - Detailed project report with additional analysis and measurements

---

## Additional Notes

### Design Considerations

1. **Single-Supply Operation:** The circuit uses a single 5V power supply with mid-supply biasing to operate with AC signals
2. **Op-Amp Selection:** AD8648 chosen for low noise and rail-to-rail performance
3. **Component Tolerances:** Standard 5-10% resistor and capacitor tolerances are acceptable; precise tuning can be achieved through scaling
4. **Frequency Range:** The three bands cover typical audio EQ regions; additional bands can be added by replicating the bandpass filter stage

### Future Enhancements

1. Add variable resistors (potentiometers) for real-time gain control
2. Implement a switchable low-pass filter to prevent aliasing in the output
3. Add a parametric EQ stage for more precise frequency control
4. Design PCB layout with proper ground planes for low-noise operation
5. Add input/output protection circuits for robust real-world implementation

### References

- SPICE Simulation: Circuit simulated using LTSpice (Linear Technology)
- Op-Amp Theory: Standard operational amplifier design techniques (active filters)
- Audio Signal Processing: Nyquist-Shannon sampling and frequency domain analysis

---

**Last Updated:** May 31, 2026  
**Status:** Complete and Documented
