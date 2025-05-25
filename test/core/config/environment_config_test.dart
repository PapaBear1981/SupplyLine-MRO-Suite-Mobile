import 'package:flutter_test/flutter_test.dart';
import 'package:supplyline_mro_suite_mobile/core/config/app_config.dart';
import 'package:supplyline_mro_suite_mobile/core/config/environment_config.dart';

void main() {
  group('EnvironmentConfig Tests', () {
    setUp(() {
      // Reset to development environment before each test
      AppConfig.setEnvironment(Environment.development);
    });

    group('Environment Detection', () {
      test('should return correct current environment string', () {
        AppConfig.setEnvironment(Environment.development);
        expect(EnvironmentConfig.currentEnvironment, 'development');

        AppConfig.setEnvironment(Environment.staging);
        expect(EnvironmentConfig.currentEnvironment, 'staging');

        AppConfig.setEnvironment(Environment.production);
        expect(EnvironmentConfig.currentEnvironment, 'production');
      });

      test('should correctly identify development environment', () {
        AppConfig.setEnvironment(Environment.development);
        expect(EnvironmentConfig.isDevelopment, true);
        expect(EnvironmentConfig.isStaging, false);
        expect(EnvironmentConfig.isProduction, false);
      });

      test('should correctly identify staging environment', () {
        AppConfig.setEnvironment(Environment.staging);
        expect(EnvironmentConfig.isDevelopment, false);
        expect(EnvironmentConfig.isStaging, true);
        expect(EnvironmentConfig.isProduction, false);
      });

      test('should correctly identify production environment', () {
        AppConfig.setEnvironment(Environment.production);
        expect(EnvironmentConfig.isDevelopment, false);
        expect(EnvironmentConfig.isStaging, false);
        expect(EnvironmentConfig.isProduction, true);
      });
    });

    group('Environment Configuration', () {
      test('should return correct environment config for development', () {
        AppConfig.setEnvironment(Environment.development);
        final config = EnvironmentConfig.environmentConfig;

        expect(config['environment'], 'development');
        expect(config['baseUrl'], 'http://localhost:5000');
        expect(config['apiBaseUrl'], 'http://localhost:5000/api/v1');
        expect(config['debugMode'], true);
        expect(config['enableLogging'], true);
        expect(config['enableCrashReporting'], false);
        expect(config['preferRemoteData'], true);
        expect(config['offlineTimeout'], 10);
        expect(config['apiTimeout'], 30);
      });

      test('should return correct environment config for staging', () {
        AppConfig.setEnvironment(Environment.staging);
        final config = EnvironmentConfig.environmentConfig;

        expect(config['environment'], 'staging');
        expect(config['baseUrl'], 'https://staging-api.supplyline-mro.com');
        expect(config['apiBaseUrl'], 'https://staging-api.supplyline-mro.com/api/v1');
        expect(config['debugMode'], false);
        expect(config['enableLogging'], true);
        expect(config['enableCrashReporting'], false);
      });

      test('should return correct environment config for production', () {
        AppConfig.setEnvironment(Environment.production);
        final config = EnvironmentConfig.environmentConfig;

        expect(config['environment'], 'production');
        expect(config['baseUrl'], 'https://api.supplyline-mro.com');
        expect(config['apiBaseUrl'], 'https://api.supplyline-mro.com/api/v1');
        expect(config['debugMode'], false);
        expect(config['enableLogging'], false);
        expect(config['enableCrashReporting'], true);
      });
    });
  });
}
