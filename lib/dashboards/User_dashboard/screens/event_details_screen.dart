// import 'package:event_management_app1/widgets/ticket_purchase_section.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import '../../../core/theme/app_theme.dart';
// import '../../../core/widgets/modern_card.dart';
// import '../../../core/widgets/empty_state.dart';
// import '../widgets/simple_ticket_purchase_widget.dart';
// // import '../widgets/hierarchy_browser.dart'; // Will be created next
// // import 'zone_browser_screen.dart'; // Will be created next

// /// Detailed view of a specific event showing all its components
// class EventDetailsScreen extends StatefulWidget {
//   final String eventId;
//   final Map<String, dynamic> eventData;

//   const EventDetailsScreen({
//     super.key,
//     required this.eventId,
//     required this.eventData,
//   });

//   @override
//   State<EventDetailsScreen> createState() => _EventDetailsScreenState();
// }

// class _EventDetailsScreenState extends State<EventDetailsScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
  
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 4, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.backgroundColor,
//       body: CustomScrollView(
//         slivers: [
//           // App bar with event header
//           _buildSliverAppBar(),
          
//           // Event details content
//           SliverToBoxAdapter(
//             child: Column(
//               children: [
//                 // Event info card
//                 _buildEventInfoCard(),
                
//                 // Tab navigation
//                 _buildTabNavigation(),
                
