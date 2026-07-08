class UserProfile {
  final int id;
  final String clerkId;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String role;
  final bool isBlocked;
  final String createdAt;

  const UserProfile({
    required this.id,
    required this.clerkId,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    required this.role,
    required this.isBlocked,
    required this.createdAt,
  });

  String get fullName =>
      [firstName, lastName].where((e) => e != null && e.isNotEmpty).join(' ') ??
      email;
  bool get isAdmin => role == 'admin';

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      clerkId: json['clerkId'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      phone: json['phone'] as String?,
      role: json['role'] as String,
      isBlocked: json['isBlocked'] as bool? ?? false,
      createdAt: json['createdAt'] as String,
    );
  }
}

class Review {
  final int id;
  final int productId;
  final String userId;
  final String userName;
  final int rating;
  final String comment;
  final String createdAt;

  const Review({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as int,
      productId: json['productId'] as int,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String,
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'rating': rating,
        'comment': comment,
      };
}

class ReviewEligibility {
  final bool canReview;
  final String? reason;

  const ReviewEligibility({required this.canReview, this.reason});

  factory ReviewEligibility.fromJson(Map<String, dynamic> json) {
    return ReviewEligibility(
      canReview: json['canReview'] as bool,
      reason: json['reason'] as String?,
    );
  }
}
