import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/tool_model.dart';
import '../../../../core/services/tool_service.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  final ToolFilters currentFilters;
  final Function(ToolFilters) onFiltersChanged;

  const FilterBottomSheet({
    super.key,
    required this.currentFilters,
    required this.onFiltersChanged,
  });

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late ToolFilters _filters;
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filters = widget.currentFilters;
    _locationController.text = _filters.location ?? '';
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  void _updateFilters(ToolFilters newFilters) {
    setState(() {
      _filters = newFilters;
    });
  }

  void _applyFilters() {
    widget.onFiltersChanged(_filters);
    Navigator.of(context).pop();
  }

  void _clearFilters() {
    setState(() {
      _filters = const ToolFilters();
      _locationController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Filter Tools',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Clear All'),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Status Filter
          Text(
            'Status',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ToolStatus.values.map((status) {
              final isSelected = _filters.status == status;
              return FilterChip(
                label: Text(status.displayName),
                selected: isSelected,
                onSelected: (selected) {
                  _updateFilters(_filters.copyWith(
                    status: selected ? status : null,
                  ));
                },
                selectedColor: colorScheme.primaryContainer,
                checkmarkColor: colorScheme.onPrimaryContainer,
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Category Filter
          Text(
            'Category',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: ToolCategory.values.map((category) {
              final isSelected = _filters.category == category;
              return FilterChip(
                label: Text(category.displayName),
                selected: isSelected,
                onSelected: (selected) {
                  _updateFilters(_filters.copyWith(
                    category: selected ? category : null,
                  ));
                },
                selectedColor: colorScheme.secondaryContainer,
                checkmarkColor: colorScheme.onSecondaryContainer,
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Location Filter
          Text(
            'Location',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _locationController,
            decoration: InputDecoration(
              hintText: 'Enter location...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: _locationController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _locationController.clear();
                        _updateFilters(_filters.copyWith(location: null));
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              _updateFilters(_filters.copyWith(
                location: value.isEmpty ? null : value,
              ));
            },
          ),

          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  child: Text(
                    _filters.hasActiveFilters 
                        ? 'Apply Filters (${_getActiveFilterCount()})' 
                        : 'Apply Filters',
                  ),
                ),
              ),
            ],
          ),

          // Add bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (_filters.status != null) count++;
    if (_filters.category != null) count++;
    if (_filters.location != null && _filters.location!.isNotEmpty) count++;
    return count;
  }
}

// Helper function to show the filter bottom sheet
Future<void> showFilterBottomSheet({
  required BuildContext context,
  required ToolFilters currentFilters,
  required Function(ToolFilters) onFiltersChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => FilterBottomSheet(
      currentFilters: currentFilters,
      onFiltersChanged: onFiltersChanged,
    ),
  );
}
