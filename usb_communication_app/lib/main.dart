import 'package:flutter/material.dart';
import 'usb.dart';
import 'dart:isolate';

import 'debug_page.dart';
import 'server_page.dart';

void main() {
  runApp(const UsbApp());
}

class UsbApp extends StatelessWidget {
  const UsbApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'USB通信应用',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ModeChoosePage(),
    );
  }
}

class ModeChoosePage extends StatefulWidget {
  const ModeChoosePage({Key? key}) : super(key: key);

  @override
  ModeChoosePageState createState() => ModeChoosePageState();
}

class ModeChoosePageState extends State<ModeChoosePage> {
  bool _isTopPressed = false;
  bool _isBottomPressed = false;
  UsbDeviceStatus _usbStatus = UsbDeviceStatus.noDevice;
  Mode _mode = Mode.choose;

  late Usb usb;
  late ReceivePort receivePort;

  @override
  void initState() {
    super.initState();
    receivePort = ReceivePort();
    usb = Usb(receivePort.sendPort);

    receivePort.listen((message) {
      switch (message) {
        case 0:
          setState(() {
            _usbStatus = UsbDeviceStatus.noDevice;
          });
          break;
        case 1:
          setState(() {
            _usbStatus = UsbDeviceStatus.unauthorized;
          });
          break;
        case 2:
          setState(() {
            _usbStatus = UsbDeviceStatus.connected;
          });
          break;
        default:
          setState(() {
            _usbStatus = UsbDeviceStatus.noDevice;
          });
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_usbStatus) {
      case UsbDeviceStatus.connected:
        switch (_mode) {
          case Mode.choose:
            return Scaffold(
              body: Column(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTapDown: (_) => setState(() => _isTopPressed = true),
                      onTapUp: (_) => setState(() {
                        _isTopPressed = false;
                        _mode = Mode.debug;
                      }),
                      onTapCancel: () => setState(() => _isTopPressed = false),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        color: _isTopPressed ? Colors.green : Colors.white,
                        child: const Center(
                          child: Text('调试模式'),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 2,
                    color: Colors.black,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTapDown: (_) => setState(() => _isBottomPressed = true),
                      onTapUp: (_) => setState(() {
                        _isBottomPressed = false;
                        _mode = Mode.server;
                      }),
                      onTapCancel: () =>
                          setState(() => _isBottomPressed = false),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        color: _isBottomPressed ? Colors.green : Colors.white,
                        child: const Center(
                          child: Text('遥控模式'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          default:
            return Scaffold(
              appBar: AppBar(
                title: _getTitle(),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: _buildUsbStatusIcon(),
                  ),
                ],
              ),
              body: _getPage(),
            );
        }
      default:
        return Scaffold(
            body: Center(
          child: _getText(),
        ));
    }
  }

  Widget _buildUsbStatusIcon() {
    switch (_usbStatus) {
      case UsbDeviceStatus.noDevice:
        return const Icon(Icons.close, color: Colors.red);
      case UsbDeviceStatus.unauthorized:
        return const Icon(Icons.help_outline, color: Colors.orange);
      case UsbDeviceStatus.connected:
        switch (_mode) {
          case Mode.choose:
            return const Icon(Icons.check, color: Colors.green);
          case Mode.debug:
            return IconButton(
              icon: const Icon(Icons.bug_report, color: Colors.black),
              onPressed: () {
                _changePage(Mode.server);
              },
            );
          case Mode.server:
            return IconButton(
              icon: const Icon(Icons.wifi, color: Colors.green),
              onPressed: () {
                _changePage(Mode.debug);
              },
            );
        }
    }
  }

  Widget _getPage() {
    switch (_mode) {
      case Mode.debug:
        return DebugPage(usb: usb);
      case Mode.server:
        return const ServerPage();
      case Mode.choose:
        return const ServerPage();
    }
  }

  Widget _getText() {
    switch (_usbStatus) {
      case UsbDeviceStatus.noDevice:
        return const Text('正在等待设备连接...');
      case UsbDeviceStatus.unauthorized:
        return const Text('正在获取设备授权...');
      default:
        return const Text('');
    }
  }

  Widget _getTitle() {
    switch (_mode) {
      case Mode.debug:
        return const Text('调试模式');
      case Mode.server:
        return const Text('遥控模式');
      case Mode.choose:
        return const Text('选择模式');
    }
  }

  void _changePage(Mode mode) {
    setState(() {
      _mode = mode;
    });
  }

  @override
  void dispose() {
    receivePort.close();
    usb.dispose();
    super.dispose();
  }
}

enum UsbDeviceStatus {
  noDevice,
  unauthorized,
  connected,
}

enum Mode {
  choose,
  debug,
  server,
}
