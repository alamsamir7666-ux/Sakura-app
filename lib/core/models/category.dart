class Category {
  final int id;
  final String name;
  final String slug;
  final String? icon;
  final int displayOrder;
  final String createdAt;
  final String updatedAt;

  const Category({
    required this.id,
    required this.name,
    required this.slug,
    this.icon,
    required this.displayOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      icon: json['icon'] as String?,
      displayOrder: json['displayOrder'] as int,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'slug': slug,
        'icon': icon,
        'displayOrder': displayOrder,
      };
}
