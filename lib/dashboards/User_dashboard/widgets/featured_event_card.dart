// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../../core/theme/app_theme.dart';
// import '../../../core/widgets/modern_card.dart';


// class FeaturedEventCard extends StatelessWidget {
//   final String eventId;
//   final Map<String, dynamic> eventData;
//   final VoidCallback onTap;

//   const FeaturedEventCard({
//     super.key,
//     required this.eventId,
//     required this.eventData,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ModernCard(
//       onTap: onTap,
//       margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header with featured badge
//           Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   eventData['eventTitle'] ?? eventData['eventName'] ?? 'Unnamed Event',
//                   style: AppTheme.headingSmall,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       AppTheme.accentColor,
//                       AppTheme.accentColor.withValues(alpha: 0.8),
//                     ],
//                   ),
//                   borderRadius: BorderRadius.circular(AppTheme.radiusS),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Icon(
//                       Icons.star,
//                       size: 12,
//                       color: Colors.white,
//                     ),
//                     const SizedBox(width: 4),
//                     Text(
//                       'Featured',
//                       style: AppTheme.bodySmall.copyWith(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
          
//           const SizedBox(height: AppTheme.spacingM),
          
//           // Event details
//           Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Date and time
//                     if (eventData['eventDate'] != null)
//                       _buildInfoRow(
//                         Icons.calendar_today_outlined,
//                         _formatDate(eventData['eventDate']),
//                         AppTheme.primaryColor,
//                       ),
                    
//                     const SizedBox(height: 8),
                    
//                     // Location
//                     if (eventData['location'] != null)
//                       _buildInfoRow(
//                         Icons.location_on_outlined,
//                         eventData['location'],
//                         AppTheme.secondaryColor,
//                       ),
                    
//                     const SizedBox(height: 8),
                    
//                     // Organizer
//                     if (eventData['organizerName'] != null)
//                       _buildInfoRow(
//                         Icons.person_outline,
//                         'By ${eventData['organizerName']}',
//                         AppTheme.textSecondary,
//                       ),
//                   ],
//                 ),
//               ),
              
//               // Event status indicator
//               Container(
//                 width: 60,
//                 height: 60,
//                 decoration: BoxDecoration(
//                   gradient: AppTheme.primaryGradient,
//                   borderRadius: BorderRadius.circular(AppTheme.radiusL),
//                 ),
//                 child: const Icon(
//                   Icons.event_available,
//                   color: Colors.white,
//                   size: 28,
//                 ),
//               ),
//             ],
//           ),
          
//           const SizedBox(height: AppTheme.spacingM),
          
//           // Description
//           if (eventData['description'] != null && eventData['description'].isNotEmpty)
//             Text(
//               eventData['description'],
//               style: AppTheme.bodyMedium,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
          
//           const SizedBox(height: AppTheme.spacingM),
          
//           // Stats row
//           _buildStatsRow(),
          
//           const SizedBox(height: AppTheme.spacingM),
          
//           // Action button
//           Row(
//             children: [
//               Expanded(
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         AppTheme.primaryColor.withValues(alpha: 0.1),
//                         AppTheme.primaryColor.withValues(alpha: 0.05),
//                       ],
//                     ),
//                     borderRadius: BorderRadius.circular(AppTheme.radiusM),
//                     border: Border.all(
//                       color: AppTheme.primaryColor.withValues(alpha: 0.2),
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         'Explore Event',
//                         style: AppTheme.labelLarge.copyWith(
//                           color: AppTheme.primaryColor,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Icon(
//                         Icons.arrow_forward,
//                         size: 16,
//                         color: AppTheme.primaryColor,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
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
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildStatsRow() {
//     return Row(
//       children: [
//         _buildStatItem(Icons.map_outlined, 'Zones', '0'),
//         const SizedBox(width: AppTheme.spacingL),
//         _buildStatItem(Icons.timeline_outlined, 'Tracks', '0'),
//         const SizedBox(width: AppTheme.spacingL),
//         _buildStatItem(Icons.schedule_outlined, 'Sessions', '0'),
//         const Spacer(),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//           decoration: BoxDecoration(
//             color: AppTheme.successColor.withValues(alpha: 0.1),
//             borderRadius: BorderRadius.circular(AppTheme.radiusS),
//           ),
//           child: Text(
//             'Published',
//             style: AppTheme.bodySmall.copyWith(
//               color: AppTheme.successColor,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildStatItem(IconData icon, String label, String count) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(icon, size: 14, color: AppTheme.textTertiary),
//         const SizedBox(width: 4),
//         Text(
//           count,
//           style: AppTheme.bodySmall.copyWith(
//             fontWeight: FontWeight.w500,
//             color: AppTheme.textSecondary,
//           ),
//         ),
//         const SizedBox(width: 2),
//         Text(
//           label,
//           style: AppTheme.bodySmall.copyWith(
//             color: AppTheme.textTertiary,
//           ),
//         ),
//       ],
//     );
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
      
//       return DateFormat('MMM dd, yyyy • h:mm a').format(dateTime);
//     } catch (e) {
//       return 'Date TBD';
//     }
//   }
// }

// /// Compact event card for lists
// class CompactEventCard extends StatelessWidget {
//   final String eventId;
//   final Map<String, dynamic> eventData;
//   final VoidCallback onTap;

//   const CompactEventCard({
//     super.key,
//     required this.eventId,
//     required this.eventData,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ModernCard(
//       onTap: onTap,
//       margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
//       child: Row(
//         children: [
//           // Event icon
//           Container(
//             width: 48,
//             height: 48,
//             decoration: BoxDecoration(
//               gradient: AppTheme.primaryGradient,
//               borderRadius: BorderRadius.circular(AppTheme.radiusM),
//             ),
//             child: const Icon(
//               Icons.event_outlined,
//               color: Colors.white,
//               size: 24,
//             ),
//           ),
          
//           const SizedBox(width: AppTheme.spacingM),
          
//           // Event info
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   eventData['eventTitle'] ?? eventData['eventName'] ?? 'Unnamed Event',
//                   style: AppTheme.labelLarge,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 4),
//                 if (eventData['location'] != null)
//                   Text(
//                     eventData['location'],
//                     style: AppTheme.bodyMedium,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 if (eventData['eventDate'] != null)
//                   Text(
//                     _formatCompactDate(eventData['eventDate']),
//                     style: AppTheme.bodySmall.copyWith(
//                       color: AppTheme.primaryColor,
//                     ),
//                   ),
//               ],
//             ),
//           ),
          
//           // Arrow
//           const Icon(
//             Icons.arrow_forward_ios,
//             color: AppTheme.textTertiary,
//             size: 16,
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatCompactDate(dynamic date) {
//     try {
//       DateTime dateTime;
//       if (date is String) {
//         dateTime = DateTime.parse(date);
//       } else if (date.runtimeType.toString().contains('Timestamp')) {
//         dateTime = date.toDate();
//       } else if (date is DateTime) {
//         dateTime = date;
//       } else {
//         return 'TBD';
//       }
      
//       return DateFormat('MMM dd').format(dateTime);
//     } catch (e) {
//       return 'TBD';
//     }
//   }
// }
