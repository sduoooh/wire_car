import 'package:flutter/material.dart';
import 'usb.dart';
import 'dart:isolate';

class DebugPage extends StatefulWidget {
  final Usb usb;

  const DebugPage({Key? key, required this.usb}) : super(key: key);

  @override
  DebugPageState createState() => DebugPageState();
}

class DebugPageState extends State<DebugPage> {
  List<String> messages = [];
  final TextEditingController _controller = TextEditingController();
  late final Usb usb;
  late final ReceivePort receivePort;

  @override
  void initState() {
    super.initState();
    usb = widget.usb;
    receivePort = ReceivePort();
    usb.addMessageSendPort(receivePort.sendPort);
    receivePort.listen((message) {
      setState(() {
        messages.add('收到： $message');
      });
    });
  }

  void _sendMessage() {
    if ( _controller.text.isNotEmpty) {
      String message = _controller.text;
      setState(() {
        _controller.clear();
      });
      usb.sendMessage(message);
      setState(() {
        if (messages.length > 4) {
          messages.removeAt(0);
          messages.removeAt(0);
        }
        messages.add('发送： $message');
      });
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

  @override
  void dispose() {
    super.dispose();
  }
}