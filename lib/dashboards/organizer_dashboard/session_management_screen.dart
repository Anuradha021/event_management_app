// import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/CreateSessionScreen.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class SessionManagementScreen extends StatelessWidget {
//   final String eventId;
//   final String zoneId;
//   final String trackId;

//   const SessionManagementScreen({
//     super.key,
//     required this.eventId,
//     required this.zoneId,
//     required this.trackId,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Manage Sessions')),
//       floatingActionButton: FloatingActionButton(
//         child: const Icon(Icons.add),
//         onPressed: () => Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => CreateSessionScreen(
//               eventId: eventId,
//               zoneId: zoneId,
//               trackId: trackId,
//             ),
//           ),
//         ),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('events')
//             .doc(eventId)
//             .collection('zones')
//             .doc(zoneId)
//             .collection('tracks')
//             .doc(trackId)
//             .collection('sessions')
//             .orderBy('createdAt')
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }

//           if (snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text('No sessions found'));
//           }

//           return ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: snapshot.data!.docs.length,
//             itemBuilder: (context, index) {
//               final session = snapshot.data!.docs[index];
//               return Card(
//                 margin: const EdgeInsets.only(bottom: 12),
//                 child: ListTile(
//                   title: Text(session['title']),
//                   subtitle: Text(session['speaker'] ?? 'No speaker'),
//                   trailing: const Icon(Icons.chevron_right),
//                   onTap: () {
//                     // Navigate to session details
//                   },
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }