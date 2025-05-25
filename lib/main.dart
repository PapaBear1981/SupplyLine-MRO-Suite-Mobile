import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/config/app_config.dart';
import 'core/config/environment_config.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/storage_service.dart';
import 'core/services/auth_service.dart';
// import 'core/services/firebase_service.dart';  // Temporarily disabled
import 'core/services/logging_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment configuration
  EnvironmentConfig.initialize();

  // Initialize logging service
  LoggingService.initialize();
  LoggingService.info('🚀 Starting SupplyLine MRO Suite Mobile App');

  // Initialize Firebase services - Temporarily disabled
  // await FirebaseService.initialize();

  // Initialize Hive for local storage
  await Hive.initFlutter();
  await StorageService.init();

  LoggingService.info('✅ All services initialized successfully');

  runApp(
    const ProviderScope(
      child: SupplyLineMROApp(),
    ),
  );
}

class SupplyLineMROApp extends ConsumerWidget {
  const SupplyLineMROApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'SupplyLine MRO Suite',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
