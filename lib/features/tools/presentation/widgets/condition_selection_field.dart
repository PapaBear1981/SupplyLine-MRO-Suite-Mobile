import 'package:flutter/material.dart';

import '../../../../core/models/checkout_model.dart';

class ConditionSelectionField extends StatefulWidget {
  final String name;
  final Function(ToolCondition) onConditionSelected;

  const ConditionSelectionField({
    super.key,
    required this.name,
    required this.onConditionSelected,
  });

  @override
  State<ConditionSelectionField> createState() => _ConditionSelectionFieldState();
}

class _ConditionSelectionFieldState extends State<ConditionSelectionField> {
  ToolCondition _selectedCondition = ToolCondition.good;

  @override
  void initState() {
    super.initState();
    widget.onConditionSelected(_selectedCondition);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tool Condition',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        ...ToolCondition.values.map((condition) => _buildConditionTile(condition)),
      ],
    );
  }

  Widget _buildConditionTile(ToolCondition condition) {
    final isSelected = _selectedCondition == condition;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected 
              ? Theme.of(context).primaryColor 
              : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: isSelected 
            ? Theme.of(context).primaryColor.withOpacity(0.05)
            : null,
      ),
      child: RadioListTile<ToolCondition>(
        value: condition,
        groupValue: _selectedCondition,
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedCondition = value;
            });
            widget.onConditionSelected(value);
          }
        },
        title: Row(
          children: [
            Icon(
              _getConditionIcon(condition),
              color: _getConditionColor(condition),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              condition.displayName,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        subtitle: Text(
          _getConditionDescription(condition),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        activeColor: Theme.of(context).primaryColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }

  IconData _getConditionIcon(ToolCondition condition) {
    switch (condition) {
      case ToolCondition.good:
        return Icons.check_circle;
      case ToolCondition.needsMaintenance:
        return Icons.build;
      case ToolCondition.damaged:
        return Icons.warning;
      case ToolCondition.lost:
        return Icons.error;
    }
  }

  Color _getConditionColor(ToolCondition condition) {
    switch (condition) {
      case ToolCondition.good:
        return Colors.green;
      case ToolCondition.needsMaintenance:
        return Colors.orange;
      case ToolCondition.damaged:
        return Colors.red;
      case ToolCondition.lost:
        return Colors.red.shade800;
    }
  }

  String _getConditionDescription(ToolCondition condition) {
    switch (condition) {
      case ToolCondition.good:
        return 'Tool is in good working condition';
      case ToolCondition.needsMaintenance:
        return 'Tool needs maintenance or calibration';
      case ToolCondition.damaged:
        return 'Tool is damaged and needs repair';
      case ToolCondition.lost:
        return 'Tool is lost or missing';
    }
  }
}
