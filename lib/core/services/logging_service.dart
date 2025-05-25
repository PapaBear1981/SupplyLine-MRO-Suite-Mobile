import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
// import 'firebase_service.dart';  // Temporarily disabled

/// Centralized logging service with multiple output options
class LoggingService {
  static Logger? _logger;
  static bool _initialized = false;

  /// Initialize the logging service
  static void initialize() {
    if (_initialized) return;

    if (AppConfig.enableLogging) {
      _logger = Logger(
        filter: _LogFilter(),
        printer: _LogPrinter(),
        output: _LogOutput(),
      );
    }

    _initialized = true;

    if (kDebugMode) {
      print('📝 Logging service initialized (enabled: ${AppConfig.enableLogging})');
    }
  }

  /// Log debug message
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (_logger != null) {
      _logger!.d(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Log info message
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    if (_logger != null) {
      _logger!.i(message, error: error, stackTrace: stackTrace);
    }

    // Also log to Firebase if enabled - Temporarily disabled
    // if (AppConfig.enableCrashReporting) {
    //   FirebaseService.log('INFO: $message');
    // }
  }

  /// Log warning message
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    if (_logger != null) {
      _logger!.w(message, error: error, stackTrace: stackTrace);
    }

    // Also log to Firebase if enabled - Temporarily disabled
    // if (AppConfig.enableCrashReporting) {
    //   FirebaseService.log('WARNING: $message');
    // }
  }

  /// Log error message
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (_logger != null) {
      _logger!.e(message, error: error, stackTrace: stackTrace);
    }

    // Also record error in Firebase if enabled - Temporarily disabled
    // if (AppConfig.enableCrashReporting && error != null) {
    //   FirebaseService.recordError(
    //     error,
    //     stackTrace,
    //     context: {'message': message},
    //   );
    // }
  }

  /// Log fatal error
  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    if (_logger != null) {
      _logger!.f(message, error: error, stackTrace: stackTrace);
    }

    // Always record fatal errors in Firebase if enabled - Temporarily disabled
    // if (AppConfig.enableCrashReporting) {
    //   FirebaseService.recordError(
    //     error ?? Exception(message),
    //     stackTrace ?? StackTrace.current,
    //     fatal: true,
    //     context: {'message': message},
    //   );
    // }
  }

  /// Log API request
  static void apiRequest(String method, String url, Map<String, dynamic>? data) {
    if (_logger != null) {
      _logger!.d('API Request: $method $url', error: data);
    }
  }

  /// Log API response
  static void apiResponse(String method, String url, int statusCode, dynamic data) {
    if (_logger != null) {
      final level = statusCode >= 400 ? Level.warning : Level.debug;
      _logger!.log(level, 'API Response: $method $url [$statusCode]', error: data);
    }
  }

  /// Log user action
  static void userAction(String action, Map<String, dynamic>? context) {
    info('User Action: $action', context);

    // Log to Firebase Analytics if enabled - Temporarily disabled
    // if (AppConfig.enableCrashReporting) {
    //   FirebaseService.logEvent('user_action', {
    //     'action': action,
    //     ...?context,
    //   });
    // }
  }

  /// Log performance metric
  static void performance(String operation, Duration duration, [Map<String, dynamic>? context]) {
    info('Performance: $operation took ${duration.inMilliseconds}ms', context);
  }
}

/// Custom log filter
class _LogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return AppConfig.enableLogging;
  }
}

/// Custom log printer
class _LogPrinter extends LogPrinter {
  @override
  List<String> log(LogEvent event) {
    final color = PrettyPrinter.defaultLevelColors[event.level];
    final emoji = _getEmoji(event.level);
    final time = DateTime.now().toIso8601String();

    final message = '$emoji [$time] ${event.level.name.toUpperCase()}: ${event.message}';

    List<String> lines = [message];

    if (event.error != null) {
      lines.add('Error: ${event.error}');
    }

    if (event.stackTrace != null && event.level.index >= Level.error.index) {
      lines.add('Stack trace:');
      lines.addAll(event.stackTrace.toString().split('\n'));
    }

    return lines;
  }

  String _getEmoji(Level level) {
    switch (level) {
      case Level.debug:
        return '🐛';
      case Level.info:
        return 'ℹ️';
      case Level.warning:
        return '⚠️';
      case Level.error:
        return '❌';
      case Level.fatal:
        return '💀';
      default:
        return '📝';
    }
  }
}

/// Custom log output
class _LogOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    for (final line in event.lines) {
      if (kDebugMode) {
        print(line);
      }
    }
  }
}
