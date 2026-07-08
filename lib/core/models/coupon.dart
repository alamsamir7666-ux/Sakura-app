class Coupon {
  final int id;
  final String code;
  final String discountType;
  final double discountValue;
  final double? minOrderAmount;
  final String? expiryDate;
  final bool isActive;

  const Coupon({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    this.minOrderAmount,
    this.expiryDate,
    required this.isActive,
  });

  String get discountLabel => discountType == 'percentage'
      ? '${discountValue.toInt()}% OFF'
      : '\$${discountValue.toStringAsFixed(2)} OFF';

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'] as int,
      code: json['code'] as String,
      discountType: json['discountType'] as String,
      discountValue: (json['discountValue'] as num).toDouble(),
      minOrderAmount: json['minOrderAmount'] != null
          ? (json['minOrderAmount'] as num).toDouble()
          : null,
      expiryDate: json['expiryDate'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'discountType': discountType,
        'discountValue': discountValue,
        'minOrderAmount': minOrderAmount,
        'expiryDate': expiryDate,
      };
}
