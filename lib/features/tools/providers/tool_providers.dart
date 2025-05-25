import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/tool_model.dart';
import '../../../core/models/checkout_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/tool_service.dart';

// Tool detail provider
final toolDetailProvider = FutureProvider.family<ToolModel, String>((ref, toolId) async {
  final toolService = ref.read(toolServiceProvider);
  return await toolService.getToolById(toolId);
});

// Tools list provider with filters
final toolsListProvider = StateNotifierProvider<ToolsListNotifier, ToolsListState>((ref) {
  return ToolsListNotifier(ref.read(toolServiceProvider));
});

// Tool checkout provider
final toolCheckoutProvider = StateNotifierProvider<ToolCheckoutNotifier, ToolCheckoutState>((ref) {
  return ToolCheckoutNotifier(ref.read(toolServiceProvider));
});

// Tool return provider
final toolReturnProvider = StateNotifierProvider<ToolReturnNotifier, ToolReturnState>((ref) {
  return ToolReturnNotifier(ref.read(toolServiceProvider));
});

// Users list provider for checkout
final usersListProvider = FutureProvider.family<List<UserModel>, String?>((ref, search) async {
  final toolService = ref.read(toolServiceProvider);
  return await toolService.getUsers(search: search);
});

// Tool categories provider
final toolCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final toolService = ref.read(toolServiceProvider);
  return await toolService.getToolCategories();
});

// QR Code scanner provider
final qrScannerProvider = StateNotifierProvider<QrScannerNotifier, QrScannerState>((ref) {
  return QrScannerNotifier(ref.read(toolServiceProvider));
});

// Tools List State and Notifier
class ToolsListState {
  final List<ToolModel> tools;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final bool hasMore;
  final String? searchQuery;
  final String? selectedCategory;
  final ToolStatus? selectedStatus;

  const ToolsListState({
    this.tools = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
    this.searchQuery,
    this.selectedCategory,
    this.selectedStatus,
  });

  ToolsListState copyWith({
    List<ToolModel>? tools,
    bool? isLoading,
    String? error,
    int? currentPage,
    bool? hasMore,
    String? searchQuery,
    String? selectedCategory,
    ToolStatus? selectedStatus,
  }) {
    return ToolsListState(
      tools: tools ?? this.tools,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedStatus: selectedStatus ?? this.selectedStatus,
    );
  }
}

class ToolsListNotifier extends StateNotifier<ToolsListState> {
  final ToolService _toolService;

  ToolsListNotifier(this._toolService) : super(const ToolsListState()) {
    loadTools();
  }

  Future<void> loadTools({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        tools: [],
        currentPage: 1,
        hasMore: true,
        error: null,
      );
    }

    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _toolService.getTools(
        page: state.currentPage,
        search: state.searchQuery,
        category: state.selectedCategory,
        status: state.selectedStatus,
      );

      final newTools = refresh ? response.tools : [...state.tools, ...response.tools];

      state = state.copyWith(
        tools: newTools,
        isLoading: false,
        currentPage: state.currentPage + 1,
        hasMore: response.pagination.currentPage < response.pagination.totalPages,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void setSearchQuery(String? query) {
    state = state.copyWith(searchQuery: query);
    loadTools(refresh: true);
  }

  void setCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
    loadTools(refresh: true);
  }

  void setStatus(ToolStatus? status) {
    state = state.copyWith(selectedStatus: status);
    loadTools(refresh: true);
  }

  void clearFilters() {
    state = state.copyWith(
      searchQuery: null,
      selectedCategory: null,
      selectedStatus: null,
    );
    loadTools(refresh: true);
  }
}

// Tool Checkout State and Notifier
class ToolCheckoutState {
  final bool isLoading;
  final String? error;
  final String? successMessage;
  final CheckoutResponse? lastCheckout;

  const ToolCheckoutState({
    this.isLoading = false,
    this.error,
    this.successMessage,
    this.lastCheckout,
  });

  ToolCheckoutState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
    CheckoutResponse? lastCheckout,
  }) {
    return ToolCheckoutState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
      lastCheckout: lastCheckout ?? this.lastCheckout,
    );
  }
}

class ToolCheckoutNotifier extends StateNotifier<ToolCheckoutState> {
  final ToolService _toolService;

  ToolCheckoutNotifier(this._toolService) : super(const ToolCheckoutState());

  Future<bool> checkoutTool(CheckoutRequest request) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);

    try {
      final response = await _toolService.checkoutTool(request);

      if (response.success) {
        state = state.copyWith(
          isLoading: false,
          successMessage: response.message,
          lastCheckout: response,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  void clearState() {
    state = const ToolCheckoutState();
  }
}

// Tool Return State and Notifier
class ToolReturnState {
  final bool isLoading;
  final String? error;
  final String? successMessage;
  final ReturnResponse? lastReturn;

  const ToolReturnState({
    this.isLoading = false,
    this.error,
    this.successMessage,
    this.lastReturn,
  });

  ToolReturnState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
    ReturnResponse? lastReturn,
  }) {
    return ToolReturnState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
      lastReturn: lastReturn ?? this.lastReturn,
    );
  }
}

class ToolReturnNotifier extends StateNotifier<ToolReturnState> {
  final ToolService _toolService;

  ToolReturnNotifier(this._toolService) : super(const ToolReturnState());

  Future<bool> returnTool(ReturnRequest request) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);

    try {
      final response = await _toolService.returnTool(request);

      if (response.success) {
        state = state.copyWith(
          isLoading: false,
          successMessage: response.message,
          lastReturn: response,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  void clearState() {
    state = const ToolReturnState();
  }
}

// QR Scanner State and Notifier
class QrScannerState {
  final bool isScanning;
  final bool isLoading;
  final String? error;
  final ToolModel? scannedTool;

  const QrScannerState({
    this.isScanning = false,
    this.isLoading = false,
    this.error,
    this.scannedTool,
  });

  QrScannerState copyWith({
    bool? isScanning,
    bool? isLoading,
    String? error,
    ToolModel? scannedTool,
  }) {
    return QrScannerState(
      isScanning: isScanning ?? this.isScanning,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      scannedTool: scannedTool ?? this.scannedTool,
    );
  }
}

class QrScannerNotifier extends StateNotifier<QrScannerState> {
  final ToolService _toolService;

  QrScannerNotifier(this._toolService) : super(const QrScannerState());

  Future<void> scanQrCode(String qrCode) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final tool = await _toolService.getToolByQrCode(qrCode);

      if (tool != null) {
        state = state.copyWith(
          isLoading: false,
          scannedTool: tool,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Tool not found for QR code: $qrCode',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void startScanning() {
    state = state.copyWith(isScanning: true, error: null);
  }

  void stopScanning() {
    state = state.copyWith(isScanning: false);
  }

  void clearState() {
    state = const QrScannerState();
  }
}
