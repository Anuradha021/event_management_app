import 'package:flutter/material.dart';

/// Single Responsibility: Handle delete confirmation dialog
class DeleteConfirmationDialog extends StatelessWidget {
  final String itemType;
  final String itemName;
  final Future<void> Function() onConfirm;

  const DeleteConfirmationDialog({
    super.key,
    required this.itemType,
    required this.itemName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Delete $itemType'),
      content: Text(
        'Are you sure you want to delete "$itemName"?\n\nThis action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              await onConfirm();
              if (context.mounted) {
                Navigator.pop(context, true);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$itemType deleted successfully')),
                );
              }
            } catch (e) {
              if (context.mounted) {
                Navigator.pop(context, false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting $itemType: $e')),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Delete'),
        ),
      ],
    );
  }

  /// Static method to show the dialog
  static Future<bool?> show(
    BuildContext context, {
    required String itemType,
    required String itemName,
    required Future<void> Function() onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        itemType: itemType,
        itemName: itemName,
        onConfirm: onConfirm,
      ),
    );
  }
}
