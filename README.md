# SleepGuard Smart Glasses

A wearable, IoT-integrated driver fatigue monitoring system built with Arduino and Flutter. This project aims to detect early signs of driver drowsiness (microsleep) using a combination of behavioral and physiological sensors, alerting the driver in real-time to prevent potential traffic accidents.

## Overview

Driver fatigue is a leading cause of traffic accidents. Long journeys, monotonous road conditions, and night driving can severely reduce a driver's cognitive awareness and reaction time. SleepGuard addresses this by constantly monitoring the driver's eyelid closure duration and pulse rate using a lightweight, non-invasive smart glasses prototype.

## System Architecture

The system operates via an edge-computing approach where the primary safety algorithm runs entirely on an embedded microcontroller, ensuring no latency and complete independence from mobile connectivity.

1. **Input**: An Infrared (IR) sensor detects eye state (open/closed), and a CNL optical sensor measures heart rate.
2. **Processing**: An Arduino Nano processes the analog and digital inputs, applying moving-average filtering and threshold logic.
3. **Control/Output**: If the eyelid remains closed for more than 2 seconds, the Arduino triggers a local piezoelectric buzzer. 
4. **Communication**: An HC-05 Bluetooth module transmits serial telemetry (Time, Eye State, BPM, Risk Status) at a 1Hz frequency.
5. **Monitoring**: A Flutter mobile application receives the Bluetooth data, visualizing the BPM on a live chart and displaying current risk metrics.

## Key Features

* **Real-Time Eyelid Tracking**: Detects microsleep events utilizing a precise 2-second closure threshold.
* **Multimodal Sensor Fusion**: Combines ocular tracking with pulse (BPM) validation to reduce false positives.
* **Failsafe Audio Alerts**: Active piezoelectric buzzer operates directly from the Arduino, ensuring alerts fire even if the Bluetooth connection fails.
* **Ergonomic Visual Filtering**: Built on a frame with yellow-tinted lenses to block short-wavelength blue light, physically reducing driver eye strain and glare from oncoming headlights.
* **Mobile Companion App**: A cross-platform Flutter app displaying real-time telemetry, historical BPM charts, and raw Bluetooth terminal data.

## Technologies Used

* **Hardware**: Arduino Nano (ATmega328P), HC-05 Bluetooth Classic
* **Sensors**: Generic IR Transmitter-Receiver, CNL Pulse Sensor
* **Software**: C/C++ (Arduino IDE), Dart (Flutter Framework)

## Installation & Setup

### Arduino Hardware
1. Flash `src/arduino/main/main.ino` to your Arduino Nano using the Arduino IDE.
2. Ensure you have the `SoftwareSerial` library installed (built-in).
3. Connect the components according to the wiring diagram in `docs/hardware.md`.

### Flutter Mobile App
1. Navigate to `src/mobile_app/`.
2. Run `flutter pub get` to install dependencies (requires `fl_chart`, `provider`, `permission_handler`, and `flutter_bluetooth_classic_serial`).
3. Compile and install on an Android device: `flutter run --release`.
4. Pair the HC-05 module in your Android Bluetooth settings before launching the app.

## Academic Context

This repository represents the practical engineering implementation of a Mechatronics Engineering graduation thesis (2026) at Isparta University of Applied Sciences, Faculty of Technology. 

* **Author**: Raşit ÇİNDEMİR
* **Advisor**: Assoc. Prof. Dr. Melik Ziya YAKUT
