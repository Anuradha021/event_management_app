import 'package:event_management_app1/core/theme/app_theme.dart';
import 'package:event_management_app1/models/ticket.dart';
import 'package:event_management_app1/screens/tickit_details_all_data/customer_ticket_details_screen.dart';
import 'package:event_management_app1/screens/tickit_purchase_all_data/widgets/available_tickets_list.dart';
import 'package:event_management_app1/screens/tickit_purchase_all_data/widgets/event_info_card.dart';
import 'package:event_management_app1/services/ticket_service.dart';
import 'package:flutter/material.dart';


class CustomerTicketPurchaseScreen extends StatefulWidget {
  final String eventId;
  final String eventTitle;
  final Map<String, dynamic> eventData;

  const CustomerTicketPurchaseScreen({
    super.key,
    required this.eventId,
    required this.eventTitle,
    required this.eventData,
  });

  @override
  State<CustomerTicketPurchaseScreen> createState() =>
      _CustomerTicketPurchaseScreenState();
}

class _CustomerTicketPurchaseScreenState
    extends State<CustomerTicketPurchaseScreen> {
  final Set<String> _loadingTickets = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buy Tickets - ${widget.eventTitle}'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          EventInfoCard(
            title: widget.eventTitle,
            location: widget.eventData['location'] ?? '',
            date: _formatEventDate(widget.eventData['eventDate']),
          ),
          Expanded(
            child: AvailableTicketsList(
              eventId: widget.eventId,
              loadingTickets: _loadingTickets,
              onPurchase: _purchaseTicket,
            ),
          ),
        ],
      ),
    );
  }

  void _purchaseTicket(TicketType ticketType) async {
    setState(() => _loadingTickets.add(ticketType.id));

    try {
      final result = await TicketService.purchaseTicket(
        ticketTypeId: ticketType.id,
        eventId: widget.eventId,
        eventTitle: widget.eventTitle,
      );

      if (result.success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your ticket is purchased.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CustomerTicketDetailsScreen(
              eventId: widget.eventId,
              eventTitle: widget.eventTitle,
              eventData: widget.eventData,
            ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Purchase failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loadingTickets.remove(ticketType.id));
      }
    }
  }

  String _formatEventDate(dynamic eventDate) {
    if (eventDate == null) return 'Date TBD';

    try {
      if (eventDate is String) return eventDate;
      if (eventDate.runtimeType.toString().contains('Timestamp')) {
        final date = eventDate.toDate();
        return '${date.day}/${date.month}/${date.year}';
      }
      return eventDate.toString();
    } catch (_) {
      return 'Date TBD';
    }
  }
}
