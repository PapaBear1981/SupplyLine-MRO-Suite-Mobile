import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/tool_model.dart';

class ToolCheckoutHistoryCard extends StatelessWidget {
  final List<CheckoutHistoryItem> history;

  const ToolCheckoutHistoryCard({
    super.key,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Checkout History',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...history.take(5).map((item) => _buildHistoryItem(context, item)),
            if (history.length > 5) ...[
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () {
                    _showFullHistory(context);
                  },
                  child: Text('View All ${history.length} Records'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, CheckoutHistoryItem item) {
    final isReturned = item.returnDate != null;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isReturned ? Icons.check_circle : Icons.schedule,
                size: 16,
                color: isReturned ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.userName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                isReturned ? 'Returned' : 'Checked Out',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isReturned ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildHistoryRow(
            context,
            'Checked Out',
            DateFormat('MMM dd, yyyy HH:mm').format(item.checkoutDate),
          ),
          if (isReturned)
            _buildHistoryRow(
              context,
              'Returned',
              DateFormat('MMM dd, yyyy HH:mm').format(item.returnDate!),
            ),
          if (item.purpose != null && item.purpose!.isNotEmpty)
            _buildHistoryRow(context, 'Purpose', item.purpose!),
          if (item.returnCondition != null && item.returnCondition!.isNotEmpty)
            _buildHistoryRow(context, 'Condition', item.returnCondition!),
          if (item.returnNotes != null && item.returnNotes!.isNotEmpty)
            _buildHistoryRow(context, 'Notes', item.returnNotes!),
        ],
      ),
    );
  }

  Widget _buildHistoryRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  void _showFullHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'Complete Checkout History',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: history.length,
                  itemBuilder: (context, index) => _buildHistoryItem(context, history[index]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
