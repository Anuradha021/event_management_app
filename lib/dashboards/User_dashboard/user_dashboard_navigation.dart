// import 'package:flutter/material.dart';
// import '../../core/theme/app_theme.dart';
// import 'screens/event_list_screen.dart';
// import 'user_screens/UserBottomNav.dart';

// /// Navigation helper for user dashboard
// class UserDashboardNavigation {
//   /// Navigate to user dashboard
//   static void navigateToUserDashboard(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const UserBottomNav(),
//       ),
//     );
//   }

//   /// Navigate to event list
//   static void navigateToEventList(
//     BuildContext context, {
//     String? searchQuery,
//     bool showSearchBar = false,
//   }) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => EventListScreen(
//           initialSearchQuery: searchQuery,
//           showSearchBar: showSearchBar,
//         ),
//       ),
//     );
//   }

//   /// Create a user dashboard button for integration
//   static Widget createUserDashboardButton(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.all(AppTheme.spacingM),
//       child: ElevatedButton.icon(
//         onPressed: () => navigateToUserDashboard(context),
//         icon: const Icon(Icons.event_available_outlined),
//         label: const Text('Browse Events'),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: AppTheme.primaryColor,
//           foregroundColor: Colors.white,
//           padding: const EdgeInsets.symmetric(
//             horizontal: AppTheme.spacingL,
//             vertical: AppTheme.spacingM,
//           ),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(AppTheme.radiusM),
//           ),
//         ),
//       ),
//     );
//   }
// }
