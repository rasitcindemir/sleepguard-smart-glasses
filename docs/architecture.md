# System Architecture

The SleepGuard system is designed as a hybrid embedded and IoT architecture. The core principle is that the embedded hardware handles the critical safety loop (sensing and alerting), while the mobile software handles telemetry, data visualization, and secondary analysis.

## Logical Flow

```mermaid
flowchart TD
    subgraph Sensors
        IR[IR Eyelid Sensor]
        CNL[CNL Pulse Sensor]
    end

    subgraph Processing Unit [Arduino Nano]
        ADC[ADC Conversion]
        Filter[Noise Filter & Moving Average]
        Logic{Closure > 2s?}
        BPM[Pulse Contact & BPM Logic]
    end

    subgraph Output & Communication
        Buzz[Piezoelectric Buzzer]
        BT[HC-05 Bluetooth]
    end

    subgraph Mobile Application [Flutter]
        UI_Dash[Dashboard UI]
        UI_Chart[Live BPM Chart]
        UI_Term[Raw Terminal]
    end

    IR -->|Digital| Logic
    CNL -->|Analog| ADC
    ADC --> Filter
    Filter --> BPM
    
    Logic -->|Yes| Buzz
    Logic -->|Eye State| BT
    BPM -->|BPM Value| BT
    
    BT -->|Serial Data| UI_Dash
    BT -->|Serial Data| UI_Chart
    BT -->|Serial Data| UI_Term
