import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/session_panel.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/stall_panel.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'zone_panel.dart';
import 'track_panel.dart';


class EventManagementScreen extends StatefulWidget {
  final String eventId;
  
  EventManagementScreen({
    super.key,
    required this.eventId,
  }) : assert(eventId.isNotEmpty);

  @override
  State<EventManagementScreen> createState() => _EventManagementScreenState();
}

class _EventManagementScreenState extends State<EventManagementScreen> {
  int _activeTabIndex = 0;
  final PageController _pageController = PageController();
  Key _refreshKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAllData,
            tooltip: 'Refresh All Data',
          ),
          IconButton(
            icon: const Icon(Icons.publish),
            onPressed: _publishEvent,
            tooltip: 'Publish Event',
          ),
        ],
      ),
      body: Column(
        children: [
          // Event Summary Card
          _buildEventSummaryCard(),
          
          // Tab Navigation
          _buildTabNavigation(),
          
          // Content Area
          Expanded(
            child: PageView(
              key: _refreshKey,
              controller: _pageController,
              onPageChanged: (index) => setState(() => _activeTabIndex = index),
              children: [
                ZonePanel(eventId: widget.eventId),
                TrackPanel(eventId: widget.eventId),
                SessionPanel(eventId: widget.eventId),
                StallPanel(eventId: widget.eventId),
              ],
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildEventSummaryCard() {
  return FutureBuilder<DocumentSnapshot>(
    future: FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .get(),
    builder: (context, snapshot) {
      // Handle loading state
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: LinearProgressIndicator(),
          ),
        );
      }

      // Handle error state
      if (snapshot.hasError) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Error: ${snapshot.error}'),
          ),
        );
      }

      // Handle no data state
      if (!snapshot.hasData || !snapshot.data!.exists) {
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('Event not found'),
          ),
        );
      }

      final event = snapshot.data!.data() as Map<String, dynamic>;
      
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Row with Status Chip
              Row(
                children: [
                  Expanded(
                    child: Text(
                      event['eventTitle'] ?? 'Untitled Event',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  Chip(
                    label: Text(
                      (event['status'] ?? 'draft').toString().toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: event['status'] == 'published'
                        ? Colors.green
                        : Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Description
              Text(
                event['eventDescription'] ?? 'No description provided',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              // Location and Date
              Wrap(
                spacing: 16,
                children: [
                  if (event['location'] != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on, size: 16),
                        const SizedBox(width: 4),
                        Text(event['location']!),
                      ],
                    ),
                  if (event['eventDate'] != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(event['eventDate']),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

// Add this helper method to your class
String _formatDate(dynamic timestamp) {
  if (timestamp == null) return 'N/A';
  final date = (timestamp as Timestamp).toDate();
  return DateFormat('MMM d, yyyy').format(date);
}

  Widget _buildTabNavigation() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTabButton(0, Icons.map, 'Zones'),
          _buildTabButton(1, Icons.timeline, 'Tracks'),
          _buildTabButton(2, Icons.schedule, 'Sessions'),
          _buildTabButton(3, Icons.store, 'Stalls'),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, IconData icon, String label) {
    return TextButton(
      onPressed: () => _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      ),
      style: TextButton.styleFrom(
        foregroundColor: _activeTabIndex == index 
            ? Colors.deepPurple 
            : Colors.grey,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          Text(label),
        ],
      ),
    );
  }

  void _refreshAllData() {
    setState(() {
      _refreshKey = UniqueKey();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Refreshing all data...'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _publishEvent() async {
    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .update({'status': 'published'});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event published successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error publishing event: ${e.toString()}')),
        );
      }
    }
  }
}