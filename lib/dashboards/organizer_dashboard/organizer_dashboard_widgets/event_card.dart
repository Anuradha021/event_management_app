// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class EventCard extends StatelessWidget {
//   final Map<String, dynamic> eventData;
//   final VoidCallback onTap;

//   const EventCard({super.key, required this.eventData, required this.onTap});

//   String _formatDate(dynamic timestamp) {
//     if (timestamp is Timestamp) {
//       final date = timestamp.toDate();
//       return '${date.day}-${date.month}-${date.year}';
//     }
//     return 'N/A';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       child: ListTile(
//         title: Text(
//           eventData['eventTitle'] ?? 'Untitled Event',
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         subtitle: Text("Date: ${_formatDate(eventData['eventDate'])}"),
//         trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//         onTap: onTap,
//       ),
//     );
//   }
// }
