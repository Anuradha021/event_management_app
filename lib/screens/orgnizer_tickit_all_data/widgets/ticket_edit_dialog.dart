import 'package:event_management_app1/models/ticket.dart';
import 'package:event_management_app1/services/ticket_service.dart';
import 'package:flutter/material.dart';


class TicketEditDialog extends StatefulWidget {
  final TicketType ticketType;

  const TicketEditDialog({super.key, required this.ticketType});

  @override
  State<TicketEditDialog> createState() => _TicketEditDialogState();
}

class _TicketEditDialogState extends State<TicketEditDialog> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.ticketType.name;
    _priceController.text = widget.ticketType.price.toString();
    _quantityController.text = widget.ticketType.totalQuantity.toString();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Ticket Type'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Ticket Name',
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
            keyboardType: TextInputType.number,
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
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _updateTicketType,
          child: const Text('Update'),
        ),
      ],
    );
  }

  void _updateTicketType() async {
    try {
      await TicketService.updateTicketType(
        ticketTypeId: widget.ticketType.id,
        name: _nameController.text,
        price: double.parse(_priceController.text),
        totalQuantity: int.parse(_quantityController.text),
      );

      if (mounted) {
        Navigator.pop(context);
        _showSnackBar('Ticket type updated successfully');
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
