import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/tool_model.dart';
import '../../../../core/services/auth_service.dart';
import '../../providers/tool_providers.dart';
import '../widgets/tool_status_chip.dart';
import '../widgets/tool_action_buttons.dart';
import '../widgets/tool_specifications_card.dart';
import '../widgets/tool_calibration_card.dart';
import '../widgets/tool_checkout_history_card.dart';

class ToolDetailPage extends ConsumerWidget {
  final String toolId;

  const ToolDetailPage({super.key, required this.toolId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toolDetailAsync = ref.watch(toolDetailProvider(toolId));
    final currentUser = ref.watch(authServiceProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tool Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: () {
              context.push('/tools/qr-scanner');
            },
          ),
        ],
      ),
      body: toolDetailAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading tool details',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(toolDetailProvider(toolId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (tool) => RefreshIndicator(
          onRefresh: () async {
            ref.refresh(toolDetailProvider(toolId));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildToolHeader(context, tool),
                const SizedBox(height: 16),
                ToolActionButtons(
                  tool: tool,
                  currentUser: currentUser,
                ),
                const SizedBox(height: 24),
                _buildToolInfo(context, tool),
                const SizedBox(height: 16),
                if (tool.specifications != null) ...[
                  ToolSpecificationsCard(specifications: tool.specifications!),
                  const SizedBox(height: 16),
                ],
                if (tool.calibration != null) ...[
                  ToolCalibrationCard(calibration: tool.calibration!),
                  const SizedBox(height: 16),
                ],
                if (tool.checkoutHistory.isNotEmpty) ...[
                  ToolCheckoutHistoryCard(history: tool.checkoutHistory),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToolHeader(BuildContext context, ToolModel tool) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tool.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                    ],
                  ),
                ),
                ToolStatusChip(status: tool.status),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              tool.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.category, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  tool.category,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 16),
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  tool.location,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolInfo(BuildContext context, ToolModel tool) {
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
            _buildInfoRow(context, 'QR Code', tool.qrCode),
            if (tool.isCheckedOut && tool.currentCheckoutDate != null) ...[
              _buildInfoRow(
                context,
                'Checked Out',
                DateFormat('MMM dd, yyyy HH:mm').format(tool.currentCheckoutDate!),
              ),
              if (tool.expectedReturnDate != null)
                _buildInfoRow(
                  context,
                  'Expected Return',
                  DateFormat('MMM dd, yyyy').format(tool.expectedReturnDate!),
                  isOverdue: tool.isOverdue,
                ),
            ],
            _buildInfoRow(
              context,
              'Created',
              DateFormat('MMM dd, yyyy').format(tool.createdAt),
            ),
            if (tool.updatedAt != null)
              _buildInfoRow(
                context,
                'Last Updated',
                DateFormat('MMM dd, yyyy HH:mm').format(tool.updatedAt!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, {bool isOverdue = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isOverdue ? Colors.red : null,
                fontWeight: isOverdue ? FontWeight.bold : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
