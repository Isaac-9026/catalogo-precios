import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Producto'),
      ),
      body: const Center(
        child: Text(
          'Detalle (Placeholder)',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
