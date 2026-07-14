import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/product.dart';
import '../../../core/supabase/supabase_config.dart';

class SupabaseRepository {
  SupabaseClient get _client {
    if (!SupabaseConfig.isConfigured) {
      throw Exception('Modo local: Supabase no está configurado.');
    }
    return Supabase.instance.client;
  }

  // Fase 5: Solo creamos la infraestructura bAsica. 
  // No hay lógica de push/pull compleja aún.
  
  Future<List<Product>> fetchRemoteProducts() async {
    final response = await _client.from('products').select();
    
    return response.map<Product>((map) => Product.fromMap(map)).toList();
  }

  // Ejemplo de escritura básica para probar permisos (se usará luego en sync)
  Future<void> upsertProduct(Product product) async {
    await _client.from('products').upsert(product.toMap());
  }
}
