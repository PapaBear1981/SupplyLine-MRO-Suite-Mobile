import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tool_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

final toolServiceProvider = Provider<ToolService>((ref) {
  return ToolService(
    ref.read(apiServiceProvider),
    ref.read(storageServiceProvider),
  );
});

class ToolFilters {
  final String? search;
  final ToolCategory? category;
  final ToolStatus? status;
  final String? location;
  final int page;
  final int limit;

  const ToolFilters({
    this.search,
    this.category,
    this.status,
    this.location,
    this.page = 1,
    this.limit = 20,
  });

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (search != null && search!.isNotEmpty) {
      params['search'] = search;
    }
    if (category != null) {
      params['category'] = category!.value;
    }
    if (status != null) {
      params['status'] = status!.value;
    }
    if (location != null && location!.isNotEmpty) {
      params['location'] = location;
    }

    return params;
  }

  ToolFilters copyWith({
    String? search,
    ToolCategory? category,
    ToolStatus? status,
    String? location,
    int? page,
    int? limit,
  }) {
    return ToolFilters(
      search: search ?? this.search,
      category: category ?? this.category,
      status: status ?? this.status,
      location: location ?? this.location,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }

  bool get hasActiveFilters {
    return (search != null && search!.isNotEmpty) ||
           category != null ||
           status != null ||
           (location != null && location!.isNotEmpty);
  }
}

class ToolService {
  final ApiService _apiService;
  final StorageService _storageService;
  static const String _cacheKeyPrefix = 'tools_cache_';
  static const Duration _cacheExpiry = Duration(minutes: 5);

  ToolService(this._apiService, this._storageService);

  /// Get tools with pagination and filtering
  Future<ToolsResponse> getTools(ToolFilters filters) async {
    try {
      // Check cache first
      final cacheKey = '${_cacheKeyPrefix}${_generateCacheKey(filters)}';
      final cachedData = await _getCachedData(cacheKey);
      if (cachedData != null) {
        return ToolsResponse.fromJson(cachedData);
      }

      // Make API request
      final response = await _apiService.get(
        '/tools',
        queryParameters: filters.toQueryParameters(),
      );

      if (response.data['success'] == true) {
        final toolsResponse = ToolsResponse.fromJson(response.data);
        
        // Cache the response
        await _cacheData(cacheKey, response.data);
        
        return toolsResponse;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch tools');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Search tools with specific query
  Future<List<ToolModel>> searchTools(String query) async {
    try {
      final response = await _apiService.get(
        '/tools/search',
        queryParameters: {'q': query},
      );

      if (response.data['success'] == true) {
        final results = response.data['data']['results'] as List;
        return results
            .map((item) => ToolModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(response.data['message'] ?? 'Search failed');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get specific tool by ID
  Future<ToolModel> getToolById(String toolId) async {
    try {
      // Check cache first
      final cacheKey = '${_cacheKeyPrefix}tool_$toolId';
      final cachedData = await _getCachedData(cacheKey);
      if (cachedData != null) {
        return ToolModel.fromJson(cachedData['data']);
      }

      final response = await _apiService.get('/tools/$toolId');

      if (response.data['success'] == true) {
        final tool = ToolModel.fromJson(response.data['data']);
        
        // Cache the tool
        await _cacheData(cacheKey, response.data);
        
        return tool;
      } else {
        throw Exception(response.data['message'] ?? 'Tool not found');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get available locations for filtering
  Future<List<String>> getLocations() async {
    try {
      final response = await _apiService.get('/tools/locations');
      
      if (response.data['success'] == true) {
        return List<String>.from(response.data['data']['locations']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch locations');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Clear tools cache
  Future<void> clearCache() async {
    // This would require implementing a method to clear cache by prefix
    // For now, we'll implement a simple approach
    try {
      await _storageService.clearSetting('tools_cache_timestamp');
    } catch (e) {
      // Ignore cache clear errors
    }
  }

  /// Generate cache key from filters
  String _generateCacheKey(ToolFilters filters) {
    final parts = <String>[
      'page_${filters.page}',
      'limit_${filters.limit}',
    ];
    
    if (filters.search != null) parts.add('search_${filters.search}');
    if (filters.category != null) parts.add('category_${filters.category!.value}');
    if (filters.status != null) parts.add('status_${filters.status!.value}');
    if (filters.location != null) parts.add('location_${filters.location}');
    
    return parts.join('_');
  }

  /// Get cached data if not expired
  Future<Map<String, dynamic>?> _getCachedData(String key) async {
    try {
      final cachedItem = await _storageService.getCachedData(key);
      if (cachedItem != null) {
        final timestamp = DateTime.fromMillisecondsSinceEpoch(cachedItem['timestamp']);
        if (DateTime.now().difference(timestamp) < _cacheExpiry) {
          return cachedItem['data'];
        }
      }
    } catch (e) {
      // Ignore cache errors
    }
    return null;
  }

  /// Cache data with timestamp
  Future<void> _cacheData(String key, Map<String, dynamic> data) async {
    try {
      await _storageService.cacheData(key, data);
    } catch (e) {
      // Ignore cache errors
    }
  }

  /// Handle Dio exceptions and convert to user-friendly messages
  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout. Please check your internet connection.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          return Exception('Authentication failed. Please log in again.');
        } else if (statusCode == 403) {
          return Exception('Access denied. You don\'t have permission to view tools.');
        } else if (statusCode == 404) {
          return Exception('Tools not found.');
        } else if (statusCode == 500) {
          return Exception('Server error. Please try again later.');
        }
        return Exception('Request failed with status $statusCode');
      case DioExceptionType.cancel:
        return Exception('Request was cancelled');
      case DioExceptionType.connectionError:
        return Exception('No internet connection. Please check your network.');
      default:
        return Exception('Network error: ${e.message}');
    }
  }
}
