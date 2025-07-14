import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TicketListScreen extends StatelessWidget {
  final String eventId;

  const TicketListScreen({super.key, required this.eventId});

  Future<List<Map<String, dynamic>>> _fetchTickets() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('tickets')
        .where('eventId', isEqualTo: eventId) 
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['ticketId'] = doc.id;
      return data;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tickets for this Event')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchTickets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final tickets = snapshot.data ?? [];

          if (tickets.isEmpty) {
            return const Center(child: Text('No tickets found for this event.'));
          }

          return ListView.builder(
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              final ticketType = ticket['ticketType'] ?? 'N/A';
              final price = ticket['price'] ?? 'N/A';
              final limit = ticket['limit']?.toString() ?? 'N/A';
              final qrData = ticket['qrCodeData'] ?? '';

              return Card(
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Type: $ticketType', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Price: ₹ $price'),
                      const SizedBox(height: 4),
                      Text('Limit: $limit'),
                      const SizedBox(height: 12),
                      Center(
                        child: QrImageView(
                          data: qrData,
                          version: QrVersions.auto,
                          size: 150,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
