import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

class DatabaseHelper {
  static const _databaseName = "catalogo_precios.db";
  static const _databaseVersion = 1;

  // Singleton
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    // 1. Create tables according to AGENTS.md
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        brand TEXT,
        category TEXT,
        description TEXT,
        price REAL NOT NULL,
        image_url TEXT,
        image_updated_at TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        updated_at TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE price_history (
        id TEXT PRIMARY KEY,
        product_id TEXT NOT NULL REFERENCES products(id),
        price REAL NOT NULL,
        changed_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE app_config (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        store_name TEXT,
        currency TEXT DEFAULT 'PEN',
        admin_pin_hash TEXT,
        last_synced_at TEXT,
        app_version TEXT
      )
    ''');

    // 2. Insert test data
    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    // Initialize config
    await db.insert('app_config', {
      'id': 1,
      'store_name': 'Mi Tienda',
      'currency': 'PEN',
      'app_version': '1.0.0'
    });

    // Dummy products
    final now = DateTime.now().toUtc().toIso8601String();
    final uuid = const Uuid();

    final testProducts = [
      {'name': 'Arroz Costeño 1kg', 'brand': 'Costeño', 'category': 'Abarrotes', 'price': 4.50},
      {'name': 'Azúcar Rubia Cartavio 1kg', 'brand': 'Cartavio', 'category': 'Abarrotes', 'price': 3.80},
      {'name': 'Aceite Primor Premium 1L', 'brand': 'Primor', 'category': 'Abarrotes', 'price': 12.50},
      {'name': 'Leche Evaporada Gloria 400g', 'brand': 'Gloria', 'category': 'Lácteos', 'price': 3.90},
      {'name': 'Fideos Don Vittorio Spaghetti 500g', 'brand': 'Don Vittorio', 'category': 'Abarrotes', 'price': 2.80},
      {'name': 'Atún Florida en Aceite 170g', 'brand': 'Florida', 'category': 'Conservas', 'price': 5.50},
      {'name': 'Avena Quaker 900g', 'brand': 'Quaker', 'category': 'Desayuno', 'price': 7.20},
      {'name': 'Café Altomayo Clásico 200g', 'brand': 'Altomayo', 'category': 'Desayuno', 'price': 15.00},
      {'name': 'Galletas Soda Field 6x34g', 'brand': 'Field', 'category': 'Snacks', 'price': 2.50},
      {'name': 'Detergente Ariel 1kg', 'brand': 'Ariel', 'category': 'Limpieza', 'price': 14.90},
      {'name': 'Jabón Bolívar 3x130g', 'brand': 'Bolívar', 'category': 'Limpieza', 'price': 4.20},
      {'name': 'Papel Higiénico Suave 12 rollos', 'brand': 'Suave', 'category': 'Limpieza', 'price': 11.50},
      {'name': 'Margarina Manty 250g', 'brand': 'Manty', 'category': 'Lácteos', 'price': 3.50},
      {'name': 'Yogurt Gloria Fresa 1kg', 'brand': 'Gloria', 'category': 'Lácteos', 'price': 6.90},
      {'name': 'Gaseosa Inca Kola 3L', 'brand': 'Inca Kola', 'category': 'Bebidas', 'price': 9.50},
    ];

    for (var p in testProducts) {
      final id = uuid.v4();
      await db.insert('products', {
        'id': id,
        'name': p['name'],
        'brand': p['brand'],
        'category': p['category'],
        'price': p['price'],
        'updated_at': now,
        'created_at': now,
      });
      // Add initial price history
      await db.insert('price_history', {
        'id': uuid.v4(),
        'product_id': id,
        'price': p['price'],
        'changed_at': now,
      });
    }
  }
}
