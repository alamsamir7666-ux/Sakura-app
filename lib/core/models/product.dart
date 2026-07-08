import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final int id;
  final String name;
  final String slug;
  final double price;
  final double? discountPrice;
  final String category;
  final int stock;
  final String description;
  final String? ingredients;
  final List<String> keyBenefits;
  final List<MainIngredient> mainIngredients;
  final List<String> bestFor;
  final String? texture;
  final List<String> images;
  final double averageRating;
  final int reviewCount;
  final bool isFeatured;
  final String? homepageSection;
  final String createdAt;

  const Product({
    required this.id,
    required this.name,
    required this.slug,
    required this.price,
    this.discountPrice,
    required this.category,
    required this.stock,
    required this.description,
    this.ingredients,
    required this.keyBenefits,
    required this.mainIngredients,
    required this.bestFor,
    this.texture,
    required this.images,
    required this.averageRating,
    required this.reviewCount,
    required this.isFeatured,
    this.homepageSection,
    required this.createdAt,
  });

  double get effectivePrice => discountPrice ?? price;
  bool get hasDiscount => discountPrice != null && discountPrice! < price;
  int get discountPercent =>
      hasDiscount ? ((price - discountPrice!) / price * 100).round() : 0;
  bool get inStock => stock > 0;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      price: (json['price'] as num).toDouble(),
      discountPrice: json['discountPrice'] != null
          ? (json['discountPrice'] as num).toDouble()
          : null,
      category: json['category'] as String,
      stock: json['stock'] as int,
      description: json['description'] as String,
      ingredients: json['ingredients'] as String?,
      keyBenefits: List<String>.from(json['keyBenefits'] ?? []),
      mainIngredients: (json['mainIngredients'] as List<dynamic>?)
              ?.map((e) => MainIngredient.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      bestFor: List<String>.from(json['bestFor'] ?? []),
      texture: json['texture'] as String?,
      images: List<String>.from(json['images'] ?? []),
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      isFeatured: json['isFeatured'] as bool? ?? false,
      homepageSection: json['homepageSection'] as String?,
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'price': price,
        'discountPrice': discountPrice,
        'category': category,
        'stock': stock,
        'description': description,
        'ingredients': ingredients,
        'keyBenefits': keyBenefits,
        'mainIngredients': mainIngredients.map((e) => e.toJson()).toList(),
        'bestFor': bestFor,
        'texture': texture,
        'images': images,
        'averageRating': averageRating,
        'reviewCount': reviewCount,
        'isFeatured': isFeatured,
        'homepageSection': homepageSection,
        'createdAt': createdAt,
      };

  @override
  List<Object?> get props => [id];
}

class MainIngredient extends Equatable {
  final String name;
  final String icon;

  const MainIngredient({required this.name, required this.icon});

  factory MainIngredient.fromJson(Map<String, dynamic> json) {
    return MainIngredient(
      name: json['name'] as String,
      icon: json['icon'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'icon': icon};

  @override
  List<Object?> get props => [name, icon];
}

class ProductListResponse extends Equatable {
  final List<Product> products;
  final int total;
  final int page;
  final int totalPages;

  const ProductListResponse({
    required this.products,
    required this.total,
    required this.page,
    required this.totalPages,
  });

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    return ProductListResponse(
      products: (json['products'] as List<dynamic>)
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      totalPages: json['totalPages'] as int,
    );
  }

  @override
  List<Object?> get props => [total, page, totalPages];
}

class HomepageProducts extends Equatable {
  final List<Product> top;
  final List<Product> bottom;

  const HomepageProducts({required this.top, required this.bottom});

  factory HomepageProducts.fromJson(Map<String, dynamic> json) {
    return HomepageProducts(
      top: (json['top'] as List<dynamic>)
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList(),
      bottom: (json['bottom'] as List<dynamic>)
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [top, bottom];
}
