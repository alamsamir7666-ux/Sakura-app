import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'app.dart';
import 'core/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Clerk
  await Clerk.initialize(
    publishableKey: const String.fromEnvironment('CLERK_PUBLISHABLE_KEY'),
  );

  AppLogger.init();

  runApp(
    const ProviderScope(
      child: SakuraBeautyApp(),
    ),
  );
}
