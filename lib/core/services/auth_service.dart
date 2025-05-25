import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../config/app_config.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

final authServiceProvider = StateNotifierProvider<AuthService, AuthState>((ref) {
  return AuthService(ref.read(apiServiceProvider), ref.read(storageServiceProvider));
});

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final UserModel? user;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    UserModel? user,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
    );
  }
}

class AuthService extends StateNotifier<AuthState> {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthService(this._apiService, this._storageService) : super(const AuthState()) {
    _initializeAuth();
  }

  bool get isAuthenticated => state.isAuthenticated;
  UserModel? get currentUser => state.user;

  Future<void> _initializeAuth() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final token = await _storageService.getAuthToken();
      if (token != null && !JwtDecoder.isExpired(token)) {
        final userData = await _storageService.getUserData();
        if (userData != null) {
          state = state.copyWith(
            isAuthenticated: true,
            user: userData,
            isLoading: false,
          );
          return;
        }
      }
      
      // Token is expired or invalid, clear storage
      await _clearAuthData();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      await _clearAuthData();
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to initialize authentication',
      );
    }
  }

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _apiService.post(
        AppConfig.loginEndpoint,
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final token = data['access_token'];
        final refreshToken = data['refresh_token'];
        final userData = UserModel.fromJson(data['user']);

        await _storageService.saveAuthToken(token);
        await _storageService.saveRefreshToken(refreshToken);
        await _storageService.saveUserData(userData);

        state = state.copyWith(
          isAuthenticated: true,
          user: userData,
          isLoading: false,
        );

        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.data['message'] ?? 'Login failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Network error: ${e.toString()}',
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    
    try {
      await _apiService.post(AppConfig.logoutEndpoint);
    } catch (e) {
      // Continue with logout even if API call fails
    }
    
    await _clearAuthData();
    state = const AuthState();
  }

  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _apiService.post(
        AppConfig.refreshTokenEndpoint,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final newToken = response.data['access_token'];
        await _storageService.saveAuthToken(newToken);
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> _clearAuthData() async {
    await _storageService.clearAuthToken();
    await _storageService.clearRefreshToken();
    await _storageService.clearUserData();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
