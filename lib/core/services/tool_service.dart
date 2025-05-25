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
      // TEMPORARY: For testing purposes, return mock data
      // TODO: Remove this and restore API call when backend is available
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate network delay

      final mockTools = _generateMockTools(filters);
      final mockPagination = PaginationModel(
        currentPage: filters.page,
        totalPages: 3,
        totalItems: 45,
        itemsPerPage: filters.limit,
      );

      return ToolsResponse(
        tools: mockTools,
        pagination: mockPagination,
      );

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
      // TEMPORARY: For testing purposes, return filtered mock data
      // TODO: Remove this and restore API call when backend is available
      await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay

      final allMockTools = _generateMockTools(const ToolFilters(limit: 100)); // Get all tools
      final searchLower = query.toLowerCase();

      final filteredTools = allMockTools.where((tool) {
        return tool.name.toLowerCase().contains(searchLower) ||
               tool.description.toLowerCase().contains(searchLower) ||
               (tool.serialNumber?.toLowerCase().contains(searchLower) ?? false) ||
               tool.qrCode.toLowerCase().contains(searchLower);
      }).take(10).toList(); // Limit search results to 10

      return filteredTools;

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
      // TEMPORARY: For testing purposes, return mock locations
      // TODO: Remove this and restore API call when backend is available
      await Future.delayed(const Duration(milliseconds: 200)); // Simulate network delay

      return [
        'Hangar A - Tool Crib',
        'Hangar B - Bay 3',
        'Hangar C - Bay 1',
        'Maintenance Shop',
        'Quality Control Lab',
        'Safety Equipment Room',
        'Machine Shop',
        'Propeller Shop',
      ];

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

  /// Generate mock tools for testing
  List<ToolModel> _generateMockTools(ToolFilters filters) {
    final allMockTools = [
      ToolModel(
        id: '1',
        name: 'Digital Torque Wrench',
        description: 'High-precision digital torque wrench with LCD display',
        category: ToolCategory.handTools,
        status: ToolStatus.available,
        location: 'Hangar A - Tool Crib',
        qrCode: 'TW001',
        serialNumber: 'DT-2023-001',
        specifications: ToolSpecifications(
          range: '10-200 Nm',
          accuracy: '±2%',
          weight: '1.2 kg',
        ),
        calibration: ToolCalibration(
          lastDate: DateTime.now().subtract(const Duration(days: 90)),
          nextDate: DateTime.now().add(const Duration(days: 275)),
          isCalibrationRequired: true,
        ),
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
      ),
      ToolModel(
        id: '2',
        name: 'CL415 Engine Hoist',
        description: 'Specialized engine hoist for CL415 aircraft maintenance',
        category: ToolCategory.cl415,
        status: ToolStatus.checkedOut,
        location: 'Hangar B - Bay 3',
        qrCode: 'EH415-001',
        serialNumber: 'CL415-EH-2022-003',
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
      ),
      ToolModel(
        id: '3',
        name: 'Pneumatic Drill',
        description: 'Heavy-duty pneumatic drill for aircraft maintenance',
        category: ToolCategory.powerTools,
        status: ToolStatus.maintenance,
        location: 'Maintenance Shop',
        qrCode: 'PD001',
        serialNumber: 'PD-2023-007',
        createdAt: DateTime.now().subtract(const Duration(days: 150)),
      ),
      ToolModel(
        id: '4',
        name: 'Precision Micrometer Set',
        description: 'Set of precision micrometers 0-25mm, 25-50mm, 50-75mm',
        category: ToolCategory.measuring,
        status: ToolStatus.available,
        location: 'Quality Control Lab',
        qrCode: 'MIC001',
        serialNumber: 'PM-SET-2023-012',
        specifications: ToolSpecifications(
          range: '0-75mm',
          accuracy: '±0.001mm',
        ),
        calibration: ToolCalibration(
          lastDate: DateTime.now().subtract(const Duration(days: 30)),
          nextDate: DateTime.now().add(const Duration(days: 335)),
          isCalibrationRequired: true,
        ),
        createdAt: DateTime.now().subtract(const Duration(days: 300)),
      ),
      ToolModel(
        id: '5',
        name: 'RJ85 Landing Gear Jack',
        description: 'Hydraulic jack specifically designed for RJ85 landing gear',
        category: ToolCategory.rj85,
        status: ToolStatus.inService,
        location: 'Hangar C - Bay 1',
        qrCode: 'LGJ85-001',
        serialNumber: 'RJ85-LGJ-2021-005',
        createdAt: DateTime.now().subtract(const Duration(days: 400)),
      ),
      ToolModel(
        id: '6',
        name: 'Safety Harness',
        description: 'Full body safety harness with shock absorbing lanyard',
        category: ToolCategory.safety,
        status: ToolStatus.available,
        location: 'Safety Equipment Room',
        qrCode: 'SH001',
        serialNumber: 'SH-2023-025',
        createdAt: DateTime.now().subtract(const Duration(days: 100)),
      ),
      ToolModel(
        id: '7',
        name: 'CNC Mill Cutting Tools',
        description: 'Set of carbide cutting tools for CNC milling operations',
        category: ToolCategory.cnc,
        status: ToolStatus.available,
        location: 'Machine Shop',
        qrCode: 'CNC001',
        serialNumber: 'CNC-CT-2023-018',
        createdAt: DateTime.now().subtract(const Duration(days: 80)),
      ),
      ToolModel(
        id: '8',
        name: 'Q400 Propeller Balancer',
        description: 'Dynamic propeller balancing equipment for Q400 aircraft',
        category: ToolCategory.q400,
        status: ToolStatus.outOfService,
        location: 'Propeller Shop',
        qrCode: 'PB400-001',
        serialNumber: 'Q400-PB-2020-002',
        calibration: ToolCalibration(
          lastDate: DateTime.now().subtract(const Duration(days: 400)),
          nextDate: DateTime.now().subtract(const Duration(days: 35)),
          isCalibrationRequired: true,
        ),
        createdAt: DateTime.now().subtract(const Duration(days: 500)),
      ),
    ];

    // Apply filters
    var filteredTools = allMockTools.where((tool) {
      if (filters.search != null && filters.search!.isNotEmpty) {
        final searchLower = filters.search!.toLowerCase();
        return tool.name.toLowerCase().contains(searchLower) ||
               tool.description.toLowerCase().contains(searchLower) ||
               (tool.serialNumber?.toLowerCase().contains(searchLower) ?? false);
      }
      return true;
    }).where((tool) {
      if (filters.category != null) {
        return tool.category == filters.category;
      }
      return true;
    }).where((tool) {
      if (filters.status != null) {
        return tool.status == filters.status;
      }
      return true;
    }).where((tool) {
      if (filters.location != null && filters.location!.isNotEmpty) {
        return tool.location.toLowerCase().contains(filters.location!.toLowerCase());
      }
      return true;
    }).toList();

    // Apply pagination
    final startIndex = (filters.page - 1) * filters.limit;
    final endIndex = startIndex + filters.limit;

    if (startIndex >= filteredTools.length) {
      return [];
    }

    return filteredTools.sublist(
      startIndex,
      endIndex > filteredTools.length ? filteredTools.length : endIndex,
    );
  }
}
