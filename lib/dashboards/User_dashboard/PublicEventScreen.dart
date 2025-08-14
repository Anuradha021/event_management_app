// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class PublicEventScreen extends StatelessWidget {
//   final String eventId;
//   const PublicEventScreen({super.key, required this.eventId});

//   Future<Map<String, dynamic>?> fetchEventDetails() async {
//     final doc = await FirebaseFirestore.instance.collection('events').doc(eventId).get();
//     return doc.data();
//   }

//   Future<List<Map<String, dynamic>>> fetchSessions() async {
//     final query = await FirebaseFirestore.instance
//         .collection('sessions')
//         .where('eventId', isEqualTo: eventId)
//         .get();

//     return query.docs.map((doc) {
//       final data = doc.data();
//       data['id'] = doc.id;
//       return data;
//     }).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Event Details")),
//       body: FutureBuilder(
//         future: Future.wait([fetchEventDetails(), fetchSessions()]),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

//           final eventData = snapshot.data![0] as Map<String, dynamic>;
//           final sessions = snapshot.data![1] as List<Map<String, dynamic>>;

//           return SingleChildScrollView(
//             padding: EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(eventData['eventName'] ?? "No Title", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//                 Text(eventData['description'] ?? "No Description"),
//                 SizedBox(height: 20),
//                 Text("Sessions", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
//                 ...sessions.map((session) {
//                   return Card(
//                     margin: EdgeInsets.symmetric(vertical: 8),
//                     child: ListTile(
//                       title: Text(session['sessionName'] ?? "Unnamed Session"),
//                       subtitle: Text("Speaker: ${session['speaker'] ?? "Unknown"}\nTime: ${session['time'] ?? "TBD"}"),
//                     ),
//                   );
//                 }).toList()
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
