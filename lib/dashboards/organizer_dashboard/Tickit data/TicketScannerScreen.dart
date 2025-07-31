import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class TicketScannerScreen extends StatelessWidget {
  final String eventId;
  const TicketScannerScreen({super.key, required this.eventId});

  void _validateTicket(String scannedTicketId, BuildContext context) async {
    final docRef =
        FirebaseFirestore.instance.collection('tickets').doc(scannedTicketId);
    final docSnap = await docRef.get();

    if (!docSnap.exists) {
      _showDialog(context, 'Invalid Ticket ID');
      return;
    }

    final data = docSnap.data()!;
    if (data['eventId'] != eventId) {
      _showDialog(context, 'This ticket is not for this event.');
      return;
    }

    if (data['status'] == 'used') {
      _showDialog(context, 'This ticket has already been used.');
      return;
    }

    await docRef.update({'status': 'used'});
    _showDialog(context, 'Ticket Validated Successfully!');
  }

  void _showDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Ticket Status"),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("OK"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scan Ticket QR")),
      body: MobileScanner(
        onDetect: (capture) {
          final barcode = capture.barcodes.first;
          final ticketId = barcode.rawValue;
          if (ticketId != null) {
            _validateTicket(ticketId, context);
          }
        },
      ),
    );
  }
}
