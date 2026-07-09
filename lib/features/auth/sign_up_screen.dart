import 'package:flutter/material.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import '../../core/theme/app_theme.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.spa, size: 64, color: AppTheme.primaryPink),
              ),
              const SizedBox(height: 24),
              const Text('Join Sakura Beauty',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Create an account to start shopping',
                  style: TextStyle(color: AppTheme.warmGray, fontSize: 15)),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: const ClerkAuthentication(),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
