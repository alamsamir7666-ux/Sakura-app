import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class EmailPreferencesScreen extends StatelessWidget {
  const EmailPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Email Preferences')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Promotional Emails'),
                  subtitle: const Text('Receive offers and deals'),
                  value: true,
                  onChanged: (_) {},
                  activeColor: AppTheme.primaryPink,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Order Updates'),
                  subtitle: const Text('Order confirmations and shipping'),
                  value: true,
                  onChanged: (_) {},
                  activeColor: AppTheme.primaryPink,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Newsletter'),
                  subtitle: const Text('Skincare tips and blog posts'),
                  value: false,
                  onChanged: (_) {},
                  activeColor: AppTheme.primaryPink,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
