import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/tool_model.dart';
import '../../../../core/services/tool_service.dart';
import '../../providers/tools_provider.dart';
import '../widgets/tool_card.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/empty_state_widget.dart';

class ToolsListPage extends ConsumerStatefulWidget {
  const ToolsListPage({super.key});

  @override
  ConsumerState<ToolsListPage> createState() => _ToolsListPageState();
}

class _ToolsListPageState extends ConsumerState<ToolsListPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showSearch = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Load initial tools
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final filters = ref.read(filterProvider).filters;
      ref.read(toolsProvider.notifier).loadTools(filters);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more tools when near bottom
      final filters = ref.read(filterProvider).filters;
      ref.read(toolsProvider.notifier).loadMoreTools(filters);
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });

    final currentFilters = ref.read(filterProvider).filters;
    final newFilters = currentFilters.copyWith(
      search: query.isEmpty ? null : query,
      page: 1, // Reset to first page when searching
    );

    ref.read(filterProvider.notifier).updateFilters(newFilters);
    ref.read(toolsProvider.notifier).loadTools(newFilters, refresh: true);
  }

  void _onToolSelected(ToolModel tool) {
    context.push('/tools/detail/${tool.id}');
  }

  void _onFiltersChanged(ToolFilters newFilters) {
    ref.read(filterProvider.notifier).updateFilters(newFilters);
    ref.read(toolsProvider.notifier).loadTools(newFilters, refresh: true);
  }

  void _clearFilters() {
    ref.read(filterProvider.notifier).clearFilters();
    setState(() {
      _searchQuery = '';
    });
    ref.read(toolsProvider.notifier).loadTools(const ToolFilters(), refresh: true);
  }

  Future<void> _refreshTools() async {
    final filters = ref.read(filterProvider).filters;
    await ref.read(toolsProvider.notifier).refreshTools(filters);
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
      if (!_showSearch) {
        _searchQuery = '';
        _onSearchChanged('');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final toolsState = ref.watch(toolsProvider);
    final filterState = ref.watch(filterProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? null
            : const Text('Tools'),
        titleSpacing: _showSearch ? 0 : null,
        flexibleSpace: _showSearch
            ? SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: ToolSearchBar(
                    onSearchChanged: _onSearchChanged,
                    onToolSelected: _onToolSelected,
                    initialValue: _searchQuery,
                  ),
                ),
              )
            : null,
        actions: _showSearch
            ? [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _toggleSearch,
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _toggleSearch,
                ),
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: () => showFilterBottomSheet(
                        context: context,
                        currentFilters: filterState.filters,
                        onFiltersChanged: _onFiltersChanged,
                      ),
                    ),
                    if (filterState.filters.hasActiveFilters)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
      ),
      body: _buildBody(toolsState, filterState),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add tool or navigate to QR scanner
          context.push('/scanner');
        },
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }

  Widget _buildBody(ToolsState toolsState, FilterState filterState) {
    // Error state
    if (toolsState.error != null && toolsState.tools.isEmpty) {
      return _buildErrorState(toolsState.error!);
    }

    // Loading state (initial load)
    if (toolsState.isLoading && toolsState.tools.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Empty state
    if (toolsState.tools.isEmpty) {
      return EmptyStateWidget(
        filters: filterState.filters,
        onClearFilters: _clearFilters,
        onRefresh: _refreshTools,
      );
    }

    // Tools list with pull-to-refresh
    return RefreshIndicator(
      onRefresh: _refreshTools,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Filter summary (if filters are active)
          if (filterState.filters.hasActiveFilters)
            SliverToBoxAdapter(
              child: _buildFilterSummary(filterState.filters),
            ),

          // Tools list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index < toolsState.tools.length) {
                  return ToolCard(tool: toolsState.tools[index]);
                } else if (toolsState.isLoadingMore) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (toolsState.hasReachedEnd) {
                  return _buildEndOfListIndicator();
                }
                return null;
              },
              childCount: toolsState.tools.length +
                  (toolsState.isLoadingMore ? 1 : 0) +
                  (toolsState.hasReachedEnd && toolsState.tools.isNotEmpty ? 1 : 0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Tools',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshTools,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSummary(ToolFilters filters) {
    final theme = Theme.of(context);
    final activeFilters = <String>[];

    if (filters.search != null && filters.search!.isNotEmpty) {
      activeFilters.add('Search: "${filters.search}"');
    }
    if (filters.status != null) {
      activeFilters.add(filters.status!.displayName);
    }
    if (filters.category != null) {
      activeFilters.add(filters.category!.displayName);
    }
    if (filters.location != null && filters.location!.isNotEmpty) {
      activeFilters.add('Location: ${filters.location}');
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_alt,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Filtered by: ${activeFilters.join(', ')}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: _clearFilters,
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Widget _buildEndOfListIndicator() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            'All tools loaded',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
