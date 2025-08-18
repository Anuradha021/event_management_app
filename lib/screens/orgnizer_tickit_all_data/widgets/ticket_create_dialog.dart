import 'package:event_management_app1/core/theme/app_theme.dart';
import 'package:event_management_app1/services/ticket_service.dart';
import 'package:flutter/material.dart';


class TicketCreateDialog extends StatefulWidget {
  final String eventId;

  const TicketCreateDialog({super.key, required this.eventId});

  @override
  State<TicketCreateDialog> createState() => _TicketCreateDialogState();
}

class _TicketCreateDialogState extends State<TicketCreateDialog> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Ticket Type'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Ticket Name (e.g., VIP, Regular)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price (\$)',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Total Quantity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _createTicketType,
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
          child: const Text('Create Ticket Type'),
        ),
      ],
    );
  }

  void _createTicketType() async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _quantityController.text.isEmpty) {
      _showSnackBar('Please fill all fields', isError: true);
      return;
    }

    try {
      await TicketService.createTicketType(
        eventId: widget.eventId,
        name: _nameController.text,
        description: '',
        price: double.parse(_priceController.text),
        totalQuantity: int.parse(_quantityController.text),
      );

      if (mounted) {
        Navigator.pop(context);
        _showSnackBar('Ticket type "${_nameController.text}" created successfully!');
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}