//                 // Tab content
//                 SizedBox(
//                   height: 600, // Fixed height for tab content
//                   child: TabBarView(
//                     controller: _tabController,
//                     children: [
//                       _buildOverviewTab(),
//                       _buildZonesTab(),
//                       _buildSessionsTab(),
//                       _buildStallsTab(),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSliverAppBar() {
//     return SliverAppBar(
//       expandedHeight: 200,
//       pinned: true,
//       backgroundColor: AppTheme.primaryColor,
//       foregroundColor: Colors.white,
//       flexibleSpace: FlexibleSpaceBar(
//         title: Text(
//           widget.eventData['eventTitle'] ?? widget.eventData['eventName'] ?? 'Event Details',
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         background: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [
//                 AppTheme.primaryColor,
//                 AppTheme.primaryColor.withValues(alpha: 0.8),
//               ],
//             ),
//           ),
//           child: Stack(
//             children: [
//               // Background pattern
//               Positioned.fill(
//                 child: Opacity(
//                   opacity: 0.1,
//                   child: Container(
//                     decoration: const BoxDecoration(
//                       image: DecorationImage(
//                         image: AssetImage('assets/images/event_pattern.png'),
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
              
//               // Content
//               Positioned(
//                 bottom: 60,
//                 left: 16,
//                 right: 16,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     if (widget.eventData['eventDate'] != null)
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 6,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withValues(alpha: 0.2),
//                           borderRadius: BorderRadius.circular(AppTheme.radiusL),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             const Icon(
//                               Icons.calendar_today,
//                               size: 14,
//                               color: Colors.white,
//                             ),
//                             const SizedBox(width: 6),
//                             Text(
//                               _formatDate(widget.eventData['eventDate']),
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEventInfoCard() {
//     return Container(
//       margin: const EdgeInsets.all(AppTheme.spacingM),
//       child: ModernCard(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Location and organizer
//             Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       if (widget.eventData['location'] != null)
//                         _buildInfoRow(
//                           Icons.location_on_outlined,
//                           widget.eventData['location'],
//                           AppTheme.secondaryColor,
//                         ),
                      
//                       const SizedBox(height: 8),
                      
//                       if (widget.eventData['organizerName'] != null)
//                         _buildInfoRow(
//                           Icons.person_outline,
//                           'Organized by ${widget.eventData['organizerName']}',
//                           AppTheme.textSecondary,
//                         ),
//                     ],
//                   ),
//                 ),
                
//                 // Status badge
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 6,
//                   ),
//                   decoration: BoxDecoration(
//                     color: AppTheme.successColor.withValues(alpha: 0.1),
//                     borderRadius: BorderRadius.circular(AppTheme.radiusL),
//                     border: Border.all(
//                       color: AppTheme.successColor.withValues(alpha: 0.3),
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         Icons.check_circle_outline,
//                         size: 14,
//                         color: AppTheme.successColor,
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         'Published',
//                         style: AppTheme.bodySmall.copyWith(
//                           color: AppTheme.successColor,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
            
//             const SizedBox(height: AppTheme.spacingM),
            
//             // Description
//             if (widget.eventData['description'] != null &&
//                 widget.eventData['description'].isNotEmpty)
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'About this event',
//                     style: AppTheme.labelLarge,
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     widget.eventData['description'],
//                     style: AppTheme.bodyMedium,
//                   ),
//                   const SizedBox(height: AppTheme.spacingM),
//                 ],
//               ),
            
//             // Quick stats
//             _buildQuickStats(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoRow(IconData icon, String text, Color color) {
//     return Row(
//       children: [
//         Icon(icon, size: 16, color: color),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Text(
//             text,
//             style: AppTheme.bodyMedium.copyWith(color: color),
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildQuickStats() {
//     return Container(
//       padding: const EdgeInsets.all(AppTheme.spacingM),
//       decoration: BoxDecoration(
//         color: AppTheme.surfaceColor,
//         borderRadius: BorderRadius.circular(AppTheme.radiusM),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _buildStatItem('Zones', Icons.map_outlined, AppTheme.primaryColor),
//           _buildStatItem('Tracks', Icons.timeline_outlined, AppTheme.secondaryColor),
//           _buildStatItem('Sessions', Icons.schedule_outlined, AppTheme.accentColor),
//           _buildStatItem('Stalls', Icons.store_outlined, AppTheme.warningColor),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatItem(String label, IconData icon, Color color) {
//     return Column(
//       children: [
//         Container(
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(
//             color: color.withValues(alpha: 0.1),
//             borderRadius: BorderRadius.circular(AppTheme.radiusM),
//           ),
//           child: Icon(icon, color: color, size: 20),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           label,
//           style: AppTheme.bodySmall.copyWith(
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         StreamBuilder<QuerySnapshot>(
//           stream: _getCountStream(label.toLowerCase()),
//           builder: (context, snapshot) {
//             final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
//             return Text(
//               count.toString(),
//               style: AppTheme.bodySmall.copyWith(
//                 color: color,
//                 fontWeight: FontWeight.bold,
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildTabNavigation() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(AppTheme.radiusL),
//         boxShadow: AppTheme.cardShadow,
//       ),
//       child: TabBar(
//         controller: _tabController,
//         labelColor: AppTheme.primaryColor,
//         unselectedLabelColor: AppTheme.textSecondary,
//         indicator: BoxDecoration(
//           color: AppTheme.primaryColor.withValues(alpha: 0.1),
//           borderRadius: BorderRadius.circular(AppTheme.radiusL),
//         ),
//         indicatorSize: TabBarIndicatorSize.tab,
//         dividerColor: Colors.transparent,
//         tabs: const [
//           Tab(text: 'Overview'),
//           Tab(text: 'Zones'),
//           Tab(text: 'Sessions'),
//           Tab(text: 'Stalls'),
//         ],
//       ),
//     );
//   }

//   Widget _buildOverviewTab() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(AppTheme.spacingM),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Ticket Purchase Section
//           TicketPurchaseSection(
//             eventId: widget.eventId,
//             eventData: widget.eventData,
//           ),

//           const SizedBox(height: AppTheme.spacingL),

//           Text(
//             'Event Structure',
//             style: AppTheme.headingSmall,
//           ),
//           const SizedBox(height: AppTheme.spacingM),

//           // HierarchyBrowser will be implemented next
//           Container(
//             padding: const EdgeInsets.all(AppTheme.spacingL),
//             decoration: BoxDecoration(
//               color: AppTheme.surfaceColor,
//               borderRadius: BorderRadius.circular(AppTheme.radiusM),
//             ),
//             child: Column(
//               children: [
//                 Icon(
//                   Icons.account_tree_outlined,
//                   size: 48,
//                   color: AppTheme.textTertiary,
//                 ),
//                 const SizedBox(height: AppTheme.spacingM),
//                 Text(
//                   'Event Hierarchy Browser',
//                   style: AppTheme.bodyLarge.copyWith(
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: AppTheme.spacingS),
//                 Text(
//                   'Interactive hierarchy browser coming soon',
//                   style: AppTheme.bodyMedium,
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildZonesTab() {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('events')
//           .doc(widget.eventId)
//           .collection('zones')
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
        
//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return const EmptyState(
//             icon: Icons.map_outlined,
//             title: 'No zones available',
//             subtitle: 'This event doesn\'t have any zones yet',
//           );
//         }
        
//         return ListView.builder(
//           padding: const EdgeInsets.all(AppTheme.spacingM),
//           itemCount: snapshot.data!.docs.length,
//           itemBuilder: (context, index) {
//             final doc = snapshot.data!.docs[index];
//             final zoneData = doc.data() as Map<String, dynamic>;
            
//             return ModernCard(
//               onTap: () => _navigateToZone(doc.id, zoneData),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 48,
//                     height: 48,
//                     decoration: BoxDecoration(
//                       color: AppTheme.primaryColor.withValues(alpha: 0.1),
//                       borderRadius: BorderRadius.circular(AppTheme.radiusM),
//                     ),
//                     child: const Icon(
//                       Icons.map_outlined,
//                       color: AppTheme.primaryColor,
//                       size: 24,
//                     ),
//                   ),
//                   const SizedBox(width: AppTheme.spacingM),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           zoneData['title'] ?? 'Unnamed Zone',
//                           style: AppTheme.labelLarge,
//                         ),
//                         if (zoneData['description'] != null)
//                           Text(
//                             zoneData['description'],
//                             style: AppTheme.bodyMedium,
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                       ],
//                     ),
//                   ),
//                   const Icon(
//                     Icons.arrow_forward_ios,
//                     color: AppTheme.textTertiary,
//                     size: 16,
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildSessionsTab() {
//     // Implementation for sessions tab
//     return const Center(
//       child: Text('Sessions content will be implemented'),
//     );
//   }

//   Widget _buildStallsTab() {
//     // Implementation for stalls tab
//     return const Center(
//       child: Text('Stalls content will be implemented'),
//     );
//   }

//   Stream<QuerySnapshot> _getCountStream(String collection) {
//     return FirebaseFirestore.instance
//         .collection('events')
//         .doc(widget.eventId)
//         .collection(collection)
//         .snapshots();
//   }

//   String _formatDate(dynamic date) {
//     try {
//       DateTime dateTime;
//       if (date is String) {
//         dateTime = DateTime.parse(date);
//       } else if (date.runtimeType.toString().contains('Timestamp')) {
//         dateTime = date.toDate();
//       } else if (date is DateTime) {
//         dateTime = date;
//       } else {
//         return 'Date TBD';
//       }
      
//       return DateFormat('EEEE, MMMM dd, yyyy').format(dateTime);
//     } catch (e) {
//       return 'Date TBD';
//     }
//   }

//   void _navigateToZone(String zoneId, Map<String, dynamic> zoneData) {
//     // Zone browser navigation will be implemented when ZoneBrowserScreen is created
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Zone browser for "${zoneData['title']}" coming soon!'),
//         backgroundColor: AppTheme.primaryColor,
//       ),
//     );
//   }
// }
