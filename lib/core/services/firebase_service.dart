// Temporarily disabled Firebase imports for web testing
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

/// Firebase service for crash reporting, analytics, and performance monitoring
/// Temporarily disabled for web testing
class FirebaseService {
  // static FirebaseAnalytics? _analytics;
  // static FirebaseCrashlytics? _crashlytics;
  // static FirebasePerformance? _performance;

  // static FirebaseAnalytics? get analytics => _analytics;
  // static FirebaseCrashlytics? get crashlytics => _crashlytics;
  // static FirebasePerformance? get performance => _performance;

  /// Initialize Firebase services based on environment
  /// Temporarily disabled for web testing
  static Future<void> initialize() async {
    if (kDebugMode) {
      print('🔥 Firebase services temporarily disabled for web testing');
    }
  }

  /// Log custom event to analytics - Temporarily disabled for web testing
  static Future<void> logEvent(String name, Map<String, Object>? parameters) async {
    // Stub implementation
  }

  /// Log user login event - Temporarily disabled for web testing
  static Future<void> logLogin(String method) async {
    // Stub implementation
  }

  /// Log user logout event - Temporarily disabled for web testing
  static Future<void> logLogout() async {
    // Stub implementation
  }

  /// Log tool checkout event - Temporarily disabled for web testing
  static Future<void> logToolCheckout(String toolId, String toolName) async {
    // Stub implementation
  }

  /// Log tool return event - Temporarily disabled for web testing
  static Future<void> logToolReturn(String toolId, String toolName) async {
    // Stub implementation
  }

  /// Log search event - Temporarily disabled for web testing
  static Future<void> logSearch(String searchTerm, String category) async {
    // Stub implementation
  }

  /// Set user ID for analytics - Temporarily disabled for web testing
  static Future<void> setUserId(String userId) async {
    // Stub implementation
  }

  /// Set user properties - Temporarily disabled for web testing
  static Future<void> setUserProperty(String name, String value) async {
    // Stub implementation
  }

  /// Record custom error - Temporarily disabled for web testing
  static Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    bool fatal = false,
    Map<String, dynamic>? context,
  }) async {
    // Stub implementation
  }

  /// Log custom message - Temporarily disabled for web testing
  static Future<void> log(String message) async {
    // Stub implementation
  }

  /// Start performance trace - Temporarily disabled for web testing
  static dynamic startTrace(String name) {
    // Stub implementation
    return null;
  }

  /// Create HTTP metric - Temporarily disabled for web testing
  static dynamic createHttpMetric(String url, dynamic method) {
    // Stub implementation
    return null;
  }
}
