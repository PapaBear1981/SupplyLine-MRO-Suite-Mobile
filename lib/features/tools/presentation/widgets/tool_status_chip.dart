import 'package:flutter/material.dart';

import '../../../../core/models/tool_model.dart';

class ToolStatusChip extends StatelessWidget {
  final ToolStatus status;
  final bool showIcon;

  const ToolStatusChip({
    super.key,
    required this.status,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: showIcon ? Icon(
        _getStatusIcon(),
        size: 16,
        color: _getStatusColor(),
      ) : null,
      label: Text(
        _getStatusText(),
        style: TextStyle(
          color: _getStatusColor(),
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: _getStatusColor().withOpacity(0.1),
      side: BorderSide(
        color: _getStatusColor().withOpacity(0.3),
        width: 1,
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (status) {
      case ToolStatus.available:
        return Icons.check_circle;
      case ToolStatus.checkedOut:
        return Icons.assignment_turned_in;
      case ToolStatus.inService:
        return Icons.build;
      case ToolStatus.damaged:
        return Icons.warning;
      case ToolStatus.lost:
        return Icons.error;
    }
  }

  Color _getStatusColor() {
    switch (status) {
      case ToolStatus.available:
        return Colors.green;
      case ToolStatus.checkedOut:
        return Colors.blue;
      case ToolStatus.inService:
        return Colors.orange;
      case ToolStatus.damaged:
        return Colors.red;
      case ToolStatus.lost:
        return Colors.red.shade800;
    }
  }

  String _getStatusText() {
    switch (status) {
      case ToolStatus.available:
        return 'Available';
      case ToolStatus.checkedOut:
        return 'Checked Out';
      case ToolStatus.inService:
        return 'In Service';
      case ToolStatus.damaged:
        return 'Damaged';
      case ToolStatus.lost:
        return 'Lost';
    }
  }
}
