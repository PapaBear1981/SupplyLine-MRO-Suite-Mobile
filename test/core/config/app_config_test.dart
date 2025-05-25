import 'package:flutter_test/flutter_test.dart';
import 'package:supplyline_mro_suite_mobile/core/config/app_config.dart';

void main() {
  group('AppConfig Tests', () {
    setUp(() {
      // Reset to development environment before each test
      AppConfig.setEnvironment(Environment.development);
    });

    group('Environment Configuration', () {
      test('should default to development environment', () {
        expect(AppConfig.environment, Environment.development);
      });

      test('should change environment when set', () {
        AppConfig.setEnvironment(Environment.production);
        expect(AppConfig.environment, Environment.production);
        
        AppConfig.setEnvironment(Environment.staging);
        expect(AppConfig.environment, Environment.staging);
      });

      test('should return correct base URL for each environment', () {
        AppConfig.setEnvironment(Environment.development);
        expect(AppConfig.baseUrl, 'http://localhost:5000');

        AppConfig.setEnvironment(Environment.staging);
        expect(AppConfig.baseUrl, 'https://staging-api.supplyline-mro.com');

        AppConfig.setEnvironment(Environment.production);
        expect(AppConfig.baseUrl, 'https://api.supplyline-mro.com');
      });

      test('should return correct API base URL', () {
        AppConfig.setEnvironment(Environment.development);
        expect(AppConfig.apiBaseUrl, 'http://localhost:5000/api/v1');

        AppConfig.setEnvironment(Environment.production);
        expect(AppConfig.apiBaseUrl, 'https://api.supplyline-mro.com/api/v1');
      });
    });

    group('Environment-specific Settings', () {
      test('should enable debug mode only in development', () {
        AppConfig.setEnvironment(Environment.development);
        expect(AppConfig.isDebugMode, true);

        AppConfig.setEnvironment(Environment.staging);
        expect(AppConfig.isDebugMode, false);

        AppConfig.setEnvironment(Environment.production);
        expect(AppConfig.isDebugMode, false);
      });

      test('should enable logging in development and staging', () {
        AppConfig.setEnvironment(Environment.development);
        expect(AppConfig.enableLogging, true);

        AppConfig.setEnvironment(Environment.staging);
        expect(AppConfig.enableLogging, true);

        AppConfig.setEnvironment(Environment.production);
        expect(AppConfig.enableLogging, false);
      });

      test('should enable crash reporting only in production', () {
        AppConfig.setEnvironment(Environment.development);
        expect(AppConfig.enableCrashReporting, false);

        AppConfig.setEnvironment(Environment.staging);
        expect(AppConfig.enableCrashReporting, false);

        AppConfig.setEnvironment(Environment.production);
        expect(AppConfig.enableCrashReporting, true);
      });
    });

    group('API Endpoints', () {
      test('should have correct authentication endpoints', () {
        expect(AppConfig.loginEndpoint, '/auth/login');
        expect(AppConfig.logoutEndpoint, '/auth/logout');
        expect(AppConfig.refreshTokenEndpoint, '/auth/refresh');
        expect(AppConfig.userProfileEndpoint, '/auth/profile');
      });

      test('should have correct tools endpoints', () {
        expect(AppConfig.toolsEndpoint, '/tools');
        expect(AppConfig.toolCheckoutEndpoint, '/tools/checkout');
        expect(AppConfig.toolReturnEndpoint, '/tools/return');
        expect(AppConfig.toolSearchEndpoint, '/tools/search');
      });

      test('should have correct reports endpoints', () {
        expect(AppConfig.reportsEndpoint, '/reports');
        expect(AppConfig.toolUsageReportEndpoint, '/reports/tool-usage');
        expect(AppConfig.userActivityReportEndpoint, '/reports/user-activity');
      });
    });

    group('App Configuration', () {
      test('should have correct app metadata', () {
        expect(AppConfig.appName, 'SupplyLine MRO Suite');
        expect(AppConfig.appVersion, '1.0.0');
      });

      test('should have correct timeout configurations', () {
        expect(AppConfig.apiTimeout, const Duration(seconds: 30));
        expect(AppConfig.offlineTimeout, const Duration(seconds: 10));
        expect(AppConfig.tokenRefreshThreshold, const Duration(minutes: 5));
        expect(AppConfig.syncRetryInterval, const Duration(minutes: 5));
      });

      test('should have correct storage keys', () {
        expect(AppConfig.authTokenKey, 'auth_token');
        expect(AppConfig.refreshTokenKey, 'refresh_token');
        expect(AppConfig.userDataKey, 'user_data');
        expect(AppConfig.settingsKey, 'app_settings');
      });

      test('should have correct QR code configuration', () {
        expect(AppConfig.qrCodePrefix, 'SLMRO_');
        expect(AppConfig.qrCodeLength, 10);
      });

      test('should have correct pagination settings', () {
        expect(AppConfig.defaultPageSize, 20);
        expect(AppConfig.maxPageSize, 100);
      });

      test('should have correct cache configuration', () {
        expect(AppConfig.cacheExpiration, const Duration(hours: 1));
        expect(AppConfig.maxCacheSize, 100);
      });
    });

    group('Data Strategy', () {
      test('should prefer remote data by default', () {
        expect(AppConfig.preferRemoteData, true);
      });
    });
  });
}
