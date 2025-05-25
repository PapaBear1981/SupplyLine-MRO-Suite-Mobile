import 'package:flutter/material.dart';

import '../../../../core/models/tool_model.dart';

class ToolSpecificationsCard extends StatelessWidget {
  final ToolSpecifications specifications;

  const ToolSpecificationsCard({
    super.key,
    required this.specifications,
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
              'Specifications',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._buildSpecificationRows(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSpecificationRows(BuildContext context) {
    final rows = <Widget>[];

    if (specifications.range != null) {
      rows.add(_buildSpecRow(context, 'Range', specifications.range!));
    }

    if (specifications.accuracy != null) {
      rows.add(_buildSpecRow(context, 'Accuracy', specifications.accuracy!));
    }

    if (specifications.weight != null) {
      rows.add(_buildSpecRow(context, 'Weight', specifications.weight!));
    }

    if (specifications.dimensions != null) {
      rows.add(_buildSpecRow(context, 'Dimensions', specifications.dimensions!));
    }

    // Add additional specifications if any
    if (specifications.additionalSpecs != null) {
      for (final entry in specifications.additionalSpecs!.entries) {
        rows.add(_buildSpecRow(context, entry.key, entry.value.toString()));
      }
    }

    return rows;
  }

  Widget _buildSpecRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
