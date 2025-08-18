import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../models/ticket.dart';
import '../../../core/theme/app_theme.dart';

class TicketQrDialog {
  static void show(BuildContext context, Ticket ticket) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(ticket.ticketTypeName),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(ticket.eventTitle,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: QrImageView(
                  data: ticket.qrCode,
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text("QR Code: ${ticket.qrCode}",
                        style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: Colors.grey),
                        textAlign: TextAlign.center),
                  ),
                  IconButton(
                    onPressed: () => _copyQRCode(context, ticket.qrCode),
                    icon: const Icon(Icons.copy, size: 16),
                    tooltip: 'Copy QR Code',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text("Present this QR code at the event entrance",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _copyQRCode(context, ticket.qrCode),
            child: const Text('Copy QR Code'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          )
        ],
      ),
    );
  }

  static void _copyQRCode(BuildContext context, String qrCode) {
    Clipboard.setData(ClipboardData(text: qrCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('QR Code copied: $qrCode'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }
}
