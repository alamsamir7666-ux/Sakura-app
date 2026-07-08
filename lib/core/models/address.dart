class AddressBody {
  final String fullName;
  final String phone;
  final String street;
  final String city;
  final String district;
  final String? postalCode;
  final bool isDefault;

  const AddressBody({
    required this.fullName,
    required this.phone,
    required this.street,
    required this.city,
    required this.district,
    this.postalCode,
    this.isDefault = false,
  });

  String get fullAddress => '$street, $city, $district';

  factory AddressBody.fromJson(Map<String, dynamic> json) {
    return AddressBody(
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      street: json['street'] as String,
      city: json['city'] as String,
      district: json['district'] as String,
      postalCode: json['postalCode'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'phone': phone,
        'street': street,
        'city': city,
        'district': district,
        'postalCode': postalCode,
        'isDefault': isDefault,
      };
}

class Address {
  final int id;
  final String userId;
  final String fullName;
  final String phone;
  final String street;
  final String city;
  final String district;
  final String? postalCode;
  final bool isDefault;

  const Address({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phone,
    required this.street,
    required this.city,
    required this.district,
    this.postalCode,
    this.isDefault = false,
  });

  String get fullAddress => '$street, $city, $district';

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as int,
      userId: json['userId'] as String,
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      street: json['street'] as String,
      city: json['city'] as String,
      district: json['district'] as String,
      postalCode: json['postalCode'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'phone': phone,
        'street': street,
        'city': city,
        'district': district,
        'postalCode': postalCode,
        'isDefault': isDefault,
      };
}
