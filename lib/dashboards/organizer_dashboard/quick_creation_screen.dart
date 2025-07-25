// import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/CreateSessionScreen.dart';
// import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/create_stall_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'firestore_hierarchy_helper.dart';


// class QuickCreationScreen extends StatefulWidget {
//   final String eventId;

//   const QuickCreationScreen({super.key, required this.eventId});

//   @override
//   State<QuickCreationScreen> createState() => _QuickCreationScreenState();
// }

// class _QuickCreationScreenState extends State<QuickCreationScreen> {
//   late Map<String, String> hierarchy;
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _initializeHierarchy();
//   }

//   Future<void> _initializeHierarchy() async {
//     hierarchy = await FirestoreHierarchyHelper.ensureHierarchy(
//       eventId: widget.eventId,
//     );
//     setState(() => isLoading = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Quick Creation')),
//       body: isLoading ? _buildLoading() : _buildContent(),
//     );
//   }

//   Widget _buildLoading() {
//     return const Center(child: CircularProgressIndicator());
//   }

//   Widget _buildContent() {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           const Text('Using default zone and track for quick creation',
//               style: TextStyle(fontStyle: FontStyle.italic)),
//           const SizedBox(height: 24),
//           _buildCreationButton(
//             icon: Icons.schedule,
//             label: 'Create New Session',
//             onPressed: () => Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => CreateSessionScreen(
//                   eventId: widget.eventId,
//                   zoneId: hierarchy['zoneId']!,
//                   trackId: hierarchy['trackId']!,
//                   isQuickCreate: true,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           _buildCreationButton(
//             icon: Icons.store,
//             label: 'Create New Stall',
//             onPressed: () => Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => CreateStallScreen(
//                   eventId: widget.eventId,
//                   zoneId: hierarchy['zoneId']!,
//                   trackId: hierarchy['trackId']!,
//                   isQuickCreate: true,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCreationButton({
//     required IconData icon,
//     required String label,
//     required VoidCallback onPressed,
//   }) {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton.icon(
//         icon: Icon(icon),
//         label: Text(label),
//         onPressed: onPressed,
//       ),
//     );
//   }
// }