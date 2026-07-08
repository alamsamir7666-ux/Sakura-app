import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class BlogArticleScreen extends StatelessWidget {
  final int postId;

  const BlogArticleScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Article')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppTheme.secondaryPink.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(Icons.spa, size: 48, color: AppTheme.primaryPink),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Article Title',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.calendar_today, size: 12, color: AppTheme.warmGray),
                SizedBox(width: 4),
                Text('June 2026',
                    style: TextStyle(color: AppTheme.warmGray, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
              'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
              style: TextStyle(fontSize: 15, height: 1.7, color: AppTheme.charcoal),
            ),
          ],
        ),
      ),
    );
  }
}
