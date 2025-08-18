import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../models/ticket.dart';

class TicketQrSection extends StatelessWidget {
  final Ticket ticket;

  const TicketQrSection({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          const Text(
            'Present this QR code at the event entrance',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          QrImageView(
            data: ticket.qrCode,
            version: QrVersions.auto,
            size: 200,
            backgroundColor: Colors.white,
          ),
          const SizedBox(height: 12),
          Text(
            "QR Code: ${ticket.qrCode}",
            style: const TextStyle(
                fontFamily: "monospace", fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
