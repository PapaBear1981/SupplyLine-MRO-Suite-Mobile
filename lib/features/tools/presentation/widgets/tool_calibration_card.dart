import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/tool_model.dart';

class ToolCalibrationCard extends StatelessWidget {
  final ToolCalibration calibration;

  const ToolCalibrationCard({
    super.key,
    required this.calibration,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Calibration',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (calibration.isOverdue)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: const Text(
                      'OVERDUE',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (!calibration.isRequired)
              _buildCalibrationRow(
                context,
                'Status',
                'Not Required',
                icon: Icons.info_outline,
                iconColor: Colors.grey,
              )
            else ...[
              if (calibration.lastDate != null)
                _buildCalibrationRow(
                  context,
                  'Last Calibration',
                  DateFormat('MMM dd, yyyy').format(calibration.lastDate!),
                  icon: Icons.check_circle_outline,
                  iconColor: Colors.green,
                ),
              if (calibration.nextDate != null)
                _buildCalibrationRow(
                  context,
                  'Next Due',
                  DateFormat('MMM dd, yyyy').format(calibration.nextDate!),
                  icon: Icons.schedule,
                  iconColor: calibration.isOverdue ? Colors.red : Colors.orange,
                ),
              if (calibration.certificate != null)
                _buildCalibrationRow(
                  context,
                  'Certificate',
                  calibration.certificate!,
                  icon: Icons.description,
                  iconColor: Colors.blue,
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCalibrationRow(
    BuildContext context,
    String label,
    String value, {
    IconData? icon,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: iconColor ?? Colors.grey[600],
            ),
            const SizedBox(width: 8),
          ],
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
                color: calibration.isOverdue && label == 'Next Due' ? Colors.red : null,
                fontWeight: calibration.isOverdue && label == 'Next Due' ? FontWeight.bold : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
