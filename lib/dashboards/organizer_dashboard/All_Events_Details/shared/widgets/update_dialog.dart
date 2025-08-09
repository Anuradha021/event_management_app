import 'package:flutter/material.dart';

/// A reusable update dialog widget
/// Follows Single Responsibility Principle - only handles dialog UI
class UpdateDialog extends StatefulWidget {
  final String title;
  final List<UpdateDialogField> fields;
  final Future<void> Function(Map<String, String> values) onUpdate;
  final String updateButtonText;

  const UpdateDialog({
    super.key,
    required this.title,
    required this.fields,
    required this.onUpdate,
    this.updateButtonText = 'Update',
  });

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  final Map<String, TextEditingController> _controllers = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    for (final field in widget.fields) {
      _controllers[field.key] = TextEditingController(text: field.initialValue);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    // Validate required fields
    for (final field in widget.fields) {
      if (field.isRequired && _controllers[field.key]!.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${field.label} is required')),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final values = <String, String>{};
      for (final field in widget.fields) {
        values[field.key] = _controllers[field.key]!.text.trim();
      }

      await widget.onUpdate(values);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.fields.map((field) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextField(
                controller: _controllers[field.key],
                decoration: InputDecoration(
                  labelText: field.label + (field.isRequired ? ' *' : ''),
                  border: const OutlineInputBorder(),
                ),
                maxLines: field.maxLines,
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleUpdate,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.updateButtonText),
        ),
      ],
    );
  }
}

/// Configuration class for dialog fields
class UpdateDialogField {
  final String key;
  final String label;
  final String initialValue;
  final bool isRequired;
  final int maxLines;

  const UpdateDialogField({
    required this.key,
    required this.label,
    this.initialValue = '',
    this.isRequired = false,
    this.maxLines = 1,
  });
}
