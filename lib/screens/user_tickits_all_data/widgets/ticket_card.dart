import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/ticket.dart';
import '../utils/ticket_status_color.dart';
import '../utils/ticket_date_formatter.dart';
import 'ticket_detail_item.dart';
import 'ticket_qr_dialog.dart';

class TicketCard extends StatelessWidget {
  final Ticket ticket;
  const TicketCard({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildDetails(),
            const SizedBox(height: 16),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ticket.eventTitle,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(ticket.ticketTypeName,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor)),
              if (ticket.ticketTypeDescription.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(ticket.ticketTypeDescription,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              ]
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: TicketStatusColor.get(ticket.status),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            ticket.status.toUpperCase(),
            style: const TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildDetails() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: TicketDetailItem(label: "Price", value: "\$${ticket.price.toStringAsFixed(2)}")),
            Expanded(child: TicketDetailItem(label: "Purchase Date", value: TicketDateFormatter.format(ticket.purchaseDate))),
          ],
        ),
        if (ticket.isUsed && ticket.usedAt != null) ...[
          const SizedBox(height: 8),
          TicketDetailItem(label: "Used At", value: TicketDateFormatter.format(ticket.usedAt!)),
        ],
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => TicketQrDialog.show(context, ticket),
            icon: const Icon(Icons.qr_code),
            label: const Text('Show QR Code'),
            style: OutlinedButton.styleFrom(foregroundColor: AppTheme.primaryColor),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _downloadPDF(context),
            icon: const Icon(Icons.download),
            label: const Text('Download PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  void _downloadPDF(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PDF download feature coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
