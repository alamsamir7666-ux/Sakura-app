import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../core/api/extra_services.dart';
import '../../core/models/dashboard.dart' as dm;

final dashboardProvider = FutureProvider<dm.DashboardStats>((ref) {
  return ref.watch(adminServiceProvider).getDashboard().then(
      (data) => dm.DashboardStats.fromJson(data as Map<String, dynamic>));
});

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _ordersPage = 1;
  int _usersPage = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashAsync = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(dashboardProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: AppTheme.accentRose,
            unselectedLabelColor: AppTheme.warmGray,
            indicatorColor: AppTheme.accentRose,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Orders'),
              Tab(text: 'Products'),
              Tab(text: 'Users'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverview(dashAsync),
                _buildOrdersTab(),
                _buildProductsTab(),
                _buildUsersTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverview(AsyncValue<dm.DashboardStats> dashAsync) {
    return dashAsync.when(
      data: (stats) => RefreshIndicator(
        onRefresh: () async => ref.invalidate(dashboardProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildStatCards(stats),
            const SizedBox(height: 24),
            _buildSalesChart(stats),
            const SizedBox(height: 24),
            _buildCategoryChart(stats),
            const SizedBox(height: 24),
            _buildRecentOrdersTable(stats),
            const SizedBox(height: 32),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildStatCards(dm.DashboardStats stats) {
    final cards = [
      ('Total Sales', '\$${stats.totalSales.toStringAsFixed(0)}', Icons.trending_up, AppTheme.successGreen, '12+% vs last month'),
      ('Orders', '${stats.totalOrders}', Icons.receipt_long, AppTheme.primaryPink, '${stats.pendingOrders} pending'),
      ('Users', '${stats.totalUsers}', Icons.people, AppTheme.softGreen, 'Registered users'),
      ('Revenue', '\$${(stats.totalSales / (stats.totalOrders == 0 ? 1 : stats.totalOrders)).toStringAsFixed(2)}', Icons.attach_money, AppTheme.mutedGold, 'Avg per order'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 1.5, crossAxisSpacing: 12, mainAxisSpacing: 12),
      itemCount: cards.length,
      itemBuilder: (_, i) {
        final (title, value, icon, color, subtitle) = cards[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const Spacer(),
                  Icon(Icons.more_horiz, size: 14, color: AppTheme.warmGray.withOpacity(0.5)),
                ],
              ),
              const Spacer(),
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.charcoal)),
              Text(subtitle, style: const TextStyle(fontSize: 10, color: AppTheme.warmGray)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSalesChart(dm.DashboardStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppTheme.primaryPink.withOpacity(0.06), blurRadius: 8)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Monthly Sales', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Revenue over time', style: TextStyle(fontSize: 11, color: AppTheme.warmGray)),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: stats.monthlySales.isEmpty
                ? const Center(child: Text('No data', style: TextStyle(color: AppTheme.warmGray)))
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: stats.monthlySales.map((m) => m.total).reduce((a, b) => a > b ? a : b) * 1.2,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                            '\$${rod.toY.toStringAsFixed(0)}',
                            const TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx >= 0 && idx < stats.monthlySales.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(stats.monthlySales[idx].month, style: const TextStyle(fontSize: 9, color: AppTheme.warmGray)),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        )),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (v, _) =>
                            Text('\$${v.toInt()}', style: const TextStyle(fontSize: 9, color: AppTheme.warmGray)))),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(show: true, drawVerticalLine: false,
                          horizontalInterval: stats.monthlySales.isNotEmpty
                              ? (stats.monthlySales.map((m) => m.total).reduce((a, b) => a > b ? a : b) * 1.2) / 4
                              : 100),
                      borderData: FlBorderData(show: false),
                      barGroups: stats.monthlySales.asMap().entries.map((entry) => BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: entry.value.total,
                            color: AppTheme.primaryPink,
                            width: 16,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                        ],
                      )).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChart(dm.DashboardStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppTheme.primaryPink.withOpacity(0.06), blurRadius: 8)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sales by Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (stats.salesByCategory.isEmpty)
            const Center(child: Text('No data', style: TextStyle(color: AppTheme.warmGray)))
          else
            ...stats.salesByCategory.map((cs) {
              final ratio = stats.totalSales > 0 ? cs.total / stats.totalSales : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(cs.category, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                        Text('\$${cs.total.toStringAsFixed(0)} (${cs.count} orders)',
                            style: const TextStyle(fontSize: 12, color: AppTheme.warmGray)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: ratio, minHeight: 8,
                        backgroundColor: AppTheme.primaryPink.withOpacity(0.08),
                        color: AppTheme.primaryPink,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildRecentOrdersTable(dm.DashboardStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent Orders', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextButton(onPressed: () => _tabController.animateTo(1), child: const Text('View All')),
          ],
        ),
        const SizedBox(height: 8),
        if (stats.recentOrders.isEmpty)
          const Card(child: Padding(padding: EdgeInsets.all(24), child: Center(child: Text('No orders', style: TextStyle(color: AppTheme.warmGray)))))
        else
          ...stats.recentOrders.take(5).map((o) {
            final order = o as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _statusColor(order['orderStatus'] as String? ?? 'pending').withOpacity(0.1),
                  radius: 18,
                  child: Icon(Icons.receipt, size: 16, color: _statusColor(order['orderStatus'] as String? ?? 'pending')),
                ),
                title: Text('#${order['trackingId']}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text('${order['orderStatus']} • ${(order['createdAt'] as String).substring(0, 10)}',
                    style: const TextStyle(fontSize: 11, color: AppTheme.warmGray)),
                trailing: Text('\$${order['totalAmount']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildOrdersTab() {
    return FutureBuilder(
      future: ref.read(adminServiceProvider).getAllOrders(page: _ordersPage),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final orders = snapshot.data ?? [];
        if (orders.isEmpty) {
          return const Center(child: Text('No orders', style: TextStyle(color: AppTheme.warmGray)));
        }
        return RefreshIndicator(
          onRefresh: () async {
            setState(() => _ordersPage = 1);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (_, i) {
              final o = orders[i] as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: _statusColor(o['orderStatus'] as String).withOpacity(0.1),
                    radius: 18,
                    child: Icon(Icons.receipt, size: 16, color: _statusColor(o['orderStatus'] as String)),
                  ),
                  title: Text('#${o['trackingId']}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${o['orderStatus']} • \$${o['totalAmount']}',
                      style: const TextStyle(fontSize: 11, color: AppTheme.warmGray)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildOrderInfoRow('Status', o['orderStatus'].toString()),
                          _buildOrderInfoRow('Payment', o['paymentStatus'].toString()),
                          _buildOrderInfoRow('Method', o['paymentMethod'].toString()),
                          _buildOrderInfoRow('Amount', '\$${o['totalAmount']}'),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _updateOrderStatus(o['id'] as int, 'processing'),
                                  style: OutlinedButton.styleFrom(foregroundColor: AppTheme.primaryPink),
                                  child: const Text('Processing', style: TextStyle(fontSize: 11)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _updateOrderStatus(o['id'] as int, 'shipped'),
                                  style: OutlinedButton.styleFrom(foregroundColor: AppTheme.softGreen),
                                  child: const Text('Shipped', style: TextStyle(fontSize: 11)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildOrderInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.warmGray))),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildProductsTab() {
    return FutureBuilder(
      future: ref.read(productServiceProvider).getProducts(limit: 50),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final response = snapshot.data;
        if (response == null || response.products.isEmpty) {
          return const Center(child: Text('No products', style: TextStyle(color: AppTheme.warmGray)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: response.products.length,
          itemBuilder: (_, i) {
            final p = response.products[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(backgroundColor: AppTheme.secondaryPink.withOpacity(0.2)),
                title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text('${p.category} • Stock: ${p.stock} • \$${p.price}',
                    style: const TextStyle(fontSize: 11, color: AppTheme.warmGray)),
                trailing: PopupMenuButton<String>(
                  onSelected: (action) async {
                    if (action == 'delete') {
                      try {
                        await ref.read(productServiceProvider).deleteProduct(p.id);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${p.name} deleted'), backgroundColor: AppTheme.successGreen),
                          );
                          setState(() {});
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorRed),
                          );
                        }
                      }
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppTheme.errorRed))),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUsersTab() {
    return FutureBuilder(
      future: ref.read(adminServiceProvider).getAllUsers(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final users = snapshot.data ?? [];
        if (users.isEmpty) {
          return const Center(child: Text('No users', style: TextStyle(color: AppTheme.warmGray)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (_, i) {
            final u = users[i] as Map<String, dynamic>;
            final blocked = u['isBlocked'] as bool? ?? false;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: blocked ? AppTheme.errorRed.withOpacity(0.1) : AppTheme.primaryPink.withOpacity(0.1),
                  child: Text((u['email'] as String? ?? 'U')[0].toUpperCase(),
                      style: TextStyle(color: blocked ? AppTheme.errorRed : AppTheme.primaryPink, fontWeight: FontWeight.bold)),
                ),
                title: Text(u['email'] as String? ?? 'Unknown', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                subtitle: Text('${u['role']} ${blocked ? '(Blocked)' : ''}',
                    style: TextStyle(fontSize: 11, color: blocked ? AppTheme.errorRed : AppTheme.warmGray)),
                trailing: Switch(
                  value: blocked,
                  activeColor: AppTheme.errorRed,
                  onChanged: (v) => _toggleBlock(u['id'] as int, v),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _statusColor(String status) {
    return switch (status.toLowerCase()) {
      'pending' => AppTheme.warningOrange,
      'processing' || 'confirmed' => AppTheme.primaryPink,
      'shipped' => AppTheme.softGreen,
      'delivered' => AppTheme.successGreen,
      'cancelled' || 'returned' => AppTheme.errorRed,
      _ => AppTheme.warmGray,
    };
  }

  Future<void> _updateOrderStatus(int id, String status) async {
    try {
      await ref.read(adminServiceProvider).updateOrderStatus(id, status);
      ref.invalidate(dashboardProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order #$id → $status'), backgroundColor: AppTheme.successGreen),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorRed),
        );
      }
    }
  }

  Future<void> _toggleBlock(int id, bool block) async {
    try {
      await ref.read(adminServiceProvider).toggleUserBlock(id, block);
      ref.invalidate(dashboardProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(block ? 'User blocked' : 'User unblocked'), backgroundColor: AppTheme.successGreen),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorRed),
        );
      }
    }
  }
}
