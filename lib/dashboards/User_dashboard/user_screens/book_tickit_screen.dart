import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_theme.dart';
import '../../../screens/customer_ticket_purchase_screen.dart';
import '../../../screens/customer_ticket_details_screen.dart';

class BookTickitScreen extends StatefulWidget {
  const BookTickitScreen({super.key});

  @override
  State<BookTickitScreen> createState() => _BookTickitScreenState();
}

class _BookTickitScreenState extends State<BookTickitScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events & Tickets'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt),
            onPressed: () {
              // Navigate to user's tickets overview
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Select an event to view your tickets'),
                ),
              );
            },
            tooltip: 'My Tickets',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .where('status', isEqualTo: 'published')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No events available'),
                  Text('Check back later for upcoming events'),
                ],
              ),
            );
          }

          final events = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final eventData = event.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eventData['eventTitle'] ?? 'Event',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        eventData['eventDescription'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              eventData['location'] ?? '',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            _formatEventDate(eventData['eventDate']),
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CustomerTicketPurchaseScreen(
                                      eventId: event.id,
                                      eventTitle: eventData['eventTitle'] ?? 'Event',
                                      eventData: eventData,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.shopping_cart),
                              label: const Text('Buy Ticket'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CustomerTicketDetailsScreen(
                                      eventId: event.id,
                                      eventTitle: eventData['eventTitle'] ?? 'Event',
                                      eventData: eventData,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.receipt),
                              label: const Text('My Tickets'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryColor,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
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
      ),
    );
  }

  String _formatEventDate(dynamic eventDate) {
    if (eventDate == null) return 'Date TBD';

    try {
      DateTime date;
      if (eventDate is String) {
        // If it's already a string, return it
        return eventDate;
      } else if (eventDate.runtimeType.toString().contains('Timestamp')) {
        // If it's a Firestore Timestamp, convert it
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