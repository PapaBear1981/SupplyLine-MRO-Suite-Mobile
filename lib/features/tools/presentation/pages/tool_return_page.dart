import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/checkout_model.dart';
import '../../../../core/services/auth_service.dart';
import '../../providers/tool_providers.dart';
import '../widgets/condition_selection_field.dart';
import '../widgets/photo_capture_widget.dart';

class ToolReturnPage extends ConsumerStatefulWidget {
  final String toolId;

  const ToolReturnPage({super.key, required this.toolId});

  @override
  ConsumerState<ToolReturnPage> createState() => _ToolReturnPageState();
}

class _ToolReturnPageState extends ConsumerState<ToolReturnPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  ToolCondition _selectedCondition = ToolCondition.good;
  List<String> _photoUrls = [];

  @override
  Widget build(BuildContext context) {
    final toolDetailAsync = ref.watch(toolDetailProvider(widget.toolId));
    final returnState = ref.watch(toolReturnProvider);
    final currentUser = ref.watch(authServiceProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Return Tool'),
      ),
      body: toolDetailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading tool: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(toolDetailProvider(widget.toolId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (tool) {
          // Check if tool can be returned by current user
          if (!tool.isCheckedOut ||
              currentUser == null ||
              tool.currentCheckoutUserId != currentUser.id.toString()) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.block, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Cannot Return Tool',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tool.isCheckedOut
                        ? 'This tool is not checked out to you'
                        : 'This tool is not currently checked out',
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildToolInfo(context, tool),
                const SizedBox(height: 24),
                _buildReturnForm(context),
                const SizedBox(height: 24),
                _buildActionButtons(context, returnState),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildToolInfo(BuildContext context, tool) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tool Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tool.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${tool.id}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (tool.currentCheckoutDate != null)
                        Text(
                          'Checked out: ${DateFormat('MMM dd, yyyy HH:mm').format(tool.currentCheckoutDate!)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      if (tool.expectedReturnDate != null)
                        Text(
                          'Expected return: ${DateFormat('MMM dd, yyyy').format(tool.expectedReturnDate!)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: tool.isOverdue ? Colors.red : null,
                            fontWeight: tool.isOverdue ? FontWeight.bold : null,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: tool.isOverdue
                        ? Colors.red.withOpacity(0.1)
                        : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: tool.isOverdue
                          ? Colors.red.withOpacity(0.3)
                          : Colors.blue.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    tool.isOverdue ? 'OVERDUE' : 'Checked Out',
                    style: TextStyle(
                      color: tool.isOverdue ? Colors.red : Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReturnForm(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Return Details',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ConditionSelectionField(
                name: 'condition',
                onConditionSelected: (condition) {
                  setState(() {
                    _selectedCondition = condition;
                  });
                },
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'notes',
                decoration: const InputDecoration(
                  labelText: 'Return Notes',
                  hintText: 'Any notes about the tool condition or usage',
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                maxLength: 500,
                validator: _selectedCondition == ToolCondition.damaged ||
                        _selectedCondition == ToolCondition.needsMaintenance
                    ? FormBuilderValidators.required(
                        errorText: 'Please provide details about the condition',
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              PhotoCaptureWidget(
                onPhotosChanged: (photos) {
                  setState(() {
                    _photoUrls = photos;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, returnState) {
    return Column(
      children: [
        if (returnState.error != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    returnState.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        if (returnState.successMessage != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    returnState.successMessage!,
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: returnState.isLoading ? null : () => context.pop(),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: returnState.isLoading ? null : _handleReturn,
                child: returnState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Return Tool'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _handleReturn() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;

      final request = ReturnRequest(
        toolId: widget.toolId,
        checkoutId: 'current', // This would be the actual checkout ID in a real implementation
        condition: _selectedCondition,
        notes: formData['notes'] as String?,
        photoUrls: _photoUrls.isNotEmpty ? _photoUrls : null,
      );

      final success = await ref.read(toolReturnProvider.notifier).returnTool(request);

      if (success) {
        // Show confirmation dialog
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Return Successful'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Tool has been successfully returned',
                    textAlign: TextAlign.center,
                  ),
                  if (_selectedCondition != ToolCondition.good) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Condition: ${_selectedCondition.displayName}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    context.pop(); // Go back to previous page
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    }
  }
}
