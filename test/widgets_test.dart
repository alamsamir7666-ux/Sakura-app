import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../lib/shared/widgets/common_widgets.dart';
import '../lib/shared/widgets/product_card.dart';
import '../lib/core/theme/app_theme.dart';

void main() {
  group('Common Widgets', () {
    testWidgets('EmptyState renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const EmptyState(
              icon: Icons.favorite,
              title: 'Test Title',
              subtitle: 'Test Subtitle',
            ),
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Subtitle'), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('EmptyState with action button', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.shopping_bag,
              title: 'Empty',
              subtitle: 'Nothing here',
              actionLabel: 'Shop Now',
              onAction: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Shop Now'), findsOneWidget);
      await tester.tap(find.text('Shop Now'));
      expect(tapped, true);
    });

    testWidgets('PriceDisplay shows discount correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PriceDisplay(price: 24.99, originalPrice: 49.99),
          ),
        ),
      );

      expect(find.text('\$24.99'), findsOneWidget);
      expect(find.text('\$49.99'), findsOneWidget);
    });
  });

  group('Theme', () {
    test('Light theme uses correct primary color', () {
      final theme = AppTheme.lightTheme;
      expect(theme.colorScheme.primary, AppTheme.primaryPink);
      expect(theme.brightness, Brightness.light);
      expect(theme.scaffoldBackgroundColor, AppTheme.sakuraWhite);
    });

    test('Dark theme uses dark brightness', () {
      final theme = AppTheme.darkTheme;
      expect(theme.brightness, Brightness.dark);
    });

    test('Theme constants are correct', () {
      expect(AppTheme.primaryPink, const Color(0xFFE8A0BF));
      expect(AppTheme.accentRose, const Color(0xFFC86B85));
      expect(AppTheme.charcoal, const Color(0xFF3D3D3D));
    });
  });
}
