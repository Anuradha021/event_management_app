import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/ticket.dart';
import 'ticket_detail_row.dart';
import 'ticket_qr_section.dart';
import 'download_button.dart';

class TicketCard extends StatelessWidget {
  final Ticket ticket;
  final Map<String, dynamic> eventData;

  const TicketCard({
    super.key,
    required this.ticket,
    required this.eventData,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ticket.ticketTypeName,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(ticket.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    ticket.status.toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Details
            TicketDetailRow(label: "Event", value: ticket.eventTitle),
            TicketDetailRow(
                label: "Location", value: eventData['location'] ?? ''),
            TicketDetailRow(
                label: "Date", value: _formatEventDate(eventData['eventDate'])),
            TicketDetailRow(
                label: "Price", value: "\$${ticket.price.toStringAsFixed(2)}"),
            TicketDetailRow(
                label: "Purchase Date", value: _formatDate(ticket.purchaseDate)),

            const SizedBox(height: 20),

            // QR Section
            TicketQrSection(ticket: ticket),

            const SizedBox(height: 20),

            // Download Button
            DownloadButton(ticket: ticket),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'used':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  String _formatEventDate(dynamic eventDate) {
    if (eventDate == null) return "TBD";
    try {
      if (eventDate is String) return eventDate;
      return eventDate.toString();
    } catch (_) {
      return "TBD";
    }
  }
}
