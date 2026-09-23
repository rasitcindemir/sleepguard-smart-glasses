# Hardware Specifications

## Bill of Materials (BOM)

| Component | Model / Specs | Quantity | Purpose |
| :--- | :--- | :---: | :--- |
| **Microcontroller** | Arduino Nano (ATmega328P) | 1 | Central processing and logic execution |
| **Eyelid Sensor** | IR Transmitter-Receiver | 1 | Optically detects eyelid closure |
| **Pulse Sensor** | CNL Optical Sensor | 1 | Detects skin contact and pulse differential |
| **Bluetooth Module** | HC-05 | 1 | Serial telemetry transmission to mobile |
| **Audio Alert** | Active Piezoelectric Buzzer | 1 | Emits high-decibel alert (2-4 kHz) |
| **Power Supply** | 9V DC Battery | 1 | Portable system power (regulated to 5V/3.3V) |
| **Chassis** | Yellow-Tinted Glasses | 1 | Wearable mount & visual contrast enhancement |

## Pin Assignments

| Component | Arduino Pin | Connection Type | Function |
| :--- | :--- | :--- | :--- |
| **IR Sensor** | `A0` | Digital/Analog In | Reads eye open (HIGH) / closed (LOW) state |
| **CNL Pulse Sensor** | `A3` | Analog In | Reads photoplethysmography voltage changes |
| **Buzzer** | `A2` | Digital Out | Triggers acoustic alarm |
| **HC-05 TX** | `D10` | SoftwareSerial RX | Receives data from Bluetooth (unused currently) |
| **HC-05 RX** | `D11` | SoftwareSerial TX | Transmits serial data to Bluetooth |
| **Power** | `5V / GND` | Power | Common supply rail |

## Hardware Design Revisions & Limitations

### 1. Environmental Light Interference
IR sensors are highly susceptible to ambient infrared radiation (direct sunlight). During development, physical light barriers were added around the sensor module to narrow its field of view and prevent false "open eye" readings in bright daylight conditions.

### 2. Vibration Artifacts
The initial design included a mechanical vibration motor for tactile feedback alongside the audio buzzer. However, mechanical resonance from the motor severely disrupted the optical readings of the CNL pulse sensor. The vibration motor was consequently removed from the final prototype to prioritize sensor stability, relying entirely on the piezoelectric buzzer for alerts.

### 3. Visual Ergonomics
The choice of yellow-tinted lenses is not purely aesthetic. Yellow spectral filters block short-wavelength light (specifically blue light from oncoming LED headlights), reducing scattering in the intraocular fluid. This passive optical feature improves visual contrast and reduces cumulative eye strain, complementing the active electronic monitoring system.
