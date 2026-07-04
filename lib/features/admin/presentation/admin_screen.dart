import 'package:flutter/material.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administración'),
      ),
      body: const Center(
        child: Text(
          'Admin (Placeholder)',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
