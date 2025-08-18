import 'package:event_management_app1/dashboards/User_dashboard/user_screens/book_tickit_all_data/event_card.dart';
import 'package:event_management_app1/screens/home_all_data/widgets/category_filter.dart';
import 'package:event_management_app1/screens/home_all_data/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';


class UnifiedHomeScreen extends StatefulWidget {
  const UnifiedHomeScreen({super.key});

  @override
  State<UnifiedHomeScreen> createState() => _UnifiedHomeScreenState();
}

class _UnifiedHomeScreenState extends State<UnifiedHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All', 'Technology', 'Business', 'Arts', 'Sports',
    'Education', 'Health', 'Music', 'Food', 'Other'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<QueryDocumentSnapshot> _filterEvents(List<QueryDocumentSnapshot> events) {
    return events.where((event) {
      final data = event.data() as Map<String, dynamic>;
      final title = (data['eventTitle'] ?? '').toString().toLowerCase();
      final description = (data['eventDescription'] ?? '').toString().toLowerCase();
      final location = (data['location'] ?? '').toString().toLowerCase();
      final category = data['eventType'] ?? 'Other';

      final matchesSearch = _searchQuery.isEmpty ||
          title.contains(_searchQuery) ||
          description.contains(_searchQuery) ||
          location.contains(_searchQuery);

      final matchesCategory = _selectedCategory == 'All' || category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
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
          SearchBarWidget(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
          ),
          CategoryFilter(
            categories: _categories,
            selectedCategory: _selectedCategory,
            onCategorySelected: (category) =>
                setState(() => _selectedCategory = category),
          ),
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
                  return const Center(child: Text('No events available'));
                }

                final events = _filterEvents(snapshot.data!.docs);
                if (events.isEmpty) {
                  return const Center(child: Text('No events found'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    final eventData = event.data() as Map<String, dynamic>;
                    return EventCard(eventId: event.id, eventData: eventData);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
