#include <SoftwareSerial.h>

#define IR_SENSOR A0
#define PULSE_SENSOR A3
#define BUZZER_PIN A2

SoftwareSerial bluetooth(10, 11);

// === SIGNAL ANALYSIS ===
const int SAMPLES = 30;
int buffer[SAMPLES];
int indexPos = 0;
bool bufferFilled = false;

// === CONTACT DETECTION ===
bool contact = false;
unsigned long contactStartTime = 0;
const int DIFF_HIGH = 40;
const int DIFF_LOW = 18;
const unsigned long MIN_CONTACT_TIME = 30000; // 30 seconds
const unsigned long STARTUP_GUARD = 3000;     // 3 seconds startup filter

// === BPM ===
int simulatedBPM = 0;

// === TIME TRACKING ===
unsigned long lastSendTime = 0;
const unsigned long interval = 5000;

// === EYE TRACKING ===
unsigned long eyeClosedStart = 0;
bool alertActive = false;

void setup() {
  pinMode(IR_SENSOR, INPUT);
  pinMode(PULSE_SENSOR, INPUT);
  pinMode(BUZZER_PIN, OUTPUT);
  
  bluetooth.begin(9600);
  Serial.begin(9600);
  
  bluetooth.println("time(s),eye_state,bpm,pulse_state");
  Serial.println("time(s),eye_state,bpm,pulse_state");
}

void loop() {
  unsigned long t = millis();
  int irValue = digitalRead(IR_SENSOR);
  int pulseValue = analogRead(PULSE_SENSOR);

  // -----------------------------------------------
  // 1) EYE TRACKING SYSTEM
  // -----------------------------------------------
  if (irValue == LOW) {
    if (eyeClosedStart == 0) {
      eyeClosedStart = t;
    }
    // Trigger alert if closed for more than 2 seconds
    if (!alertActive && (t - eyeClosedStart > 2000)) {
      digitalWrite(BUZZER_PIN, HIGH);
      alertActive = true;
    }
  } else {
    eyeClosedStart = 0;
    alertActive = false;
    digitalWrite(BUZZER_PIN, LOW);
  }

  // -----------------------------------------------
  // 2) PULSE SENSOR BUFFERING
  // -----------------------------------------------
  buffer[indexPos] = pulseValue;
  indexPos++;
  if (indexPos >= SAMPLES) {
    indexPos = 0;
    bufferFilled = true;
  }

  // -----------------------------------------------
  // 3) CALCULATE SIGNAL DIFFERENTIAL
  // -----------------------------------------------
  if (bufferFilled) {
    int minV = 1023;
    int maxV = 0;
    for (int i = 0; i < SAMPLES; i++) {
      if (buffer[i] < minV) minV = buffer[i];
      if (buffer[i] > maxV) maxV = buffer[i];
    }
    int diff = maxV - minV;

    // ------------------------------------------------------
    // 4) STARTUP FILTER 
    // ------------------------------------------------------
    if (t < STARTUP_GUARD) {
      contact = false;
      simulatedBPM = 0;
      return; // Exit early, bypass contact detection during startup
    }

    // ------------------------------------------------------
    // 5) CONTACT LOGIC
    // ------------------------------------------------------
    if (diff > DIFF_HIGH) {
      contact = true;
      contactStartTime = t;
    }
    
    if (contact && diff < DIFF_LOW && (t - contactStartTime > MIN_CONTACT_TIME)) {
      contact = false;
    }
  }

  // -----------------------------------------------
  // 6) TELEMETRY & BPM GENERATION
  // -----------------------------------------------
  if (millis() - lastSendTime >= interval) {
    lastSendTime = millis();
    
    if (!contact) {
      simulatedBPM = 0;
    } else {
      if (simulatedBPM == 0) {
        simulatedBPM = random(70, 90);
      } else {
        simulatedBPM += random(-3, 4);
      }
      
      if (simulatedBPM < 60) simulatedBPM = 60;
      if (simulatedBPM > 110) simulatedBPM = 110;
    }
    
    String eyeState = (irValue == LOW) ? "göz kapalı" : "göz açık";
    String pulseState = (simulatedBPM == 0) ? "nabiz yok" : "durum normal";
    float sec = millis() / 1000.0;
    
    String out = String(sec, 2) + "s," + eyeState + "," + simulatedBPM + "," + pulseState;
    
    bluetooth.println(out);
    Serial.println(out);
  }
  
  delay(10);
}
