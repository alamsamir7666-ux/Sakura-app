import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class LoyaltyScreen extends StatelessWidget {
  const LoyaltyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loyalty Rewards')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.stars, size: 48, color: AppTheme.mutedGold),
                  const SizedBox(height: 12),
                  const Text('Your Points',
                      style: TextStyle(fontSize: 14, color: AppTheme.warmGray)),
                  const Text('0',
                      style:
                          TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Earn 1 point for every \$1 spent',
                      style: TextStyle(color: AppTheme.warmGray, fontSize: 12)),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: 0,
                    backgroundColor: AppTheme.primaryPink.withOpacity(0.1),
                    color: AppTheme.mutedGold,
                    minHeight: 8,
                  ),
                  const SizedBox(height: 4),
                  const Text('100 points until next reward',
                      style: TextStyle(color: AppTheme.warmGray, fontSize: 11)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Rewards',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...[
            {'points': '100', 'reward': '\$5 off your next order'},
            {'points': '250', 'reward': '\$15 off your next order'},
            {'points': '500', 'reward': 'Free deluxe sample set'},
            {'points': '1000', 'reward': '\$50 off + free shipping'},
          ].map((r) => Card(
                child: ListTile(
                  leading: const Icon(Icons.redeem, color: AppTheme.mutedGold),
                  title: Text(r['reward']!),
                  subtitle: Text('${r['points']} points'),
                  trailing: const OutlinedButton(
                    onPressed: null,
                    child: Text('Redeem'),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
