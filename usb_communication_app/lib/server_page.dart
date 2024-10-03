import 'package:flutter/material.dart';

class ServerPage extends StatefulWidget {
  const ServerPage({Key? key}) : super(key: key);

  @override
  ServerPageState createState() => ServerPageState();
}

class ServerPageState extends State<ServerPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('施工中......')),
    );
  }
}
