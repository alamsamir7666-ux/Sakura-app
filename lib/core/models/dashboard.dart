class DashboardStats {
  final double totalSales;
  final int totalOrders;
  final int totalUsers;
  final int pendingOrders;
  final List<dynamic> recentOrders;
  final List<CategorySales> salesByCategory;
  final List<MonthlySales> monthlySales;

  const DashboardStats({
    required this.totalSales,
    required this.totalOrders,
    required this.totalUsers,
    required this.pendingOrders,
    required this.recentOrders,
    required this.salesByCategory,
    required this.monthlySales,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalSales: (json['totalSales'] as num).toDouble(),
      totalOrders: json['totalOrders'] as int,
      totalUsers: json['totalUsers'] as int,
      pendingOrders: json['pendingOrders'] as int,
      recentOrders: json['recentOrders'] as List<dynamic>,
      salesByCategory: (json['salesByCategory'] as List<dynamic>)
          .map((e) => CategorySales.fromJson(e as Map<String, dynamic>))
          .toList(),
      monthlySales: (json['monthlySales'] as List<dynamic>)
          .map((e) => MonthlySales.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CategorySales {
  final String category;
  final double total;
  final int count;

  const CategorySales({
    required this.category,
    required this.total,
    required this.count,
  });

  factory CategorySales.fromJson(Map<String, dynamic> json) {
    return CategorySales(
      category: json['category'] as String,
      total: (json['total'] as num).toDouble(),
      count: json['count'] as int,
    );
  }
}

class MonthlySales {
  final String month;
  final double total;
  final int orders;

  const MonthlySales({
    required this.month,
    required this.total,
    required this.orders,
  });

  factory MonthlySales.fromJson(Map<String, dynamic> json) {
    return MonthlySales(
      month: json['month'] as String,
      total: (json['total'] as num).toDouble(),
      orders: json['orders'] as int,
    );
  }
}
