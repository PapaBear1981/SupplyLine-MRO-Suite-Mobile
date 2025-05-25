import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/tool_model.dart';
import '../../../../core/models/user_model.dart';

class ToolActionButtons extends StatelessWidget {
  final ToolModel tool;
  final UserModel? currentUser;

  const ToolActionButtons({
    super.key,
    required this.tool,
    this.currentUser,
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
              'Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _buildActionButtons(context),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActionButtons(BuildContext context) {
    final buttons = <Widget>[];

    // Checkout button - show if tool is available
    if (tool.isAvailable) {
      buttons.add(
        ElevatedButton.icon(
          onPressed: () {
            context.push('/tools/checkout/${tool.id}');
          },
          icon: const Icon(Icons.assignment_turned_in),
          label: const Text('Checkout'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      );
    }

    // Return button - show if tool is checked out by current user
    if (tool.isCheckedOut && 
        currentUser != null && 
        tool.currentCheckoutUserId == currentUser!.id.toString()) {
      buttons.add(
        ElevatedButton.icon(
          onPressed: () {
            context.push('/tools/return/${tool.id}');
          },
          icon: const Icon(Icons.assignment_return),
          label: const Text('Return'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      );
    }

    // QR Code button - always available
    buttons.add(
      OutlinedButton.icon(
        onPressed: () {
          _showQrCodeDialog(context);
        },
        icon: const Icon(Icons.qr_code),
        label: const Text('QR Code'),
      ),
    );

    // Share button - always available
    buttons.add(
      OutlinedButton.icon(
        onPressed: () {
          _shareToolInfo(context);
        },
        icon: const Icon(Icons.share),
        label: const Text('Share'),
      ),
    );

    // Service button - show for authorized users (admin/technician)
    if (currentUser != null && 
        (currentUser!.role == 'admin' || currentUser!.role == 'technician')) {
      buttons.add(
        OutlinedButton.icon(
          onPressed: () {
            _showServiceDialog(context);
          },
          icon: const Icon(Icons.build),
          label: const Text('Service'),
        ),
      );
    }

    return buttons;
  }

  void _showQrCodeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'QR Code\nPlaceholder',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              tool.qrCode,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _shareToolInfo(BuildContext context) {
    final toolInfo = '''
Tool: ${tool.name}
ID: ${tool.id}
Status: ${tool.status.value}
Location: ${tool.location}
QR Code: ${tool.qrCode}
''';

    // TODO: Implement actual sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tool info copied: $toolInfo'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showServiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Service Tool'),
        content: const Text(
          'Service functionality will be implemented in a future update.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
