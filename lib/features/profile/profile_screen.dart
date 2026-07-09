import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ClerkAuthBuilder(
        signedInBuilder: (context, authState) => _buildProfile(context, ref, authState),
        signedOutBuilder: (context, authState) => _buildSignInPrompt(context),
      ),
    );
  }

  Widget _buildProfile(BuildContext context, WidgetRef ref, ClerkAuthState authState) {
    final user = authState.user;
    final email = authState.userEmailAddresses.isNotEmpty
        ? authState.userEmailAddresses.first.emailAddress
        : '';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppTheme.primaryPink.withOpacity(0.1),
                  backgroundImage: authState.userImageUrl != null
                      ? NetworkImage(authState.userImageUrl!)
                      : null,
                  child: authState.userImageUrl == null
                      ? Text(
                          (authState.userFullName?.isNotEmpty == true
                                  ? authState.userFullName![0]
                                  : 'U')
                              .toUpperCase(),
                          style: const TextStyle(
                              color: AppTheme.primaryPink,
                              fontWeight: FontWeight.bold,
                              fontSize: 22),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authState.userFullName ?? 'User',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(email,
                          style: const TextStyle(color: AppTheme.warmGray, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildMenuSection('Account', [
          _MenuItem(Icons.shopping_bag, 'My Orders', () => context.push('/orders')),
          _MenuItem(Icons.favorite, 'Wishlist', () => context.push('/wishlist')),
          _MenuItem(Icons.location_on, 'Addresses', () => context.push('/addresses')),
          _MenuItem(Icons.local_shipping, 'Track Order', () => context.push('/track')),
        ]),
        _buildMenuSection('Rewards', [
          _MenuItem(Icons.card_giftcard, 'Loyalty Points', () => context.push('/loyalty')),
          _MenuItem(Icons.share, 'Refer a Friend', () => context.push('/referral')),
          _MenuItem(Icons.card_giftcard_outlined, 'Gift Cards', () => context.push('/gift-cards')),
        ]),
        _buildMenuSection('More', [
          _MenuItem(Icons.face, 'Skin Profile', () => context.push('/skin-profile')),
          _MenuItem(Icons.subscriptions, 'Subscriptions', () => context.push('/subscriptions')),
          _MenuItem(Icons.keyboard_return, 'Returns & Refunds', () => context.push('/returns')),
          _MenuItem(Icons.article, 'Blog', () => context.push('/blog')),
          _MenuItem(Icons.email, 'Email Preferences', () => context.push('/email-preferences')),
          _MenuItem(Icons.mail, 'Newsletter', () => context.push('/newsletter')),
          _MenuItem(Icons.compare_arrows, 'Compare Products', () => context.push('/compare')),
          _MenuItem(Icons.settings, 'Settings', () => context.push('/settings')),
        ]),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => authState.signOut(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.errorRed,
              side: const BorderSide(color: AppTheme.errorRed),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Sign Out'),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSignInPrompt(BuildContext context) {
    return EmptyState(
      icon: Icons.person_outline,
      title: 'Sign in to your account',
      subtitle: 'Access your orders, wishlist, and more',
      actionLabel: 'Sign In',
      onAction: () => context.push('/sign-in'),
    );
  }

  Widget _buildMenuSection(String title, List<_MenuItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryPink)),
        ),
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            children: items.map((item) {
              final isLast = items.last == item;
              return Column(
                children: [
                  ListTile(
                    leading: Icon(item.icon, color: AppTheme.charcoal, size: 22),
                    title: Text(item.title, style: const TextStyle(fontSize: 14)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.warmGray),
                    onTap: item.onTap,
                  ),
                  if (!isLast) const Divider(height: 1, indent: 56),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _MenuItem(this.icon, this.title, this.onTap);
}
