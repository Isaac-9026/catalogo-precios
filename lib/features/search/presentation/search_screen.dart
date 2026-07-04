import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../../product_detail/presentation/product_detail_screen.dart';
import '../../admin/presentation/admin_screen.dart';
import '../../../core/database/database_helper.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int _productCount = 0;

  @override
  void initState() {
    super.initState();
    _checkDb();
  }

  Future<void> _checkDb() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM products');
    if (mounted) {
      setState(() {
        _productCount = Sqflite.firstIntValue(result) ?? 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Precios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminScreen()),
              );
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Búsqueda (Placeholder)',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 16),
            Text('Productos en BD: $_productCount'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProductDetailScreen()),
                );
              },
              child: const Text('Ir a Detalle (Temporal)'),
            )
          ],
        ),
      ),
    );
  }
}
