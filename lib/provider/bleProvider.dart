import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleProvider with ChangeNotifier {
  final _ble = FlutterReactiveBle();
  int counter = 0;
  String deviceId = "";
  // ignore: close_sinks
  StreamController<int> bleController = StreamController.broadcast();
  Stream<int>? bleStream;
  BleProvider() {
    bleStream = bleController.stream;
  }
  getDevices() {
    print("GET DEVICES");
    Uuid serv = Uuid.parse("042bd80f-14f6-42be-a45c-a62836a4fa3f");
    _ble.scanForDevices(
        withServices: [],
        requireLocationServicesEnabled: false,
        scanMode: ScanMode.lowLatency).listen((device) {
      if (device.name == "MonESP32") {
        print(device);
        print(device.name);
        print(device.id);
        print(device.serviceData);
        print(device.manufacturerData);
        this.deviceId = device.id;
        connect();
      }
    }, onError: (err) {
      //code for handling error
      print("ERREUR : $err");
    });
  }

  connect() {
    print("device id : ${this.deviceId}");
    _ble
        .connectToDevice(
      id: deviceId,
      /*
    servicesWithCharacteristicsToDiscover: {
      serviceId: []
    },
    */
      connectionTimeout: const Duration(seconds: 2),
    )
        .listen((connectionState) {
      // Handle connection state updates
      print("status: $connectionState");
      if (connectionState.connectionState == DeviceConnectionState.connected) {
        print(" CONNECTED ");
        final characteristic = QualifiedCharacteristic(
            serviceId: Uuid.parse("042bd80f-14f6-42be-a45c-a62836a4fa3f"),
            characteristicId:
                Uuid.parse("065de41b-79fb-479d-b592-47caf39bfccb"),
            deviceId: deviceId);
        _ble.subscribeToCharacteristic(characteristic).listen((data) {
          // code to handle incoming data
          print(data);

          counter = data[0] + data[1] * 256;
          //notifyListeners();
          bleController.add(counter);
        }, onError: (dynamic error) {
          print(error); // code to handle errors
        });
      }
    }, onError: (Object error) {
      // Handle a possible error
      print(error);
    });
  }
}
