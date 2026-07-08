import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../lib/core/models/product.dart';
import '../../lib/core/models/category.dart';
import '../../lib/core/models/address.dart';

void main() {
  group('Product Model', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 1,
        'name': 'Sakura Cream',
        'slug': 'sakura-cream',
        'price': 29.99,
        'discountPrice': 24.99,
        'category': 'Moisturizer',
        'stock': 50,
        'description': 'A luxurious cream',
        'ingredients': 'Water, Sakura extract',
        'keyBenefits': ['Hydrating', 'Brightening'],
        'mainIngredients': [
          {'name': 'Sakura Extract', 'icon': '🌸'}
        ],
        'bestFor': ['Dry Skin', 'Sensitive Skin'],
        'texture': 'Cream',
        'images': ['/images/sakura.jpg'],
        'averageRating': 4.5,
        'reviewCount': 120,
        'isFeatured': true,
        'homepageSection': 'top',
        'createdAt': '2026-01-01T00:00:00Z',
      };

      final product = Product.fromJson(json);

      expect(product.id, 1);
      expect(product.name, 'Sakura Cream');
      expect(product.price, 29.99);
      expect(product.effectivePrice, 24.99);
      expect(product.hasDiscount, true);
      expect(product.discountPercent, 16);
      expect(product.inStock, true);
      expect(product.mainIngredients.length, 1);
      expect(product.mainIngredients.first.name, 'Sakura Extract');
    });

    test('hasDiscount returns false when no discount', () {
      final product = Product(
        id: 1,
        name: 'Test',
        slug: 'test',
        price: 10.0,
        category: 'Test',
        stock: 10,
        description: 'Test',
        keyBenefits: [],
        mainIngredients: [],
        bestFor: [],
        images: [],
        averageRating: 0,
        reviewCount: 0,
        isFeatured: false,
        createdAt: '',
      );
      expect(product.hasDiscount, false);
      expect(product.discountPercent, 0);
    });

    test('inStock returns false when stock is 0', () {
      final product = Product(
        id: 1,
        name: 'Test',
        slug: 'test',
        price: 10.0,
        category: 'Test',
        stock: 0,
        description: 'Test',
        keyBenefits: [],
        mainIngredients: [],
        bestFor: [],
        images: [],
        averageRating: 0,
        reviewCount: 0,
        isFeatured: false,
        createdAt: '',
      );
      expect(product.inStock, false);
    });
  });

  group('Category Model', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 1,
        'name': 'Moisturizers',
        'slug': 'moisturizers',
        'icon': '💧',
        'displayOrder': 1,
        'createdAt': '2026-01-01T00:00:00Z',
        'updatedAt': '2026-01-01T00:00:00Z',
      };

      final category = Category.fromJson(json);

      expect(category.id, 1);
      expect(category.name, 'Moisturizers');
      expect(category.slug, 'moisturizers');
    });
  });

  group('Address Model', () {
    test('fullAddress builds correctly', () {
      const address = AddressBody(
        fullName: 'Test User',
        phone: '1234567890',
        street: '123 Sakura Street',
        city: 'Tokyo',
        district: 'Shibuya',
        postalCode: '150-0001',
      );

      expect(address.fullAddress, '123 Sakura Street, Tokyo, Shibuya');
    });

    test('toJson produces correct map', () {
      const address = AddressBody(
        fullName: 'Test User',
        phone: '1234567890',
        street: '123 Sakura Street',
        city: 'Tokyo',
        district: 'Shibuya',
        isDefault: true,
      );

      final json = address.toJson();

      expect(json['fullName'], 'Test User');
      expect(json['isDefault'], true);
    });
  });

  group('ProductListResponse', () {
    test('fromJson with empty products', () {
      final json = {
        'products': [],
        'total': 0,
        'page': 1,
        'totalPages': 0,
      };

      final response = ProductListResponse.fromJson(json);

      expect(response.products, isEmpty);
      expect(response.total, 0);
      expect(response.page, 1);
      expect(response.totalPages, 0);
    });
  });
}
