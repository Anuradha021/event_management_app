// import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/StallManagementScreen.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'firestore_hierarchy_helper.dart';
// import 'session_management_screen.dart';


// class FullHierarchyScreen extends StatefulWidget {
//   final String eventId;

//   const FullHierarchyScreen({super.key, required this.eventId});

//   @override
//   State<FullHierarchyScreen> createState() => _FullHierarchyScreenState();
// }

// class _FullHierarchyScreenState extends State<FullHierarchyScreen> {
//   String? selectedZoneId;
//   String? selectedTrackId;
//   List<Map<String, dynamic>> zones = [];
//   List<Map<String, dynamic>> tracks = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   Future<void> _loadData() async {
//     setState(() => isLoading = true);
    
//     zones = await FirestoreHierarchyHelper.fetchZones(widget.eventId);
//     if (zones.isNotEmpty) {
//       selectedZoneId = zones.first['id'];
//       tracks = await FirestoreHierarchyHelper.fetchTracks(widget.eventId, selectedZoneId!);
//       if (tracks.isNotEmpty) {
//         selectedTrackId = tracks.first['id'];
//       }
//     }
    
//     setState(() => isLoading = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Configure Event Structure')),
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
//           _buildZoneDropdown(),
//           const SizedBox(height: 16),
//           if (selectedZoneId != null) _buildTrackDropdown(),
//           const Spacer(),
//           if (selectedTrackId != null) _buildActionButtons(),
//         ],
//       ),
//     );
//   }

//   Widget _buildZoneDropdown() {
//     return DropdownButtonFormField<String>(
//       value: selectedZoneId,
//       decoration: const InputDecoration(
//         labelText: 'Zone',
//         border: OutlineInputBorder(),
//       ),
//       items: zones.map<DropdownMenuItem<String>>((zone) => DropdownMenuItem<String>(
//         value: zone['id'] as String,
//         child: Text(zone['name']),
//       )).toList(),
//       onChanged: (value) async {
//         setState(() {
//           selectedZoneId = value;
//           selectedTrackId = null;
//           tracks = [];
//         });
//         if (value != null) {
//           tracks = await FirestoreHierarchyHelper.fetchTracks(widget.eventId, value);
//           if (tracks.isNotEmpty) {
//             setState(() => selectedTrackId = tracks.first['id']);
//           }
//         }
//       },
//     );
//   }

//   Widget _buildTrackDropdown() {
//     return DropdownButtonFormField<String>(
//       value: selectedTrackId,
//       decoration: const InputDecoration(
//         labelText: 'Track',
//         border: OutlineInputBorder(),
//       ),
//       items: tracks.map<DropdownMenuItem<String>>((track) => DropdownMenuItem<String>(
//         value: track['id'] as String,
//         child: Text(track['name']),
//       )).toList(),
//       onChanged: (value) => setState(() => selectedTrackId = value),
//     );
//   }

//   Widget _buildActionButtons() {
//     return Column(
//       children: [
//         SizedBox(
//           width: double.infinity,
//           child: ElevatedButton.icon(
//             icon: const Icon(Icons.schedule),
//             label: const Text('Manage Sessions'),
//             onPressed: () => Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => SessionManagementScreen(
//                   eventId: widget.eventId,
//                   zoneId: selectedZoneId!,
//                   trackId: selectedTrackId!,
//                 ),
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 12),
//         SizedBox(
//           width: double.infinity,
//           child: ElevatedButton.icon(
//             icon: const Icon(Icons.store),
//             label: const Text('Manage Stalls'),
//             onPressed: () => Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => StallManagementScreen(
//                   eventId: widget.eventId,
//                   zoneId: selectedZoneId!,
//                   trackId: selectedTrackId!,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }