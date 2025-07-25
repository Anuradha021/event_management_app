// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class EventDashboardScreen extends StatefulWidget {
//   final String eventId;

//   const EventDashboardScreen({Key? key, required this.eventId}) : super(key: key);

//   @override
//   State<EventDashboardScreen> createState() => _EventDashboardScreenState();
// }

// class _EventDashboardScreenState extends State<EventDashboardScreen> {
//   String selectedZoneId = 'defaultZone';
//   String selectedTrackId = 'defaultTrack';

//   List<DropdownMenuItem<String>> zoneItems = [];
//   List<DropdownMenuItem<String>> trackItems = [];

//   @override
//   void initState() {
//     super.initState();
//     loadZones();
//     loadTracks();
//   }

//   Future<void> loadZones() async {
//     final snapshot = await FirebaseFirestore.instance
//         .collection('events')
//         .doc(widget.eventId)
//         .collection('zones')
//         .get();

//     List<DropdownMenuItem<String>> items = [
//       DropdownMenuItem(value: 'defaultZone', child: Text('Default Zone')),
//     ];

//     for (var doc in snapshot.docs) {
//       items.add(DropdownMenuItem(value: doc.id, child: Text(doc['name'] ?? 'Unnamed Zone')));
//     }

//     setState(() {
//       zoneItems = items;
//     });
//   }

//   Future<void> loadTracks() async {
//     final snapshot = await FirebaseFirestore.instance
//         .collection('events')
//         .doc(widget.eventId)
//         .collection('zones')
//         .doc(selectedZoneId)
//         .collection('tracks')
//         .get();

//     List<DropdownMenuItem<String>> items = [
//       DropdownMenuItem(value: 'defaultTrack', child: Text('Default Track')),
//     ];

//     for (var doc in snapshot.docs) {
//       items.add(DropdownMenuItem(value: doc.id, child: Text(doc['name'] ?? 'Unnamed Track')));
//     }

//     setState(() {
//       trackItems = items;
//     });
//   }

//   void handleProceed() {
//     // Store selectedZoneId and selectedTrackId in Firestore or use in navigation
//     print('Selected Zone: $selectedZoneId');
//     print('Selected Track: $selectedTrackId');

//     // Proceed to SessionScreen or next step with selected IDs
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Event Dashboard")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Text("Select Zone"),
//             DropdownButton<String>(
//               value: selectedZoneId,
//               items: zoneItems,
//               onChanged: (value) {
//                 if (value != null) {
//                   setState(() {
//                     selectedZoneId = value;
//                     selectedTrackId = 'defaultTrack'; // reset
//                     loadTracks(); // refresh track list based on new zone
//                   });
//                 }
//               },
//             ),
//             SizedBox(height: 20),
//             Text("Select Track"),
//             DropdownButton<String>(
//               value: selectedTrackId,
//               items: trackItems,
//               onChanged: (value) {
//                 if (value != null) {
//                   setState(() {
//                     selectedTrackId = value;
//                   });
//                 }
//               },
//             ),
//             SizedBox(height: 40),
//             ElevatedButton(
//               onPressed: handleProceed,
//               child: Text("Proceed to Sessions"),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
