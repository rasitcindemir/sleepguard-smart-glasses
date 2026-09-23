import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_classic_serial/flutter_bluetooth_classic.dart';

class BluetoothService {
  final FlutterBluetoothClassic _bluetooth = FlutterBluetoothClassic();
  
  StreamSubscription<BluetoothData>? _dataSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  StreamSubscription<BluetoothState>? _stateSubscription;
  StreamSubscription<BluetoothDevice>? _discoverySubscription;
  
  final StreamController<String> _lineController = StreamController<String>.broadcast();
  final StreamController<BluetoothConnectionState> _connectionController = StreamController<BluetoothConnectionState>.broadcast();
  final StreamController<BluetoothDevice> _discoveredDeviceController = StreamController<BluetoothDevice>.broadcast();
  
  final StringBuffer _buffer = StringBuffer();

  Stream<String> get onLineReceived => _lineController.stream;
  Stream<BluetoothConnectionState> get onConnectionChanged => _connectionController.stream;
  Stream<BluetoothDevice> get onDeviceDiscovered => _discoveredDeviceController.stream;

  Future<bool> isBluetoothSupported() async {
    return _bluetooth.isBluetoothSupported();
  }

  Future<bool> isBluetoothEnabled() async {
    return _bluetooth.isBluetoothEnabled();
  }

  Future<bool> enableBluetooth() async {
    return _bluetooth.enableBluetooth();
  }

  Future<List<BluetoothDevice>> getPairedDevices() async {
    return _bluetooth.getPairedDevices();
  }

  Future<bool> connect(String address) async {
    return _bluetooth.connect(address);
  }

  Future<bool> disconnect() async {
    return _bluetooth.disconnect();
  }

  Future<bool> startDiscovery() async {
    return _bluetooth.startDiscovery();
  }

  Future<bool> stopDiscovery() async {
    return _bluetooth.stopDiscovery();
  }

  void startListening() {
    _stateSubscription ??= _bluetooth.onStateChanged.listen(
      (state) {
        debugPrint('Bluetooth state: ${state.status}');
      },
      onError: (error) {
        debugPrint('Bluetooth state error: $error');
      }
    );
    
    _connectionSubscription ??= _bluetooth.onConnectionChanged.listen(
      (state) {
        _connectionController.add(state);
      },
      onError: (error) {
        debugPrint('Bluetooth connection error: $error');
      }
    );
    
    _discoverySubscription ??= _bluetooth.onDeviceDiscovered.listen(
      (device) {
        _discoveredDeviceController.add(device);
      },
      onError: (error) {
        debugPrint('Bluetooth discovery error: $error');
      }
    );
    
    _dataSubscription ??= _bluetooth.onDataReceived.listen(
      _handleIncomingData,
      onError: (error) {
        debugPrint('Bluetooth data error: $error');
      }
    );
  }

  void _handleIncomingData(BluetoothData data) {
    final receivedText = data.asString();
    _buffer.write(receivedText);
    
    final bufferText = _buffer.toString();
    if (!bufferText.contains('\n')) return;
    
    final lines = bufferText.split('\n');
    _buffer.clear();
    
    final lastPart = lines.last.trim();
    if (lastPart.isNotEmpty) {
      _buffer.write(lastPart);
    }
    
    for (int i = 0; i < lines.length - 1; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      _lineController.add(line);
    }
  }

  Future<void> dispose() async {
    await _dataSubscription?.cancel();
    await _connectionSubscription?.cancel();
    await _stateSubscription?.cancel();
    await _discoverySubscription?.cancel();
    await _lineController.close();
    await _connectionController.close();
    await _discoveredDeviceController.close();
  }
}
