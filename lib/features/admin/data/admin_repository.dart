import 'package:uuid/uuid.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/product.dart';

class AdminRepository {
  final _uuid = const Uuid();

  Future<List<Product>> getAllProducts() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'products',
      where: 'is_deleted = 0',
      orderBy: 'name ASC',
    );
    return maps.map((e) => Product.fromMap(e)).toList();
  }

  Future<void> createProduct(Product product) async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now().toIso8601String();
    
    await db.transaction((txn) async {
      await txn.insert('products', product.toMap());
      
      await txn.insert('price_history', {
        'id': _uuid.v4(),
        'product_id': product.id,
        'price': product.price,
        'changed_at': now,
      });
    });
  }

  Future<void> updateProduct(Product product, bool priceChanged) async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now().toIso8601String();
    
    await db.transaction((txn) async {
      final map = product.toMap();
      map['updated_at'] = now;
      
      await txn.update(
        'products',
        map,
        where: 'id = ?',
        whereArgs: [product.id],
      );
      
      if (priceChanged) {
        await txn.insert('price_history', {
          'id': _uuid.v4(),
          'product_id': product.id,
          'price': product.price,
          'changed_at': now,
        });
      }
    });
  }

  Future<void> deleteProduct(String id) async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now().toIso8601String();
    // REGLA: Nunca hacer DELETE físico. Solo soft-delete.
    await db.update(
      'products',
      {
        'is_deleted': 1,
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> toggleActiveStatus(String id, int isActive) async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now().toIso8601String();
    await db.update(
      'products',
      {
        'is_active': isActive,
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
