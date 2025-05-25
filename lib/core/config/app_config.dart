class AppConfig {
  // API Configuration - Primary backend communication
  static const String baseUrl = 'http://localhost:5000'; // Development URL
  static const String productionUrl = 'https://your-production-server.com'; // Production URL
  static const String apiVersion = 'v1';
  static const String apiBaseUrl = '$baseUrl/api/$apiVersion';

  // Data Strategy Configuration
  static const bool preferRemoteData = true; // Always try remote first
  static const Duration offlineTimeout = Duration(seconds: 10); // Timeout before using offline data
  static const Duration syncRetryInterval = Duration(minutes: 5); // Retry sync interval

  // Authentication endpoints
  static const String loginEndpoint = '/auth/login';
  static const String logoutEndpoint = '/auth/logout';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String userProfileEndpoint = '/auth/profile';

  // Tools endpoints
  static const String toolsEndpoint = '/tools';
  static const String toolCheckoutEndpoint = '/tools/checkout';
  static const String toolReturnEndpoint = '/tools/return';
  static const String toolSearchEndpoint = '/tools/search';

  // Users endpoints
  static const String usersEndpoint = '/users';
  static const String userRegistrationEndpoint = '/users/register';

  // Reports endpoints
  static const String reportsEndpoint = '/reports';
  static const String toolUsageReportEndpoint = '/reports/tool-usage';
  static const String userActivityReportEndpoint = '/reports/user-activity';

  // Chemicals endpoints
  static const String chemicalsEndpoint = '/chemicals';
  static const String chemicalAnalyticsEndpoint = '/chemicals/analytics';

  // Calibration endpoints
  static const String calibrationEndpoint = '/calibration';
  static const String calibrationScheduleEndpoint = '/calibration/schedule';

  // App Configuration
  static const String appName = 'SupplyLine MRO Suite';
  static const String appVersion = '1.0.0';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String settingsKey = 'app_settings';

  // QR Code Configuration
  static const String qrCodePrefix = 'SLMRO_';
  static const int qrCodeLength = 10;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Cache Configuration
  static const Duration cacheExpiration = Duration(hours: 1);
  static const int maxCacheSize = 100; // Number of items
}
