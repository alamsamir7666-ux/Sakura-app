class SkinProfile {
  final int id;
  final String userId;
  final String skinType;
  final List<String> concerns;
  final String? sensitivity;
  final String? preferredTexture;
  final List<String>? allergies;
  final String createdAt;
  final String updatedAt;

  const SkinProfile({
    required this.id,
    required this.userId,
    required this.skinType,
    required this.concerns,
    this.sensitivity,
    this.preferredTexture,
    this.allergies,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SkinProfile.fromJson(Map<String, dynamic> json) {
    return SkinProfile(
      id: json['id'] as int,
      userId: json['userId'] as String,
      skinType: json['skinType'] as String,
      concerns: List<String>.from(json['concerns'] ?? []),
      sensitivity: json['sensitivity'] as String?,
      preferredTexture: json['preferredTexture'] as String?,
      allergies: json['allergies'] != null
          ? List<String>.from(json['allergies'] as List)
          : null,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'skinType': skinType,
        'concerns': concerns,
        'sensitivity': sensitivity,
        'preferredTexture': preferredTexture,
        'allergies': allergies,
      };
}

class ReturnRequest {
  final int id;
  final int orderId;
  final String reason;
  final String status;
  final String? notes;
  final String createdAt;
  final String? resolvedAt;

  const ReturnRequest({
    required this.id,
    required this.orderId,
    required this.reason,
    required this.status,
    this.notes,
    required this.createdAt,
    this.resolvedAt,
  });

  factory ReturnRequest.fromJson(Map<String, dynamic> json) {
    return ReturnRequest(
      id: json['id'] as int,
      orderId: json['orderId'] as int,
      reason: json['reason'] as String,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] as String,
      resolvedAt: json['resolvedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'reason': reason,
        'notes': notes,
      };
}

class Affiliate {
  final int id;
  final String userId;
  final String code;
  final double commissionRate;
  final double totalEarnings;
  final bool isActive;
  final String createdAt;

  const Affiliate({
    required this.id,
    required this.userId,
    required this.code,
    required this.commissionRate,
    required this.totalEarnings,
    required this.isActive,
    required this.createdAt,
  });

  factory Affiliate.fromJson(Map<String, dynamic> json) {
    return Affiliate(
      id: json['id'] as int,
      userId: json['userId'] as String,
      code: json['code'] as String,
      commissionRate: (json['commissionRate'] as num).toDouble(),
      totalEarnings: (json['totalEarnings'] as num).toDouble(),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] as String,
    );
  }
}

class AffiliateCashout {
  final int id;
  final int affiliateId;
  final double amount;
  final String status;
  final String? paymentMethod;
  final String? transactionId;
  final String createdAt;

  const AffiliateCashout({
    required this.id,
    required this.affiliateId,
    required this.amount,
    required this.status,
    this.paymentMethod,
    this.transactionId,
    required this.createdAt,
  });

  factory AffiliateCashout.fromJson(Map<String, dynamic> json) {
    return AffiliateCashout(
      id: json['id'] as int,
      affiliateId: json['affiliateId'] as int,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      paymentMethod: json['paymentMethod'] as String?,
      transactionId: json['transactionId'] as String?,
      createdAt: json['createdAt'] as String,
    );
  }
}

class Newsletter {
  final int id;
  final String email;
  final bool isActive;
  final String? subscribedAt;
  final String? unsubscribedAt;

  const Newsletter({
    required this.id,
    required this.email,
    required this.isActive,
    this.subscribedAt,
    this.unsubscribedAt,
  });

  factory Newsletter.fromJson(Map<String, dynamic> json) {
    return Newsletter(
      id: json['id'] as int,
      email: json['email'] as String,
      isActive: json['isActive'] as bool? ?? true,
      subscribedAt: json['subscribedAt'] as String?,
      unsubscribedAt: json['unsubscribedAt'] as String?,
    );
  }
}

class FlashSale {
  final int id;
  final int productId;
  final double salePrice;
  final int quantity;
  final int sold;
  final DateTime startTime;
  final DateTime endTime;
  final bool isActive;

  const FlashSale({
    required this.id,
    required this.productId,
    required this.salePrice,
    required this.quantity,
    required this.sold,
    required this.startTime,
    required this.endTime,
    required this.isActive,
  });

  int get remaining => quantity - sold;
  double get progress => quantity > 0 ? sold / quantity : 0;
  bool get isExpired => DateTime.now().isAfter(endTime);
  bool get isSoldOut => sold >= quantity;

  factory FlashSale.fromJson(Map<String, dynamic> json) {
    return FlashSale(
      id: json['id'] as int,
      productId: json['productId'] as int,
      salePrice: (json['salePrice'] as num).toDouble(),
      quantity: json['quantity'] as int,
      sold: json['sold'] as int? ?? 0,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}
