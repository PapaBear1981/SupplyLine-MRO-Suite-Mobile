import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/tool_model.dart';

class ToolCard extends StatelessWidget {
  final ToolModel tool;
  final VoidCallback? onTap;

  const ToolCard({
    super.key,
    required this.tool,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap ?? () => context.push('/tools/detail/${tool.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with tool name and status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      tool.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(colorScheme),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Description
              Text(
                tool.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // Info row with category and location
              Row(
                children: [
                  Icon(
                    _getCategoryIcon(tool.category),
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    tool.category.displayName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      tool.location,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              // Calibration warning if applicable
              if (tool.calibration?.isOverdue == true ||
                  tool.calibration?.isDueSoon == true) ...[
                const SizedBox(height: 8),
                _buildCalibrationWarning(theme, colorScheme),
              ],
              
              // Serial number if available
              if (tool.serialNumber != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.qr_code,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'S/N: ${tool.serialNumber}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(ColorScheme colorScheme) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (tool.status) {
      case ToolStatus.available:
        backgroundColor = colorScheme.primaryContainer;
        textColor = colorScheme.onPrimaryContainer;
        icon = Icons.check_circle_outline;
        break;
      case ToolStatus.checkedOut:
        backgroundColor = colorScheme.secondaryContainer;
        textColor = colorScheme.onSecondaryContainer;
        icon = Icons.person_outline;
        break;
      case ToolStatus.inService:
        backgroundColor = colorScheme.tertiaryContainer;
        textColor = colorScheme.onTertiaryContainer;
        icon = Icons.build_outlined;
        break;
      case ToolStatus.maintenance:
        backgroundColor = colorScheme.errorContainer;
        textColor = colorScheme.onErrorContainer;
        icon = Icons.warning_outlined;
        break;
      case ToolStatus.outOfService:
        backgroundColor = colorScheme.surfaceVariant;
        textColor = colorScheme.onSurfaceVariant;
        icon = Icons.block_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            tool.status.displayName,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalibrationWarning(ThemeData theme, ColorScheme colorScheme) {
    final isOverdue = tool.calibration?.isOverdue == true;
    final isDueSoon = tool.calibration?.isDueSoon == true;
    
    if (!isOverdue && !isDueSoon) return const SizedBox.shrink();

    final backgroundColor = isOverdue 
        ? colorScheme.errorContainer 
        : colorScheme.secondaryContainer;
    final textColor = isOverdue 
        ? colorScheme.onErrorContainer 
        : colorScheme.onSecondaryContainer;
    final icon = isOverdue ? Icons.error_outline : Icons.schedule_outlined;
    final text = isOverdue ? 'Calibration Overdue' : 'Calibration Due Soon';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(ToolCategory category) {
    switch (category) {
      case ToolCategory.handTools:
        return Icons.handyman;
      case ToolCategory.powerTools:
        return Icons.power;
      case ToolCategory.measuring:
        return Icons.straighten;
      case ToolCategory.safety:
        return Icons.security;
      case ToolCategory.cnc:
        return Icons.precision_manufacturing;
      case ToolCategory.engine:
        return Icons.settings;
      case ToolCategory.cl415:
      case ToolCategory.rj85:
      case ToolCategory.q400:
        return Icons.flight;
      case ToolCategory.sheetmetal:
        return Icons.construction;
      case ToolCategory.general:
      default:
        return Icons.build;
    }
  }
}
