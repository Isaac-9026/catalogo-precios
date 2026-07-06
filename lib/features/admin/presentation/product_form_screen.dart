import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/product.dart';
import '../data/admin_repository.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repo = AdminRepository();

  late TextEditingController _nameCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _brandCtrl;
  late TextEditingController _categoryCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _imageCtrl;

  bool _isActive = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _priceCtrl = TextEditingController(text: p?.price.toString() ?? '');
    _brandCtrl = TextEditingController(text: p?.brand ?? '');
    _categoryCtrl = TextEditingController(text: p?.category ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _imageCtrl = TextEditingController(text: p?.imageUrl ?? '');
    _isActive = p?.isActive == 1;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _brandCtrl.dispose();
    _categoryCtrl.dispose();
    _descCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final now = DateTime.now().toIso8601String();
    final price = double.parse(_priceCtrl.text);

    if (widget.product == null) {
      // Create
      final newProduct = Product(
        id: const Uuid().v4(),
        name: _nameCtrl.text,
        price: price,
        brand: _brandCtrl.text.isEmpty ? null : _brandCtrl.text,
        category: _categoryCtrl.text.isEmpty ? null : _categoryCtrl.text,
        description: _descCtrl.text.isEmpty ? null : _descCtrl.text,
        imageUrl: _imageCtrl.text.isEmpty ? null : _imageCtrl.text,
        isActive: _isActive ? 1 : 0,
        createdAt: now,
        updatedAt: now,
      );
      await _repo.createProduct(newProduct);
    } else {
      // Update
      final p = widget.product!;
      final bool priceChanged = p.price != price;

      final updatedProduct = Product(
        id: p.id,
        name: _nameCtrl.text,
        price: price,
        brand: _brandCtrl.text.isEmpty ? null : _brandCtrl.text,
        category: _categoryCtrl.text.isEmpty ? null : _categoryCtrl.text,
        description: _descCtrl.text.isEmpty ? null : _descCtrl.text,
        imageUrl: _imageCtrl.text.isEmpty ? null : _imageCtrl.text,
        isActive: _isActive ? 1 : 0,
        isDeleted: p.isDeleted,
        createdAt: p.createdAt,
        updatedAt: now,
      );
      await _repo.updateProduct(updatedProduct, priceChanged);
    }

    if (mounted) {
      Navigator.pop(context, true); // Retorna true para refrescar la lista
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Producto' : 'Nuevo Producto'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            if (isEditing)
              SwitchListTile(
                title: const Text('Producto Activo'),
                subtitle: const Text('Mostrar en resultados de búsqueda'),
                value: _isActive,
                onChanged: (val) => setState(() => _isActive = val),
              ),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nombre *'),
              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceCtrl,
              decoration: const InputDecoration(labelText: 'Precio *', prefixText: 'S/ '),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Requerido';
                if (double.tryParse(v) == null) return 'Número inválido';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _brandCtrl,
              decoration: const InputDecoration(labelText: 'Marca'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _categoryCtrl,
              decoration: const InputDecoration(labelText: 'Categoría'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Descripción'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _imageCtrl,
              decoration: const InputDecoration(labelText: 'URL de Imagen'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving 
                  ? const CircularProgressIndicator() 
                  : const Text('Guardar Producto'),
            ),
          ],
        ),
      ),
    );
  }
}
