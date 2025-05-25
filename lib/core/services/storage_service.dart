import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../config/app_config.dart';
import '../models/user_model.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

class StorageService {
  static late Box _authBox;
  static late Box _settingsBox;
  static late Box _cacheBox;

  static Future<void> init() async {
    _authBox = await Hive.openBox('auth');
    _settingsBox = await Hive.openBox('settings');
    _cacheBox = await Hive.openBox('cache');
  }

  // Authentication Token Management
  Future<void> saveAuthToken(String token) async {
    await _authBox.put(AppConfig.authTokenKey, token);
  }

  Future<String?> getAuthToken() async {
    return _authBox.get(AppConfig.authTokenKey);
  }

  Future<void> clearAuthToken() async {
    await _authBox.delete(AppConfig.authTokenKey);
  }

  // Refresh Token Management
  Future<void> saveRefreshToken(String token) async {
    await _authBox.put(AppConfig.refreshTokenKey, token);
  }

  Future<String?> getRefreshToken() async {
    return _authBox.get(AppConfig.refreshTokenKey);
  }

  Future<void> clearRefreshToken() async {
    await _authBox.delete(AppConfig.refreshTokenKey);
  }

  // User Data Management
  Future<void> saveUserData(UserModel user) async {
    await _authBox.put(AppConfig.userDataKey, jsonEncode(user.toJson()));
  }

  Future<UserModel?> getUserData() async {
    final userData = _authBox.get(AppConfig.userDataKey);
    if (userData != null) {
      return UserModel.fromJson(jsonDecode(userData));
    }
    return null;
  }

  Future<void> clearUserData() async {
    await _authBox.delete(AppConfig.userDataKey);
  }

  // Settings Management
  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  Future<T?> getSetting<T>(String key) async {
    return _settingsBox.get(key) as T?;
  }

  Future<void> clearSetting(String key) async {
    await _settingsBox.delete(key);
  }

  Future<void> clearAllSettings() async {
    await _settingsBox.clear();
  }

  // Cache Management
  Future<void> cacheData(String key, Map<String, dynamic> data) async {
    final cacheItem = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await _cacheBox.put(key, jsonEncode(cacheItem));
  }

  Future<Map<String, dynamic>?> getCachedData(String key) async {
    final cachedItem = _cacheBox.get(key);
    if (cachedItem != null) {
      final decoded = jsonDecode(cachedItem);
      final timestamp = DateTime.fromMillisecondsSinceEpoch(decoded['timestamp']);
      
      // Check if cache is still valid
      if (DateTime.now().difference(timestamp) < AppConfig.cacheExpiration) {
        return decoded['data'] as Map<String, dynamic>;
      } else {
        // Cache expired, remove it
        await _cacheBox.delete(key);
      }
    }
    return null;
  }

  Future<void> clearCache() async {
    await _cacheBox.clear();
  }

  Future<void> clearExpiredCache() async {
    final keys = _cacheBox.keys.toList();
    for (final key in keys) {
      final cachedItem = _cacheBox.get(key);
      if (cachedItem != null) {
        try {
          final decoded = jsonDecode(cachedItem);
          final timestamp = DateTime.fromMillisecondsSinceEpoch(decoded['timestamp']);
          
          if (DateTime.now().difference(timestamp) >= AppConfig.cacheExpiration) {
            await _cacheBox.delete(key);
          }
        } catch (e) {
          // Invalid cache item, remove it
          await _cacheBox.delete(key);
        }
      }
    }
  }

  // General utility methods
  Future<void> clearAllData() async {
    await _authBox.clear();
    await _settingsBox.clear();
    await _cacheBox.clear();
  }

  Future<bool> hasKey(String key, {String box = 'auth'}) async {
    switch (box) {
      case 'auth':
        return _authBox.containsKey(key);
      case 'settings':
        return _settingsBox.containsKey(key);
      case 'cache':
        return _cacheBox.containsKey(key);
      default:
        return false;
    }
  }
}
