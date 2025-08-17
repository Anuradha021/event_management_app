import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/theme/app_theme.dart';
import '../screens/user_event_details_screen.dart';
import '../screens/organizer_event_details_screen.dart';
import '../services/moderator_service.dart';

class UnifiedHomeScreen extends StatefulWidget {
  const UnifiedHomeScreen({super.key});

  @override
  State<UnifiedHomeScreen> createState() => _UnifiedHomeScreenState();
}

class _UnifiedHomeScreenState extends State<UnifiedHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _isOrganizer = false;

  final List<String> _categories = [
    'All',
    'Technology',
    'Business',
    'Arts',
    'Sports',
    'Education',
    'Health',
    'Music',
    'Food',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _checkOrganizerStatus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _checkOrganizerStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Check if user has any organized events
      final organizedEvents = await FirebaseFirestore.instance
          .collection('events')
          .where('organizerUid', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (mounted) {
        setState(() {
          _isOrganizer = organizedEvents.docs.isNotEmpty;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
       
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search events...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // Category Filter
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                    checkmarkColor: AppTheme.primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primaryColor : Colors.grey[700],
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),

          // Events List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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

                final events = _filterEvents(snapshot.data!.docs);

                if (events.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No events found'),
                        Text('Try adjusting your search or filters'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    final eventData = event.data() as Map<String, dynamic>;
                    return _buildEventCard(event.id, eventData);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<QueryDocumentSnapshot> _filterEvents(List<QueryDocumentSnapshot> events) {
    return events.where((event) {
      final data = event.data() as Map<String, dynamic>;
      final title = (data['eventTitle'] ?? '').toString().toLowerCase();
      final description = (data['eventDescription'] ?? '').toString().toLowerCase();
      final location = (data['location'] ?? '').toString().toLowerCase();
      final category = data['eventType'] ?? 'Other';

      //  search filter
      final matchesSearch = _searchQuery.isEmpty ||
          title.contains(_searchQuery) ||
          description.contains(_searchQuery) ||
          location.contains(_searchQuery);

      //  category filter
      final matchesCategory = _selectedCategory == 'All' || category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  Widget _buildEventCard(String eventId, Map<String, dynamic> eventData) {
    final user = FirebaseAuth.instance.currentUser;
    final isMyEvent = user != null && eventData['organizerUid'] == user.uid;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    eventData['eventTitle'] ?? 'Event',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isMyEvent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'MY EVENT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _navigateToEventDetails(eventId, eventData, isMyEvent),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(isMyEvent ? 'Manage Event' : 'View Event'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEventDetails(String eventId, Map<String, dynamic> eventData, bool isMyEvent) {
    if (isMyEvent) {
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrganizerEventDetailsScreen(
            eventId: eventId,
            eventData: eventData,
          ),
        ),
      );
    } else {
    
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserEventDetailsScreen(
            eventId: eventId,
            eventData: eventData,
          ),
        ),
      );
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
