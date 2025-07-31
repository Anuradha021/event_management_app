import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TicketCreateScreen extends StatefulWidget {
  final String eventId;
  const TicketCreateScreen({super.key, required this.eventId});

  @override
  State<TicketCreateScreen> createState() => _TicketCreateScreenState();
}

class _TicketCreateScreenState extends State<TicketCreateScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? generatedTicketId;

  Future<void> _createTicket() async {
    final uuid = Uuid();
    final ticketId = uuid.v4();

    await FirebaseFirestore.instance.collection('tickets').doc(ticketId).set({
      'ticketId': ticketId,
      'eventId': widget.eventId,
      'attendeeName': _nameController.text.trim(),
      'status': 'unused',
    });

    setState(() {
      generatedTicketId = ticketId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Ticket")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Attendee Name'),
            ),
            ElevatedButton(
              onPressed: _createTicket,
              child: Text("Generate Ticket"),
            ),
            if (generatedTicketId != null) ...[
              SizedBox(height: 20),
              Text("QR Code for Ticket ID:"),
              QrImageView(
                data: generatedTicketId!,
                version: QrVersions.auto,
                size: 200.0,
              ),
            ]
          ],
        ),
      ),
    );
  }
}
