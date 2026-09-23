import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_classic_serial/flutter_bluetooth_classic.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/sensor_data.dart';
import '../services/bluetooth_service.dart';

class BluetoothProvider extends ChangeNotifier {
  final BluetoothService _service = BluetoothService();
  
  StreamSubscription<String>? _lineSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  StreamSubscription<BluetoothDevice>? _discoverySubscription;
  
  bool isBluetoothSupported = false;
  bool isBluetoothEnabled = false;
  bool isLoading = false;
  bool isDiscovering = false;
  bool isConnected = false;
  
  String? connectedDeviceName;
  String? connectedDeviceAddress;
  String statusMessage = 'Bluetooth başlatılıyor...';
  
  final List<BluetoothDevice> pairedDevices = [];
  final List<BluetoothDevice> discoveredDevices = [];
  final List<String> terminalLines = [];
  final List<SensorData> sensorHistory = [];
  
  SensorData? latestData;

  Future<void> initialize() async {
    isLoading = true;
    notifyListeners();
    
    await _requestPermissions();
    
    try {
      isBluetoothSupported = await _service.isBluetoothSupported();
      isBluetoothEnabled = await _service.isBluetoothEnabled();
      
      _service.startListening();
      _lineSubscription = _service.onLineReceived.listen(_onLineReceived);
      _connectionSubscription = _service.onConnectionChanged.listen(_onConnectionChanged);
      _discoverySubscription = _service.onDeviceDiscovered.listen(_onDeviceDiscovered);
      
      if (!isBluetoothSupported) {
        statusMessage = 'Bu cihaz Bluetooth Classic desteklemiyor.';
      } else if (!isBluetoothEnabled) {
        statusMessage = 'Bluetooth kapalı. Lütfen Bluetooth’u aç.';
      } else {
        await loadPairedDevices();
        statusMessage = 'Bluetooth hazır. HC-05 cihazını seçebilirsin.';
      }
    } catch (e) {
      statusMessage = 'Bluetooth başlatma hatası: $e';
    }
    
    isLoading = false;
    notifyListeners();
  }

  Future<void> _requestPermissions() async {
    await Permission.bluetooth.request();
    await Permission.bluetoothConnect.request();
    await Permission.bluetoothScan.request();
    await Permission.location.request();
  }

  Future<void> enableBluetooth() async {
    try {
      final result = await _service.enableBluetooth();
      isBluetoothEnabled = await _service.isBluetoothEnabled();
      if (result || isBluetoothEnabled) {
        await loadPairedDevices();
        statusMessage = 'Bluetooth açıldı.';
      } else {
        statusMessage = 'Bluetooth açılamadı. Telefon ayarlarından açmayı dene.';
      }
    } catch (e) {
      statusMessage = 'Bluetooth açılırken hata oluştu: $e';
    }
    notifyListeners();
  }

  Future<void> loadPairedDevices() async {
    isLoading = true;
    notifyListeners();
    try {
      final devices = await _service.getPairedDevices();
      pairedDevices
        ..clear()
        ..addAll(devices);
      if (devices.isEmpty) {
        statusMessage = 'Eşleşmiş cihaz yok. Telefon ayarlarından önce HC-05 ile eşleş.';
      } else {
        statusMessage = 'Eşleşmiş cihazlar yüklendi.';
      }
    } catch (e) {
      statusMessage = 'Eşleşmiş cihazlar alınamadı: $e';
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> startDiscovery() async {
    isDiscovering = true;
    discoveredDevices.clear();
    statusMessage = 'Yakındaki Bluetooth cihazları aranıyor...';
    notifyListeners();
    try {
      final result = await _service.startDiscovery();
      if (!result) {
        statusMessage = 'Cihaz arama başlatılamadı.';
        isDiscovering = false;
      }
    } catch (e) {
      isDiscovering = false;
      statusMessage = 'Cihaz arama başlatılamadı: $e';
    }
    notifyListeners();
  }

  Future<void> stopDiscovery() async {
    try {
      await _service.stopDiscovery();
    } catch (_) {}
    isDiscovering = false;
    statusMessage = 'Cihaz arama durduruldu.';
    notifyListeners();
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    isLoading = true;
    statusMessage = '${device.name} cihazına bağlanılıyor...';
    notifyListeners();
    try {
      final connected = await _service.connect(device.address);
      if (connected) {
        isConnected = true;
        connectedDeviceName = device.name;
        connectedDeviceAddress = device.address;
        statusMessage = '${device.name} cihazına bağlandı.';
      } else {
        statusMessage = '${device.name} cihazına bağlanılamadı.';
      }
    } catch (e) {
      statusMessage = 'Bağlantı hatası: $e';
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> disconnect() async {
    try {
      await _service.disconnect();
    } catch (_) {}
    isConnected = false;
    connectedDeviceName = null;
    connectedDeviceAddress = null;
    statusMessage = 'Bluetooth bağlantısı kesildi.';
    notifyListeners();
  }

  void _onConnectionChanged(BluetoothConnectionState state) {
    isConnected = state.isConnected;
    if (state.isConnected) {
      connectedDeviceAddress = state.deviceAddress;
      final allDevices = [...pairedDevices, ...discoveredDevices];
      for (final device in allDevices) {
        if (device.address == state.deviceAddress) {
          connectedDeviceName = device.name;
          break;
        }
      }
      statusMessage = '${connectedDeviceName ?? 'Cihaz'} bağlı.';
    } else {
      isConnected = false;
      connectedDeviceName = null;
      connectedDeviceAddress = null;
      statusMessage = 'Cihaz bağlantısı kesildi.';
    }
    notifyListeners();
  }

  void _onDeviceDiscovered(BluetoothDevice device) {
    final exists = discoveredDevices.any((item) => item.address == device.address);
    if (!exists) {
      discoveredDevices.add(device);
      notifyListeners();
    }
  }

  void _onLineReceived(String line) {
    if (line.toLowerCase().contains('time')) return;
    
    terminalLines.add(line);
    if (terminalLines.length > 100) { // Max terminal lines
      terminalLines.removeAt(0);
    }
    
    try {
      final data = SensorData.fromBluetoothLine(line);
      latestData = data;
      sensorHistory.add(data);
      if (sensorHistory.length > 50) { // Max chart points
        sensorHistory.removeAt(0);
      }
    } catch (_) {
      // Ignore malformed data
    }
    notifyListeners();
  }

  void clearTerminal() {
    terminalLines.clear();
    notifyListeners();
  }

  void clearChart() {
    sensorHistory.clear();
    latestData = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _lineSubscription?.cancel();
    _connectionSubscription?.cancel();
    _discoverySubscription?.cancel();
    _service.dispose();
    super.dispose();
  }
}
