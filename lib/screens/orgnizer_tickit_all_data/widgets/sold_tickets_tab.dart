import 'package:event_management_app1/core/theme/app_theme.dart';
import 'package:event_management_app1/models/ticket.dart';
import 'package:event_management_app1/services/ticket_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class SoldTicketsTab extends StatefulWidget {
  final String eventId;

  const SoldTicketsTab({super.key, required this.eventId});

  @override
  State<SoldTicketsTab> createState() => _SoldTicketsTabState();
}

class _SoldTicketsTabState extends State<SoldTicketsTab> {
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _copyQRCode(String qrCode) {
    Clipboard.setData(ClipboardData(text: qrCode));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('QR Code copied: $qrCode'),
          duration: const Duration(seconds: 2),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Ticket>>(
      stream: TicketService.getTicketsForEvent(widget.eventId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final tickets = snapshot.data ?? [];

        if (tickets.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No tickets sold yet'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tickets.length,
          itemBuilder: (context, index) {
            final ticket = tickets[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ticket.ticketTypeName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(ticket.userName),
                              Text(ticket.userEmail),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: ticket.isUsed ? Colors.green : Colors.orange,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                ticket.status.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${ticket.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'QR: ${ticket.qrCode}',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _copyQRCode(ticket.qrCode),
                          icon: const Icon(Icons.copy, size: 16),
                          tooltip: 'Copy QR Code',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                      ],
                    ),
                    Text('Purchased: ${_formatDate(ticket.purchaseDate)}'),
                    if (ticket.usedAt != null)
                      Text('Used: ${_formatDate(ticket.usedAt!)}'),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
