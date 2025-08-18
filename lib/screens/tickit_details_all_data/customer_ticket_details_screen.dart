import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../models/ticket.dart';
import '../../services/ticket_service.dart';
import 'widgets/ticket_card.dart';

class CustomerTicketDetailsScreen extends StatefulWidget {
  final String eventId;
  final String eventTitle;
  final Map<String, dynamic> eventData;

  const CustomerTicketDetailsScreen({
    super.key,
    required this.eventId,
    required this.eventTitle,
    required this.eventData,
  });

  @override
  State<CustomerTicketDetailsScreen> createState() =>
      _CustomerTicketDetailsScreenState();
}

class _CustomerTicketDetailsScreenState
    extends State<CustomerTicketDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Tickets - ${widget.eventTitle}'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Ticket>>(
        stream: TicketService.getUserTicketsForEvent(widget.eventId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final tickets = snapshot.data ?? [];

          if (tickets.isEmpty) {
            return const Center(
              child: Text("No tickets found for this event."),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return TicketCard(
                ticket: ticket,
                eventData: widget.eventData,
              );
            },
          );
        },
      ),
    );
  }
}
