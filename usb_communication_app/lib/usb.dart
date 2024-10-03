import 'dart:isolate';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:usb_serial/usb_serial.dart';

class Usb {
  UsbPort? _port;
  SendPort sendPort;
  bool messageSubscriptionInit = false;
  late SendPort messageSendPort;
  late StreamSubscription messageSubscription;

  Usb(this.sendPort) {
    _usbStatusInit();
    const EventChannel('usb_events')
        .receiveBroadcastStream()
        .map((event) => event as String)
        .listen((event) {
      if (event == 'connect') {
        _usbStatusInit();
      } else if (event == 'disconnect') {
        _port?.close();
        if (messageSubscriptionInit) {
          messageSubscription.cancel();
        }
        messageSubscriptionInit = false;
        sendPort.send(0);
      }
    });
  }

  addMessageSendPort(SendPort sendPort) async {
    if (messageSubscriptionInit) {
      messageSubscription.cancel();
    }
    messageSubscriptionInit = true;
    messageSendPort = sendPort;
    messageSubscription = _port!.inputStream!.listen((Uint8List data) {
      String message = String.fromCharCodes(data);
      messageSendPort.send(message);
    });
  }

  _usbStatusInit() async {
    List<UsbDevice> devices = await UsbSerial.listDevices();
    if (devices.isEmpty) {
      sendPort.send(0);
      return;
    } else {
      sendPort.send(1);
      await _createPort(devices[0]);
    }
  }

  _createPort(UsbDevice device) async {
    try {
      _port = await device.create();
      await _port!.open();
      await _port!.setDTR(true);
      await _port!.setRTS(true);
      await _port!.setPortParameters(
          9600, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);
      sendPort.send(3);
    } catch (e) {
      sendPort.send(2);
    }
  }

  void sendMessage(String string) {
    if (_port != null && string.isNotEmpty) {
      _port!.write(Uint8List.fromList(string.codeUnits));
    }
  }

  void dispose() {
    _port?.close();
    if (messageSubscriptionInit) {
      messageSubscription.cancel();
    }
    messageSubscriptionInit = false;
    
  }
}
