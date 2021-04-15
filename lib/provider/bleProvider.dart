import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleProvider with ChangeNotifier {
  final _ble = FlutterReactiveBle();
  int counter = 0;
  String deviceId = "";

  getDevices() {
    print("GET DEVICES");
    _ble.scanForDevices(withServices: [], scanMode: ScanMode.lowLatency).listen(
        (device) {
      deviceId = device.id;
      print(device);
      print(device.name);
      deviceId = device.id;
      print(device.id);
      print(device.serviceData);
      print(device.manufacturerData);
    }, onError: (err) {
      //code for handling error
      print("ERREUR : $err");
    });
  }

  connect() {
    _ble
        .connectToDevice(
      id: "AC:67:B2:39:6E:36",
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
            deviceId: "AC:67:B2:39:6E:36");
        _ble.subscribeToCharacteristic(characteristic).listen((data) {
          // code to handle incoming data
          print(data.first);
          counter = data.first;
          notifyListeners();
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
