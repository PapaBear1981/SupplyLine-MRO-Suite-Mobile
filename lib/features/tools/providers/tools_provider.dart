import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/tool_model.dart';
import '../../../core/services/tool_service.dart';

// Tools list state
class ToolsState {
  final List<ToolModel> tools;
  final PaginationModel? pagination;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final bool hasReachedEnd;

  const ToolsState({
    this.tools = const [],
    this.pagination,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.hasReachedEnd = false,
  });

  ToolsState copyWith({
    List<ToolModel>? tools,
    PaginationModel? pagination,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool? hasReachedEnd,
  }) {
    return ToolsState(
      tools: tools ?? this.tools,
      pagination: pagination ?? this.pagination,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
    );
  }
}

// Filter state
class FilterState {
  final ToolFilters filters;
  final List<String> availableLocations;
  final bool isLoadingLocations;

  const FilterState({
    this.filters = const ToolFilters(),
    this.availableLocations = const [],
    this.isLoadingLocations = false,
  });

  FilterState copyWith({
    ToolFilters? filters,
    List<String>? availableLocations,
    bool? isLoadingLocations,
  }) {
    return FilterState(
      filters: filters ?? this.filters,
      availableLocations: availableLocations ?? this.availableLocations,
      isLoadingLocations: isLoadingLocations ?? this.isLoadingLocations,
    );
  }
}

// Tools provider
final toolsProvider = StateNotifierProvider<ToolsNotifier, ToolsState>((ref) {
  return ToolsNotifier(ref.read(toolServiceProvider));
});

class ToolsNotifier extends StateNotifier<ToolsState> {
  final ToolService _toolService;

  ToolsNotifier(this._toolService) : super(const ToolsState());

  /// Load tools with current filters
  Future<void> loadTools(ToolFilters filters, {bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        tools: [],
        hasReachedEnd: false,
      );
    } else if (state.isLoading || state.isLoadingMore) {
      return; // Prevent multiple simultaneous requests
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final response = await _toolService.getTools(filters);
      
      state = state.copyWith(
        tools: response.tools,
        pagination: response.pagination,
        isLoading: false,
        hasReachedEnd: response.tools.length < filters.limit,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load more tools (pagination)
  Future<void> loadMoreTools(ToolFilters filters) async {
    if (state.isLoadingMore || state.hasReachedEnd || state.pagination == null) {
      return;
    }

    state = state.copyWith(isLoadingMore: true, error: null);

    try {
      final nextPage = state.pagination!.currentPage + 1;
      final nextFilters = filters.copyWith(page: nextPage);
      final response = await _toolService.getTools(nextFilters);
      
      final allTools = [...state.tools, ...response.tools];
      
      state = state.copyWith(
        tools: allTools,
        pagination: response.pagination,
        isLoadingMore: false,
        hasReachedEnd: response.tools.length < filters.limit,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh tools list
  Future<void> refreshTools(ToolFilters filters) async {
    await _toolService.clearCache();
    await loadTools(filters, refresh: true);
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Filter provider
final filterProvider = StateNotifierProvider<FilterNotifier, FilterState>((ref) {
  return FilterNotifier(ref.read(toolServiceProvider));
});

class FilterNotifier extends StateNotifier<FilterState> {
  final ToolService _toolService;

  FilterNotifier(this._toolService) : super(const FilterState()) {
    _loadLocations();
  }

  /// Update filters
  void updateFilters(ToolFilters newFilters) {
    state = state.copyWith(filters: newFilters);
  }

  /// Clear all filters
  void clearFilters() {
    state = state.copyWith(filters: const ToolFilters());
  }

  /// Load available locations
  Future<void> _loadLocations() async {
    state = state.copyWith(isLoadingLocations: true);
    
    try {
      final locations = await _toolService.getLocations();
      state = state.copyWith(
        availableLocations: locations,
        isLoadingLocations: false,
      );
    } catch (e) {
      state = state.copyWith(isLoadingLocations: false);
      // Silently fail for locations - not critical
    }
  }

  /// Refresh locations
  Future<void> refreshLocations() async {
    await _loadLocations();
  }
}

// Search provider for real-time search
final searchProvider = StateNotifierProvider<SearchNotifier, AsyncValue<List<ToolModel>>>((ref) {
  return SearchNotifier(ref.read(toolServiceProvider));
});

class SearchNotifier extends StateNotifier<AsyncValue<List<ToolModel>>> {
  final ToolService _toolService;

  SearchNotifier(this._toolService) : super(const AsyncValue.data([]));

  /// Search tools
  Future<void> searchTools(String query) async {
    if (query.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();

    try {
      final results = await _toolService.searchTools(query);
      state = AsyncValue.data(results);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Clear search results
  void clearSearch() {
    state = const AsyncValue.data([]);
  }
}

// Individual tool provider
final toolProvider = FutureProvider.family<ToolModel, String>((ref, toolId) async {
  final toolService = ref.read(toolServiceProvider);
  return await toolService.getToolById(toolId);
});
