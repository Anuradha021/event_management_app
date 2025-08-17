import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/ticket.dart';
import '../services/ticket_service.dart';
import 'customer_ticket_details_screen.dart';

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
  State<CustomerTicketPurchaseScreen> createState() => _CustomerTicketPurchaseScreenState();
}

class _CustomerTicketPurchaseScreenState extends State<CustomerTicketPurchaseScreen> {
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
          // Event Info Card
          _buildEventInfoCard(),
          
          // Available Tickets
          Expanded(
            child: _buildAvailableTickets(),
          ),
        ],
      ),
    );
  }

  Widget _buildEventInfoCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.eventTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.eventData['location'] ?? '',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  _formatEventDate(widget.eventData['eventDate']),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableTickets() {
    return StreamBuilder<List<TicketType>>(
      stream: TicketService.getAvailableTicketTypes(widget.eventId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
              ],
            ),
          );
        }

        final ticketTypes = snapshot.data ?? [];

        if (ticketTypes.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.confirmation_number_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No tickets available',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'This event currently has no ticket types available for purchase.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ticketTypes.length,
          itemBuilder: (context, index) {
            final ticketType = ticketTypes[index];
            return _buildTicketTypeCard(ticketType);
          },
        );
      },
    );
  }

  Widget _buildTicketTypeCard(TicketType ticketType) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
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
                        ticketType.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (ticketType.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          ticketType.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${ticketType.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    Text(
                      '${ticketType.availableQuantity} left',
                      style: TextStyle(
                        color: ticketType.availableQuantity < 10 
                            ? Colors.red 
                            : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: ticketType.isSoldOut || _loadingTickets.contains(ticketType.id)
                    ? null
                    : () => _purchaseTicket(ticketType),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ticketType.isSoldOut 
                      ? Colors.grey 
                      : AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _loadingTickets.contains(ticketType.id)
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        ticketType.isSoldOut ? 'Sold Out' : 'Select Ticket',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
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

      if (result.success) {
        // Show success snackbar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your ticket is purchased.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Navigate to ticket details screen
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
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'Purchase failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
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
      DateTime date;
      if (eventDate is String) {
        return eventDate;
      } else if (eventDate.runtimeType.toString().contains('Timestamp')) {
        date = eventDate.toDate();
        return '${date.day}/${date.month}/${date.year}';
      } else {
        return eventDate.toString();
      }
    } catch (e) {
      return 'Date TBD';
    }
  }
}
