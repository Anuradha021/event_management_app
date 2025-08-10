// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../../core/theme/app_theme.dart';
// import '../../../core/widgets/empty_state.dart';
// import '../widgets/featured_event_card.dart';
// import '../widgets/quick_search_bar.dart';
// import 'event_details_screen.dart';

// /// Screen showing all published events with search and filter capabilities
// class EventListScreen extends StatefulWidget {
//   final String? initialSearchQuery;
//   final bool showSearchBar;

//   const EventListScreen({
//     super.key,
//     this.initialSearchQuery,
//     this.showSearchBar = false,
//   });

//   @override
//   State<EventListScreen> createState() => _EventListScreenState();
// }

// class _EventListScreenState extends State<EventListScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
  
//   String _searchQuery = '';
//   Map<String, dynamic> _filters = {};
//   bool _showFilters = false;
//   String _sortBy = 'date'; // date, name, location
//   bool _sortAscending = true;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.initialSearchQuery != null) {
//       _searchController.text = widget.initialSearchQuery!;
//       _searchQuery = widget.initialSearchQuery!;
//     }
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.backgroundColor,
//       appBar: AppBar(
//         title: const Text('All Events'),
//         backgroundColor: AppTheme.primaryColor,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: Icon(_showFilters ? Icons.filter_list : Icons.filter_list_outlined),
//             onPressed: () => setState(() => _showFilters = !_showFilters),
//             tooltip: 'Filters',
//           ),
//           PopupMenuButton<String>(
//             icon: const Icon(Icons.sort_outlined),
//             tooltip: 'Sort',
//             onSelected: _handleSortSelection,
//             itemBuilder: (context) => [
//               PopupMenuItem(
//                 value: 'date',
//                 child: Row(
//                   children: [
//                     Icon(Icons.calendar_today_outlined, size: 18),
//                     const SizedBox(width: 8),
//                     const Text('Sort by Date'),
//                   ],
//                 ),
//               ),
//               PopupMenuItem(
//                 value: 'name',
//                 child: Row(
//                   children: [
//                     Icon(Icons.sort_by_alpha_outlined, size: 18),
//                     const SizedBox(width: 8),
//                     const Text('Sort by Name'),
//                   ],
//                 ),
//               ),
//               PopupMenuItem(
//                 value: 'location',
//                 child: Row(
//                   children: [
//                     Icon(Icons.location_on_outlined, size: 18),
//                     const SizedBox(width: 8),
//                     const Text('Sort by Location'),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Search bar
//           if (widget.showSearchBar || _searchQuery.isNotEmpty)
//             Container(
//               padding: const EdgeInsets.all(AppTheme.spacingM),
//               child: QuickSearchBar(
//                 controller: _searchController,
//                 onSearch: _handleSearch,
//               ),
//             ),
          
//           // Filters
//           if (_showFilters)
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
//               child: Container(
//                 padding: const EdgeInsets.all(AppTheme.spacingM),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(AppTheme.radiusM),
//                   boxShadow: AppTheme.cardShadow,
//                 ),
//                 child: Column(
//                   children: [
//                     Text(
//                       'Search Filters',
//                       style: AppTheme.labelLarge,
//                     ),
//                     const SizedBox(height: AppTheme.spacingM),
//                     Text(
//                       'Advanced filters coming soon!',
//                       style: AppTheme.bodyMedium,
//                     ),
//                     const SizedBox(height: AppTheme.spacingM),
//                     ElevatedButton(
//                       onPressed: () => setState(() => _showFilters = false),
//                       child: const Text('Close'),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
          
//           // Results header
//           _buildResultsHeader(),
          
//           // Events list
//           Expanded(
//             child: _buildEventsList(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildResultsHeader() {
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: AppTheme.spacingM,
//         vertical: AppTheme.spacingS,
//       ),
//       child: Row(
//         children: [
//           Text(
//             _searchQuery.isNotEmpty 
//                 ? 'Search Results'
//                 : 'All Events',
//             style: AppTheme.headingSmall,
//           ),
//           const Spacer(),
//           if (_searchQuery.isNotEmpty)
//             TextButton(
//               onPressed: _clearSearch,
//               child: const Text('Clear'),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEventsList() {
//     return StreamBuilder<QuerySnapshot>(
//       stream: _buildEventsQuery(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
        
//         if (snapshot.hasError) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.error_outline,
//                   size: 48,
//                   color: AppTheme.errorColor,
//                 ),
//                 const SizedBox(height: AppTheme.spacingM),
//                 Text(
//                   'Error loading events',
//                   style: AppTheme.bodyLarge.copyWith(color: AppTheme.errorColor),
//                 ),
//                 const SizedBox(height: AppTheme.spacingS),
//                 Text(
//                   'Please try again later',
//                   style: AppTheme.bodyMedium,
//                 ),
//               ],
//             ),
//           );
//         }
        
//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return EmptyState(
//             icon: _searchQuery.isNotEmpty ? Icons.search_off : Icons.event_busy,
//             title: _searchQuery.isNotEmpty 
//                 ? 'No events found'
//                 : 'No events available',
//             subtitle: _searchQuery.isNotEmpty
//                 ? 'Try adjusting your search terms or filters'
//                 : 'Check back soon for upcoming events',
//             onActionPressed: _searchQuery.isNotEmpty ? _clearSearch : null,
//             actionText: _searchQuery.isNotEmpty ? 'Clear Search' : null,
//           );
//         }
        
