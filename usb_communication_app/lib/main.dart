import 'package:flutter/material.dart';
import 'package:usb_serial/usb_serial.dart';
import 'dart:typed_data';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'USB通信应用',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const UsbCommunicationPage(),
    );
  }
}

class UsbCommunicationPage extends StatefulWidget {
  const UsbCommunicationPage({Key? key}) : super(key: key);

  @override
  UsbCommunicationPageState createState() => UsbCommunicationPageState();
}

class UsbCommunicationPageState extends State<UsbCommunicationPage> {
  List<String> messages = [];
  final TextEditingController _controller = TextEditingController();
  UsbPort? _port;
  UsbDeviceStatus _usbStatus = UsbDeviceStatus.noDevice;

  @override
  void initState() {
    super.initState();
    _connectToUsbDevice();
  }

  Future<void> _connectToUsbDevice() async {
    List<UsbDevice> devices = await UsbSerial.listDevices();
    if (devices.isEmpty) {
      setState(() {
        _usbStatus = UsbDeviceStatus.noDevice;
      });
      return;
    }

    setState(() {
      _usbStatus = UsbDeviceStatus.unauthorized;
    });

    try {
      _port = await devices[0].create();
      await _port!.open();
      await _port!.setDTR(true);
      await _port!.setRTS(true);
      _port!.setPortParameters(9600, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

      setState(() {
        _usbStatus = UsbDeviceStatus.connected;
      });

      _port!.inputStream!.listen((Uint8List data) {
        String message = String.fromCharCodes(data);
        setState(() {
          messages.add(message);
          if (messages.length > 5) {
            messages.removeAt(0);
          }
        });
      });
    } catch (e) {
      setState(() {
        _usbStatus = UsbDeviceStatus.unauthorized;
      });
    }
  }

  void _sendMessage() {
    if (_port != null && _controller.text.isNotEmpty) {
      _port!.write(Uint8List.fromList(_controller.text.codeUnits));
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('USB通信应用'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: _buildUsbStatusIcon(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(messages[messages.length - 1 - index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: '输入消息...',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _sendMessage,
                  child: const Text('发送'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsbStatusIcon() {
    switch (_usbStatus) {
      case UsbDeviceStatus.noDevice:
        return const Icon(Icons.close, color: Colors.red);
      case UsbDeviceStatus.unauthorized:
        return const Icon(Icons.help_outline, color: Colors.orange);
      case UsbDeviceStatus.connected:
        return const Icon(Icons.check, color: Colors.green);
    }
  }

  @override
  void dispose() {
    _port?.close();
    super.dispose();
  }
}

enum UsbDeviceStatus {
  noDevice,
  unauthorized,
  connected,
}