import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/api/extra_services.dart';
import '../../core/models/dashboard.dart' as dm;

final dashboardProvider = FutureProvider<dm.DashboardStats>((ref) {
  return ref.watch(adminServiceProvider).getDashboard().then(
      (data) => dm.DashboardStats.fromJson(data as Map<String, dynamic>));
});

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashAsync = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: dashAsync.when(
        data: (stats) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(dashboardProvider),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Stats Cards
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: [
                  _StatCard('Total Sales',
                      '\$${stats.totalSales.toStringAsFixed(0)}',
                      Icons.trending_up, AppTheme.successGreen),
                  _StatCard('Orders', '${stats.totalOrders}',
                      Icons.receipt_long, AppTheme.primaryPink),
                  _StatCard('Users', '${stats.totalUsers}',
                      Icons.people, AppTheme.softGreen),
                  _StatCard('Pending', '${stats.pendingOrders}',
                      Icons.pending, AppTheme.warningOrange),
                ],
              ),
              const SizedBox(height: 24),
              // Quick Actions
              const Text('Quick Actions',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ActionChip('Products', Icons.spa, () {}),
                  _ActionChip('Categories', Icons.category, () {}),
                  _ActionChip('Orders', Icons.receipt, () {}),
                  _ActionChip('Users', Icons.people, () {}),
                  _ActionChip('Coupons', Icons.discount, () {}),
                  _ActionChip('Reviews', Icons.star, () {}),
                ],
              ),
              const SizedBox(height: 24),
              // Recent Orders
              const Text('Recent Orders',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (stats.recentOrders.isEmpty)
                const Text('No recent orders',
                    style: TextStyle(color: AppTheme.warmGray))
              else
                ...stats.recentOrders.take(5).map((order) {
                  final o = order as Map<String, dynamic>;
                  return Card(
                    child: ListTile(
                      title: Text('Order #${o['trackingId']}'),
                      subtitle: Text('${o['orderStatus']} • \$${o['totalAmount']}'),
                      trailing: Text(o['createdAt'].toString().substring(0, 10)),
                    ),
                  );
                }),
              const SizedBox(height: 24),
              // Sales by Category
              const Text('Sales by Category',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...stats.salesByCategory.map((cs) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(cs.category,
                            style: const TextStyle(fontSize: 13)),
                      ),
                      Expanded(
                        flex: 3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: stats.totalSales > 0
                                ? cs.total / stats.totalSales
                                : 0,
                            backgroundColor:
                                AppTheme.primaryPink.withOpacity(0.1),
                            color: AppTheme.primaryPink,
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('\$${cs.total.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 32),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.warmGray, fontSize: 11)),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionChip(this.label, this.icon, this.onTap);

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      onPressed: onTap,
      backgroundColor: AppTheme.secondaryPink.withOpacity(0.2),
    );
  }
}
