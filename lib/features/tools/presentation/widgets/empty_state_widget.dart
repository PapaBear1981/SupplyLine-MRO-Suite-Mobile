import 'package:flutter/material.dart';

import '../../../../core/services/tool_service.dart';

class EmptyStateWidget extends StatelessWidget {
  final ToolFilters filters;
  final VoidCallback? onClearFilters;
  final VoidCallback? onRefresh;

  const EmptyStateWidget({
    super.key,
    required this.filters,
    this.onClearFilters,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasFilters = filters.hasActiveFilters;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasFilters ? Icons.search_off : Icons.build_outlined,
                size: 64,
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              hasFilters ? 'No tools match your filters' : 'No tools available',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              hasFilters
                  ? 'Try adjusting your search criteria or clearing filters to see more tools.'
                  : 'There are currently no tools in the system. Check back later or contact your administrator.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Action buttons
            if (hasFilters) ...[
              ElevatedButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear Filters'),
              ),
              const SizedBox(height: 12),
            ],

            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),

            // Filter summary if filters are active
            if (hasFilters) ...[
              const SizedBox(height: 24),
              _buildFilterSummary(theme, colorScheme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSummary(ThemeData theme, ColorScheme colorScheme) {
    final activeFilters = <String>[];

    if (filters.search != null && filters.search!.isNotEmpty) {
      activeFilters.add('Search: "${filters.search}"');
    }
    if (filters.status != null) {
      activeFilters.add('Status: ${filters.status!.displayName}');
    }
    if (filters.category != null) {
      activeFilters.add('Category: ${filters.category!.displayName}');
    }
    if (filters.location != null && filters.location!.isNotEmpty) {
      activeFilters.add('Location: ${filters.location}');
    }

    if (activeFilters.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Active Filters:',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          ...activeFilters.map((filter) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_alt_outlined,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        filter,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
