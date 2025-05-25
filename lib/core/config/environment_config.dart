import 'package:flutter/foundation.dart';
import 'app_config.dart';

/// Environment configuration utility class
/// Handles environment detection and configuration setup
class EnvironmentConfig {
  static const String _envKey = 'FLUTTER_ENV';
  
  /// Initialize environment based on build mode and environment variables
  static void initialize() {
    Environment env;
    
    // Check for environment variable first
    const String? envString = String.fromEnvironment(_envKey);
    
    if (envString != null) {
      switch (envString.toLowerCase()) {
        case 'development':
        case 'dev':
          env = Environment.development;
          break;
        case 'staging':
        case 'stage':
          env = Environment.staging;
          break;
        case 'production':
        case 'prod':
          env = Environment.production;
          break;
        default:
          env = kDebugMode ? Environment.development : Environment.production;
      }
    } else {
      // Default based on build mode
      env = kDebugMode ? Environment.development : Environment.production;
    }
    
    AppConfig.setEnvironment(env);
    
    if (kDebugMode) {
      print('🌍 Environment initialized: ${env.name}');
      print('🔗 API Base URL: ${AppConfig.apiBaseUrl}');
      print('📊 Logging enabled: ${AppConfig.enableLogging}');
      print('💥 Crash reporting: ${AppConfig.enableCrashReporting}');
    }
  }
  
  /// Get current environment as string
  static String get currentEnvironment => AppConfig.environment.name;
  
  /// Check if running in development
  static bool get isDevelopment => AppConfig.environment == Environment.development;
  
  /// Check if running in staging
  static bool get isStaging => AppConfig.environment == Environment.staging;
  
  /// Check if running in production
  static bool get isProduction => AppConfig.environment == Environment.production;
  
  /// Get environment-specific configuration
  static Map<String, dynamic> get environmentConfig {
    return {
      'environment': currentEnvironment,
      'baseUrl': AppConfig.baseUrl,
      'apiBaseUrl': AppConfig.apiBaseUrl,
      'debugMode': AppConfig.isDebugMode,
      'enableLogging': AppConfig.enableLogging,
      'enableCrashReporting': AppConfig.enableCrashReporting,
      'preferRemoteData': AppConfig.preferRemoteData,
      'offlineTimeout': AppConfig.offlineTimeout.inSeconds,
      'apiTimeout': AppConfig.apiTimeout.inSeconds,
    };
  }
}
