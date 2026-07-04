import '../../../core/database/database_helper.dart';
import '../../../core/models/product.dart';

class SearchRepository {
  String normalizeText(String text) {
    String normalized = text.toLowerCase();
    normalized = normalized.replaceAll(RegExp(r'[áäâà]'), 'a');
    normalized = normalized.replaceAll(RegExp(r'[éëêè]'), 'e');
    normalized = normalized.replaceAll(RegExp(r'[íïîì]'), 'i');
    normalized = normalized.replaceAll(RegExp(r'[óöôò]'), 'o');
    normalized = normalized.replaceAll(RegExp(r'[úüûù]'), 'u');
    return normalized;
  }

  Future<List<Product>> searchProducts(String query) async {
    final db = await DatabaseHelper.instance.database;
    final normalizedQuery = normalizeText(query);
    
    final List<Map<String, dynamic>> maps;
    if (normalizedQuery.isEmpty) {
        // If empty, show some initial products or all active ones
        maps = await db.rawQuery('''
          SELECT * FROM products 
          WHERE is_active = 1 AND is_deleted = 0 
          ORDER BY name ASC
        ''');
    } else {
        maps = await db.rawQuery('''
          SELECT * FROM products 
          WHERE is_active = 1 
          AND is_deleted = 0 
          AND LOWER(name) LIKE ?
          ORDER BY name ASC
        ''', ['%$normalizedQuery%']);
    }

    return maps.map((e) => Product.fromMap(e)).toList();
  }
}
