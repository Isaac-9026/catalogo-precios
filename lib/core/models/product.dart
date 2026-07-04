class Product {
  final String id;
  final String name;
  final String? brand;
  final String? category;
  final String? description;
  final double price;
  final String? imageUrl;
  final String? imageUpdatedAt;
  final int isActive;
  final int isDeleted;
  final String updatedAt;
  final String createdAt;

  Product({
    required this.id,
    required this.name,
    this.brand,
    this.category,
    this.description,
    required this.price,
    this.imageUrl,
    this.imageUpdatedAt,
    this.isActive = 1,
    this.isDeleted = 0,
    required this.updatedAt,
    required this.createdAt,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      brand: map['brand'] as String?,
      category: map['category'] as String?,
      description: map['description'] as String?,
      price: (map['price'] as num).toDouble(),
      imageUrl: map['image_url'] as String?,
      imageUpdatedAt: map['image_updated_at'] as String?,
      isActive: map['is_active'] as int? ?? 1,
      isDeleted: map['is_deleted'] as int? ?? 0,
      updatedAt: map['updated_at'] as String,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'category': category,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'image_updated_at': imageUpdatedAt,
      'is_active': isActive,
      'is_deleted': isDeleted,
      'updated_at': updatedAt,
      'created_at': createdAt,
    };
  }
}
