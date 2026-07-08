import 'package:flutter/foundation.dart';

enum BuildFlavor { development, staging, production }

class AppConfig {
  final BuildFlavor flavor;
  final String clerkPublishableKey;
  final String apiBaseUrl;
  final bool enableLogging;
  final bool enableAnalytics;

  const AppConfig({
    required this.flavor,
    required this.clerkPublishableKey,
    required this.apiBaseUrl,
    required this.enableLogging,
    required this.enableAnalytics,
  });

  static AppConfig fromEnvironment() {
    const flavorStr = String.fromEnvironment('FLAVOR', defaultValue: 'development');
    return AppConfig(
      flavor: switch (flavorStr) {
        'production' => BuildFlavor.production,
        'staging' => BuildFlavor.staging,
        _ => BuildFlavor.development,
      },
      clerkPublishableKey: const String.fromEnvironment('CLERK_PUBLISHABLE_KEY'),
      apiBaseUrl: const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'https://envy-enhance-fixed5.vercel.app',
      ),
      enableLogging: const bool.fromEnvironment('ENABLE_LOGGING', defaultValue: true),
      enableAnalytics: const bool.fromEnvironment('ENABLE_ANALYTICS', defaultValue: false),
    );
  }

  bool get isProduction => flavor == BuildFlavor.production;
  bool get isStaging => flavor == BuildFlavor.staging;
  bool get isDevelopment => flavor == BuildFlavor.development;
}
