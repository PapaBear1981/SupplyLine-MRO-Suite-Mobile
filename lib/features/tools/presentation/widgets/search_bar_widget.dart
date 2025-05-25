import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import '../../../../core/models/tool_model.dart';
import '../../../tools/providers/tools_provider.dart';

class ToolSearchBar extends ConsumerStatefulWidget {
  final Function(String) onSearchChanged;
  final Function(ToolModel) onToolSelected;
  final String? initialValue;

  const ToolSearchBar({
    super.key,
    required this.onSearchChanged,
    required this.onToolSelected,
    this.initialValue,
  });

  @override
  ConsumerState<ToolSearchBar> createState() => _ToolSearchBarState();
}

class _ToolSearchBarState extends ConsumerState<ToolSearchBar> {
  late TextEditingController _controller;
  Timer? _debounceTimer;
  bool _showSuggestions = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounceTimer?.cancel();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {
      _showSuggestions = _focusNode.hasFocus && _controller.text.isNotEmpty;
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      _showSuggestions = value.isNotEmpty && _focusNode.hasFocus;
    });

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Start new timer
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      widget.onSearchChanged(value);
      if (value.isNotEmpty) {
        ref.read(searchProvider.notifier).searchTools(value);
      } else {
        ref.read(searchProvider.notifier).clearSearch();
      }
    });
  }

  void _onSuggestionTap(ToolModel tool) {
    _controller.text = tool.name;
    setState(() {
      _showSuggestions = false;
    });
    _focusNode.unfocus();
    widget.onToolSelected(tool);
  }

  void _clearSearch() {
    _controller.clear();
    setState(() {
      _showSuggestions = false;
    });
    widget.onSearchChanged('');
    ref.read(searchProvider.notifier).clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searchResults = ref.watch(searchProvider);

    return Column(
      children: [
        // Search TextField
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'Search tools by name, description, or serial number...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clearSearch,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
          ),
          onChanged: _onSearchChanged,
          textInputAction: TextInputAction.search,
          onSubmitted: (value) {
            setState(() {
              _showSuggestions = false;
            });
            _focusNode.unfocus();
          },
        ),

        // Search Suggestions
        if (_showSuggestions) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: searchResults.when(
              data: (tools) {
                if (tools.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No tools found',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: tools.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: theme.colorScheme.outline.withOpacity(0.1),
                  ),
                  itemBuilder: (context, index) {
                    final tool = tools[index];
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        _getStatusIcon(tool.status),
                        color: _getStatusColor(tool.status, theme.colorScheme),
                        size: 20,
                      ),
                      title: Text(
                        tool.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        '${tool.category.displayName} • ${tool.location}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: Text(
                        tool.status.displayName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _getStatusColor(tool.status, theme.colorScheme),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () => _onSuggestionTap(tool),
                    );
                  },
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              error: (error, stack) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Error searching tools',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  IconData _getStatusIcon(ToolStatus status) {
    switch (status) {
      case ToolStatus.available:
        return Icons.check_circle_outline;
      case ToolStatus.checkedOut:
        return Icons.person_outline;
      case ToolStatus.inService:
        return Icons.build_outlined;
      case ToolStatus.maintenance:
        return Icons.warning_outlined;
      case ToolStatus.outOfService:
        return Icons.block_outlined;
    }
  }

  Color _getStatusColor(ToolStatus status, ColorScheme colorScheme) {
    switch (status) {
      case ToolStatus.available:
        return colorScheme.primary;
      case ToolStatus.checkedOut:
        return colorScheme.secondary;
      case ToolStatus.inService:
        return colorScheme.tertiary;
      case ToolStatus.maintenance:
        return colorScheme.error;
      case ToolStatus.outOfService:
        return colorScheme.onSurfaceVariant;
    }
  }
}
