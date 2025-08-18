import 'package:event_management_app1/core/theme/app_theme.dart';
import 'package:flutter/material.dart';


class ValidateTicketTab extends StatelessWidget {
  final TextEditingController qrController;
  final bool isLoading;
  final VoidCallback onValidate;

  const ValidateTicketTab({
    super.key,
    required this.qrController,
    required this.isLoading,
    required this.onValidate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: qrController,
            decoration: const InputDecoration(
              labelText: 'Enter QR Code',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.qr_code),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : onValidate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Validate Ticket'),
            ),
          ),
        ],
      ),
    );
  }
}
