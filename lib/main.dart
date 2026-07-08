import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/database/database_helper.dart';
import 'features/search/presentation/search_screen.dart';
import 'core/supabase/env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  // PRUEBA TEMPORAL DE CONEXIÓN A SUPABASE (FASE 5)
  try {
    final response = await Supabase.instance.client.from('products').select();
    debugPrint('=== SUPABASE CONNECTION TEST SUCCESS ===');
    debugPrint(response.toString());
    debugPrint('=========================================');
  } catch (e) {
    debugPrint('=== SUPABASE CONNECTION TEST FAILED ===');
    debugPrint(e.toString());
    debugPrint('========================================');
  }

  // Initialize Database
  await DatabaseHelper.instance.database;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catálogo de Precios',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SearchScreen(),
    );
  }
}
