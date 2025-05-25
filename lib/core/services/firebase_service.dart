import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

/// Firebase service for crash reporting, analytics, and performance monitoring
class FirebaseService {
  static FirebaseAnalytics? _analytics;
  static FirebaseCrashlytics? _crashlytics;
  static FirebasePerformance? _performance;
  
  static FirebaseAnalytics? get analytics => _analytics;
  static FirebaseCrashlytics? get crashlytics => _crashlytics;
  static FirebasePerformance? get performance => _performance;
  
  /// Initialize Firebase services based on environment
  static Future<void> initialize() async {
    try {
      // Only initialize Firebase in production or when explicitly enabled
      if (AppConfig.enableCrashReporting || kDebugMode) {
        await Firebase.initializeApp();
        
        // Initialize Analytics
        _analytics = FirebaseAnalytics.instance;
        await _analytics!.setAnalyticsCollectionEnabled(AppConfig.enableCrashReporting);
        
        // Initialize Crashlytics
        _crashlytics = FirebaseCrashlytics.instance;
        await _crashlytics!.setCrashlyticsCollectionEnabled(AppConfig.enableCrashReporting);
        
        // Initialize Performance Monitoring
        _performance = FirebasePerformance.instance;
        await _performance!.setPerformanceCollectionEnabled(AppConfig.enableCrashReporting);
        
        // Set up crash reporting for Flutter errors
        if (AppConfig.enableCrashReporting) {
          FlutterError.onError = _crashlytics!.recordFlutterFatalError;
          
          // Pass all uncaught asynchronous errors to Crashlytics
          PlatformDispatcher.instance.onError = (error, stack) {
            _crashlytics!.recordError(error, stack, fatal: true);
            return true;
          };
        }
        
        if (kDebugMode) {
          print('🔥 Firebase services initialized');
          print('📊 Analytics enabled: ${AppConfig.enableCrashReporting}');
          print('💥 Crashlytics enabled: ${AppConfig.enableCrashReporting}');
          print('⚡ Performance monitoring enabled: ${AppConfig.enableCrashReporting}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to initialize Firebase: $e');
      }
    }
  }
  
  /// Log custom event to analytics
  static Future<void> logEvent(String name, Map<String, Object>? parameters) async {
    if (_analytics != null && AppConfig.enableCrashReporting) {
      await _analytics!.logEvent(name: name, parameters: parameters);
    }
  }
  
  /// Log user login event
  static Future<void> logLogin(String method) async {
    await logEvent('login', {'login_method': method});
  }
  
  /// Log user logout event
  static Future<void> logLogout() async {
    await logEvent('logout', null);
  }
  
  /// Log tool checkout event
  static Future<void> logToolCheckout(String toolId, String toolName) async {
    await logEvent('tool_checkout', {
      'tool_id': toolId,
      'tool_name': toolName,
    });
  }
  
  /// Log tool return event
  static Future<void> logToolReturn(String toolId, String toolName) async {
    await logEvent('tool_return', {
      'tool_id': toolId,
      'tool_name': toolName,
    });
  }
  
  /// Log search event
  static Future<void> logSearch(String searchTerm, String category) async {
    await logEvent('search', {
      'search_term': searchTerm,
      'category': category,
    });
  }
  
  /// Set user ID for analytics
  static Future<void> setUserId(String userId) async {
    if (_analytics != null && AppConfig.enableCrashReporting) {
      await _analytics!.setUserId(id: userId);
    }
  }
  
  /// Set user properties
  static Future<void> setUserProperty(String name, String value) async {
    if (_analytics != null && AppConfig.enableCrashReporting) {
      await _analytics!.setUserProperty(name: name, value: value);
    }
  }
  
  /// Record custom error
  static Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    bool fatal = false,
    Map<String, dynamic>? context,
  }) async {
    if (_crashlytics != null && AppConfig.enableCrashReporting) {
      await _crashlytics!.recordError(
        exception,
        stackTrace,
        fatal: fatal,
        information: context?.entries.map((e) => '${e.key}: ${e.value}').toList() ?? [],
      );
    }
  }
  
  /// Log custom message
  static Future<void> log(String message) async {
    if (_crashlytics != null && AppConfig.enableCrashReporting) {
      await _crashlytics!.log(message);
    }
  }
  
  /// Start performance trace
  static Trace? startTrace(String name) {
    if (_performance != null && AppConfig.enableCrashReporting) {
      return _performance!.newTrace(name);
    }
    return null;
  }
  
  /// Create HTTP metric
  static HttpMetric? createHttpMetric(String url, HttpMethod method) {
    if (_performance != null && AppConfig.enableCrashReporting) {
      return _performance!.newHttpMetric(url, method);
    }
    return null;
  }
}
