// import 'package:event_management_app1/models/ticket_model.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';


// class TicketManagementScreen extends StatelessWidget {
//   final String eventId;
//   final String eventTitle;

//   const TicketManagementScreen({
//     super.key,
//     required this.eventId,
//     required this.eventTitle,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Tickets - $eventTitle'),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('tickets')
//             .where('eventId', isEqualTo: eventId)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text('No tickets found for this event'));
//           }

//  final tickets = snapshot.data!.docs.map((doc) {
//   final data = doc.data() as Map<String, dynamic>;
//   return TicketModel(
//     id: doc.id,
//     eventId: data['eventId'] ?? '',
//     userId: data['userId'] ?? '',
//     userName: data['userName'] ?? 'Unknown',
//     ticketType: data['ticketType'] ?? 'General',
//     price: (data['price'] ?? 0.0).toDouble(),
//     status: data['status'] ?? 'valid',
//     purchaseDate: data['purchaseDate']?.toDate(), 
//     expiryDate: data['expiryDate']?.toDate(),    
//   );
// }).toList();

//           return ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: tickets.length,
//             itemBuilder: (context, index) {
//               final ticket = tickets[index];
//               return Card(
//                 margin: const EdgeInsets.only(bottom: 16),
//                 child: ListTile(
//                   title: Text('${ticket.ticketType.toUpperCase()} Ticket'),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('Owner: ${ticket.userName}'),
//                       Text('Status: ${ticket.status}'),
//                       Text('Price: \$${ticket.price.toStringAsFixed(2)}'),
//                     ],
//                   ),
//                   trailing: Chip(
//                     label: Text(ticket.status),
//                     backgroundColor: _getStatusColor(ticket.status),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   Color _getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'valid':
//         return Colors.green;
//       case 'used':
//         return Colors.orange;
//       case 'expired':
//         return Colors.red;
//       case 'cancelled':
//         return Colors.grey;
//       default:
//         return Colors.blue;
//     }
//   }
// }