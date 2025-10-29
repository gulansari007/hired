import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hired/controllers/networkController.dart';

class NetworkScreen extends StatefulWidget {
  const NetworkScreen({super.key});

  @override
  State<NetworkScreen> createState() => _NetworkScreenState();
}

class _NetworkScreenState extends State<NetworkScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add to Your Network'),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
