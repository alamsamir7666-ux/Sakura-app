class ProductVariant {
  final int id;
  final int productId;
  final String name;
  final String? size;
  final String? color;
  final double? priceModifier;
  final int stock;

  const ProductVariant({
    required this.id,
    required this.productId,
    required this.name,
    this.size,
    this.color,
    this.priceModifier,
    required this.stock,
  });

  bool get inStock => stock > 0;

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] as int,
      productId: json['productId'] as int,
      name: json['name'] as String,
      size: json['size'] as String?,
      color: json['color'] as String?,
      priceModifier: json['priceModifier'] != null
          ? (json['priceModifier'] as num).toDouble()
          : null,
      stock: json['stock'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'size': size,
        'color': color,
        'priceModifier': priceModifier,
        'stock': stock,
      };
}

class ProductQA {
  final int id;
  final int productId;
  final String userId;
  final String userName;
  final String question;
  final String? answer;
  final String createdAt;
  final String? answeredAt;

  const ProductQA({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.question,
    this.answer,
    required this.createdAt,
    this.answeredAt,
  });

  bool get isAnswered => answer != null;

  factory ProductQA.fromJson(Map<String, dynamic> json) {
    return ProductQA(
      id: json['id'] as int,
      productId: json['productId'] as int,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String?,
      createdAt: json['createdAt'] as String,
      answeredAt: json['answeredAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'question': question,
      };
}

class StockAlert {
  final int id;
  final int productId;
  final String? variantId;
  final String email;
  final bool notified;
  final String createdAt;

  const StockAlert({
    required this.id,
    required this.productId,
    this.variantId,
    required this.email,
    required this.notified,
    required this.createdAt,
  });

  factory StockAlert.fromJson(Map<String, dynamic> json) {
    return StockAlert(
      id: json['id'] as int,
      productId: json['productId'] as int,
      variantId: json['variantId'] as String?,
      email: json['email'] as String,
      notified: json['notified'] as bool? ?? false,
      createdAt: json['createdAt'] as String,
    );
  }
}
