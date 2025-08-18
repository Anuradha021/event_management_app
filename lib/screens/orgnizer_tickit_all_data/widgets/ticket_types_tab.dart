import 'package:event_management_app1/core/theme/app_theme.dart';
import 'package:event_management_app1/models/ticket.dart';
import 'package:event_management_app1/services/ticket_service.dart';
import 'package:flutter/material.dart';


class TicketTypesTab extends StatelessWidget {
  final String eventId;
  final Function(TicketType) onEdit;
  final Function(String) onDelete;

  const TicketTypesTab({
    super.key,
    required this.eventId,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TicketType>>(
      stream: TicketService.getTicketTypesForOrganizer(eventId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final ticketTypes = snapshot.data ?? [];

        if (ticketTypes.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon(Icons.confirmation_number, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No ticket types created'),
                Text('Tap + to create'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ticketTypes.length,
          itemBuilder: (context, index) {
            final ticketType = ticketTypes[index];
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
                          child: Text(
                            ticketType.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '\$${ticketType.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('${ticketType.soldQuantity}/${ticketType.totalQuantity} sold'),
                    Text('Revenue: \$${ticketType.revenue.toStringAsFixed(2)}'),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: ticketType.totalQuantity > 0
                          ? ticketType.soldQuantity / ticketType.totalQuantity
                          : 0,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => onEdit(ticketType),
                          child: const Text('Edit'),
                        ),
                        TextButton(
                          onPressed: () => onDelete(ticketType.id),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
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