//         final events = snapshot.data!.docs;
//         final filteredEvents = _applyClientSideFilters(events);
        
//         if (filteredEvents.isEmpty) {
//           return EmptyState(
//             icon: Icons.filter_list_off,
//             title: 'No events match your filters',
//             subtitle: 'Try adjusting your search criteria',
//             onActionPressed: _clearFilters,
//             actionText: 'Clear Filters',
//           );
//         }
        
//         return ListView.builder(
//           controller: _scrollController,
//           padding: const EdgeInsets.all(AppTheme.spacingM),
//           itemCount: filteredEvents.length,
//           itemBuilder: (context, index) {
//             final doc = filteredEvents[index];
//             final eventData = doc.data() as Map<String, dynamic>;
            
//             return CompactEventCard(
//               eventId: doc.id,
//               eventData: eventData,
//               onTap: () => _navigateToEventDetails(doc.id, eventData),
//             );
//           },
//         );
//       },
//     );
//   }

//   Stream<QuerySnapshot> _buildEventsQuery() {
//     Query query = FirebaseFirestore.instance
//         .collection('events')
//         .where('status', isEqualTo: 'published');
    
//     // Apply sorting
//     switch (_sortBy) {
//       case 'date':
//         query = query.orderBy('eventDate', descending: !_sortAscending);
//         break;
//       case 'name':
//         query = query.orderBy('eventTitle', descending: !_sortAscending);
//         break;
//       case 'location':
//         query = query.orderBy('location', descending: !_sortAscending);
//         break;
//     }
    
//     return query.snapshots();
//   }

//   List<QueryDocumentSnapshot> _applyClientSideFilters(List<QueryDocumentSnapshot> events) {
//     var filtered = events;
    
//     // Apply search query
//     if (_searchQuery.isNotEmpty) {
//       filtered = filtered.where((doc) {
//         final data = doc.data() as Map<String, dynamic>;
//         final searchText = _searchQuery.toLowerCase();
        
//         return (data['eventTitle']?.toString().toLowerCase().contains(searchText) ?? false) ||
//                (data['eventName']?.toString().toLowerCase().contains(searchText) ?? false) ||
//                (data['description']?.toString().toLowerCase().contains(searchText) ?? false) ||
//                (data['location']?.toString().toLowerCase().contains(searchText) ?? false) ||
//                (data['organizerName']?.toString().toLowerCase().contains(searchText) ?? false);
//       }).toList();
//     }
    
//     // Apply date range filter
//     if (_filters['dateRange'] != null) {
//       final now = DateTime.now();
//       DateTime? startDate;
//       DateTime? endDate;
      
//       switch (_filters['dateRange']) {
//         case 'today':
//           startDate = DateTime(now.year, now.month, now.day);
//           endDate = startDate.add(const Duration(days: 1));
//           break;
//         case 'week':
//           startDate = now.subtract(Duration(days: now.weekday - 1));
//           endDate = startDate.add(const Duration(days: 7));
//           break;
//         case 'month':
//           startDate = DateTime(now.year, now.month, 1);
//           endDate = DateTime(now.year, now.month + 1, 1);
//           break;
//       }
      
//       if (startDate != null && endDate != null) {
//         filtered = filtered.where((doc) {
//           final data = doc.data() as Map<String, dynamic>;
//           final eventDate = data['eventDate'];
//           if (eventDate == null) return false;
          
//           try {
//             DateTime date;
//             if (eventDate is String) {
//               date = DateTime.parse(eventDate);
//             } else if (eventDate.runtimeType.toString().contains('Timestamp')) {
//               date = eventDate.toDate();
//             } else {
//               return false;
//             }
            
//             return date.isAfter(startDate!) && date.isBefore(endDate!);
//           } catch (e) {
//             return false;
//           }
//         }).toList();
//       }
//     }
    
//     // Apply location filter
//     if (_filters['location'] != null && _filters['location'].isNotEmpty) {
//       final locationFilter = _filters['location'].toLowerCase();
//       filtered = filtered.where((doc) {
//         final data = doc.data() as Map<String, dynamic>;
//         return data['location']?.toString().toLowerCase().contains(locationFilter) ?? false;
//       }).toList();
//     }
    
//     // Apply category filter
//     if (_filters['categories'] != null && (_filters['categories'] as List).isNotEmpty) {
//       final categories = _filters['categories'] as List<String>;
//       filtered = filtered.where((doc) {
//         final data = doc.data() as Map<String, dynamic>;
//         final eventCategory = data['category']?.toString();
//         return eventCategory != null && categories.contains(eventCategory);
//       }).toList();
//     }
    
//     return filtered;
//   }

//   void _handleSearch(String query) {
//     setState(() {
//       _searchQuery = query;
//     });
//   }

//   // Filters functionality will be implemented when SearchFilters widget is created

//   void _handleSortSelection(String sortBy) {
//     setState(() {
//       if (_sortBy == sortBy) {
//         _sortAscending = !_sortAscending;
//       } else {
//         _sortBy = sortBy;
//         _sortAscending = true;
//       }
//     });
//   }

//   void _clearSearch() {
//     setState(() {
//       _searchQuery = '';
//       _searchController.clear();
//     });
//   }

//   void _clearFilters() {
//     setState(() {
//       _filters.clear();
//       _showFilters = false;
//     });
//   }

//   void _navigateToEventDetails(String eventId, Map<String, dynamic> eventData) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => EventDetailsScreen(
//           eventId: eventId,
//           eventData: eventData,
//         ),
//       ),
//     );
//   }
// }
