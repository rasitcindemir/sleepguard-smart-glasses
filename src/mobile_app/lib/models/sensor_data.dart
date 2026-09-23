class SensorData {
  final double time;
  final String eyeState;
  final int bpm;
  final String pulseState;
  final DateTime receivedAt;

  const SensorData({
    required this.time,
    required this.eyeState,
    required this.bpm,
    required this.pulseState,
    required this.receivedAt
  });

  bool get isEyeClosed {
    return eyeState.toLowerCase().contains('kapalı') ||
           eyeState.toLowerCase().contains('kapali');
  }

  bool get hasPulse {
    return bpm > 0;
  }

  String get riskStatus {
    if (isEyeClosed && bpm == 0) return 'Yüksek Risk';
    if (isEyeClosed) return 'Uyku Riski';
    if (bpm == 0) return 'Sensör Teması Yok';
    return 'Normal';
  }

  factory SensorData.fromBluetoothLine(String line) {
    final cleanLine = line.trim();
    final parts = cleanLine.split(',');
    
    if (parts.length < 4) {
      throw FormatException('Eksik veri formatı: $line');
    }
    
    final timeText = parts[0]
        .replaceAll('s', '')
        .replaceAll('S', '')
        .replaceAll(' ', '')
        .trim();
        
    final parsedTime = double.tryParse(timeText) ?? 0;
    final eyeState = parts[1].trim();
    final bpm = int.tryParse(parts[2].trim()) ?? 0;
    final pulseState = parts[3].trim();
    
    return SensorData(
      time: parsedTime,
      eyeState: eyeState,
      bpm: bpm,
      pulseState: pulseState,
      receivedAt: DateTime.now()
    );
  }
}
