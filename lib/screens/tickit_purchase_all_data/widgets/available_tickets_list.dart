import 'package:event_management_app1/models/ticket.dart';
import 'package:event_management_app1/services/ticket_service.dart';
import 'package:flutter/material.dart';
import 'ticket_type_card.dart';

class AvailableTicketsList extends StatelessWidget {
  final String eventId;
  final Set<String> loadingTickets;
  final Function(TicketType) onPurchase;

  const AvailableTicketsList({
    super.key,
    required this.eventId,
    required this.loadingTickets,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TicketType>>(
      stream: TicketService.getAvailableTicketTypes(eventId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final ticketTypes = snapshot.data ?? [];

        if (ticketTypes.isEmpty) {
          return const Center(child: Text("No tickets available"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ticketTypes.length,
          itemBuilder: (context, index) {
            final ticketType = ticketTypes[index];
            return TicketTypeCard(
              ticketType: ticketType,
              isLoading: loadingTickets.contains(ticketType.id),
              onPurchase: () => onPurchase(ticketType),
            );
          },
        );
      },
    );
  }
}
