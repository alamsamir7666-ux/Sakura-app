import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class GiftCardsScreen extends StatelessWidget {
  const GiftCardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gift Cards')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.card_giftcard, size: 64, color: AppTheme.primaryPink),
          const SizedBox(height: 16),
          const Text('Sakura Beauty Gift Cards',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Give the gift of glowing skin',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.warmGray)),
          const SizedBox(height: 24),
          ...['\$25', '\$50', '\$100', '\$200'].map((amount) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading:
                      const Icon(Icons.card_giftcard, color: AppTheme.accentRose),
                  title: Text('$amount Gift Card',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Delivered instantly via email'),
                  trailing:
                      ElevatedButton(onPressed: () {}, child: const Text('Buy')),
                ),
              )),
        ],
      ),
    );
  }
}
