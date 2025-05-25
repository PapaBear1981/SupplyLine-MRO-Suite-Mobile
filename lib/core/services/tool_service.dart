import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../models/tool_model.dart';
import '../models/checkout_model.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'logging_service.dart';

final toolServiceProvider = Provider<ToolService>((ref) {
  return ToolService(ref.read(apiServiceProvider));
});

class ToolService {
  final ApiService _apiService;

  ToolService(this._apiService);

  /// Get paginated list of tools with optional filters
  Future<ToolListResponse> getTools({
    int page = 1,
    int limit = 20,
    String? search,
    String? category,
    ToolStatus? status,
    String? location,
  }) async {
    try {
      LoggingService.info('Fetching tools list', {
        'page': page,
        'limit': limit,
        'search': search,
        'category': category,
        'status': status?.value,
        'location': location,
      });

      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (status != null) {
        queryParams['status'] = status.value;
      }
      if (location != null && location.isNotEmpty) {
        queryParams['location'] = location;
      }

      final response = await _apiService.get(
        AppConfig.toolsEndpoint,
        queryParameters: queryParams,
      );

      LoggingService.apiResponse('GET', AppConfig.toolsEndpoint, response.statusCode!, response.data);

      if (response.statusCode == 200) {
        return ToolListResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch tools: ${response.statusMessage}');
      }
    } catch (e) {
      LoggingService.error('Failed to fetch tools', e);
      rethrow;
    }
  }

  /// Get detailed information about a specific tool
  Future<ToolModel> getToolById(String toolId) async {
    try {
      LoggingService.info('Fetching tool details', {'toolId': toolId});

      final response = await _apiService.get('${AppConfig.toolsEndpoint}/$toolId');

      LoggingService.apiResponse('GET', '${AppConfig.toolsEndpoint}/$toolId', response.statusCode!, response.data);

      if (response.statusCode == 200) {
        return ToolModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to fetch tool details: ${response.statusMessage}');
      }
    } catch (e) {
      LoggingService.error('Failed to fetch tool details', e);
      rethrow;
    }
  }

  /// Search for tools by QR code
  Future<ToolModel?> getToolByQrCode(String qrCode) async {
    try {
      LoggingService.info('Searching tool by QR code', {'qrCode': qrCode});

      final response = await _apiService.get(
        '${AppConfig.toolsEndpoint}/qr/$qrCode',
      );

      LoggingService.apiResponse('GET', '${AppConfig.toolsEndpoint}/qr/$qrCode', response.statusCode!, response.data);

      if (response.statusCode == 200) {
        return ToolModel.fromJson(response.data['data']);
      } else if (response.statusCode == 404) {
        return null; // Tool not found
      } else {
        throw Exception('Failed to search tool by QR code: ${response.statusMessage}');
      }
    } catch (e) {
      LoggingService.error('Failed to search tool by QR code', e);
      rethrow;
    }
  }

  /// Checkout a tool to a user
  Future<CheckoutResponse> checkoutTool(CheckoutRequest request) async {
    try {
      LoggingService.info('Checking out tool', {
        'toolId': request.toolId,
        'userId': request.userId,
        'expectedReturnDate': request.expectedReturnDate.toIso8601String(),
      });

      final response = await _apiService.post(
        '${AppConfig.toolsEndpoint}/checkout',
        data: request.toJson(),
      );

      LoggingService.apiResponse('POST', '${AppConfig.toolsEndpoint}/checkout', response.statusCode!, response.data);

      final checkoutResponse = CheckoutResponse.fromJson(response.data);

      if (checkoutResponse.success) {
        LoggingService.userAction('tool_checkout', {
          'toolId': request.toolId,
          'userId': request.userId,
        });
      }

      return checkoutResponse;
    } catch (e) {
      LoggingService.error('Failed to checkout tool', e);
      rethrow;
    }
  }

  /// Return a tool
  Future<ReturnResponse> returnTool(ReturnRequest request) async {
    try {
      LoggingService.info('Returning tool', {
        'toolId': request.toolId,
        'checkoutId': request.checkoutId,
        'condition': request.condition.value,
      });

      final response = await _apiService.post(
        '${AppConfig.toolsEndpoint}/return',
        data: request.toJson(),
      );

      LoggingService.apiResponse('POST', '${AppConfig.toolsEndpoint}/return', response.statusCode!, response.data);

      final returnResponse = ReturnResponse.fromJson(response.data);

      if (returnResponse.success) {
        LoggingService.userAction('tool_return', {
          'toolId': request.toolId,
          'condition': request.condition.value,
        });
      }

      return returnResponse;
    } catch (e) {
      LoggingService.error('Failed to return tool', e);
      rethrow;
    }
  }

  /// Get list of users for checkout assignment
  Future<List<UserModel>> getUsers({String? search}) async {
    try {
      LoggingService.info('Fetching users list', {'search': search});

      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _apiService.get(
        '/api/v1/users',
        queryParameters: queryParams,
      );

      LoggingService.apiResponse('GET', '/api/v1/users', response.statusCode!, response.data);

      if (response.statusCode == 200) {
        final List<dynamic> usersData = response.data['data']['users'];
        return usersData.map((userData) => UserModel.fromJson(userData)).toList();
      } else {
        throw Exception('Failed to fetch users: ${response.statusMessage}');
      }
    } catch (e) {
      LoggingService.error('Failed to fetch users', e);
      rethrow;
    }
  }

  /// Get tool categories for filtering
  Future<List<String>> getToolCategories() async {
    try {
      LoggingService.info('Fetching tool categories');

      final response = await _apiService.get('${AppConfig.toolsEndpoint}/categories');

      LoggingService.apiResponse('GET', '${AppConfig.toolsEndpoint}/categories', response.statusCode!, response.data);

      if (response.statusCode == 200) {
        final List<dynamic> categoriesData = response.data['data'];
        return categoriesData.cast<String>();
      } else {
        throw Exception('Failed to fetch tool categories: ${response.statusMessage}');
      }
    } catch (e) {
      LoggingService.error('Failed to fetch tool categories', e);
      rethrow;
    }
  }
}

class ToolListResponse {
  final List<ToolModel> tools;
  final PaginationInfo pagination;

  ToolListResponse({
    required this.tools,
    required this.pagination,
  });

  factory ToolListResponse.fromJson(Map<String, dynamic> json) {
    return ToolListResponse(
      tools: (json['data']['tools'] as List<dynamic>)
          .map((toolData) => ToolModel.fromJson(toolData))
          .toList(),
      pagination: PaginationInfo.fromJson(json['data']['pagination']),
    );
  }
}

class PaginationInfo {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;

  PaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['current_page'] as int,
      totalPages: json['total_pages'] as int,
      totalItems: json['total_items'] as int,
      itemsPerPage: json['items_per_page'] as int,
    );
  }
}
