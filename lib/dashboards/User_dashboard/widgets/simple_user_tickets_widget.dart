// import 'package:event_management_app1/models/ticket_model.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';


// class SimpleUserTicketsWidget extends StatelessWidget {
//   final String userId;

//   const SimpleUserTicketsWidget({
//     super.key,
//     required this.userId,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('My Tickets'),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('tickets')
//             .where('userId', isEqualTo: userId)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.confirmation_number, size: 64),
//                   const SizedBox(height: 16),
//                   const Text('No tickets found'),
//                   TextButton(
//                     onPressed: () => _createTestTicket(context),
//                     child: const Text('Create Test Ticket'),
//                   ),
//                 ],
//               ),
//             );
//           }

//           final tickets = snapshot.data!.docs
//               .map((doc) => TicketModel.fromFirestore(doc))
//               .toList();

//           return ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: tickets.length,
//             itemBuilder: (context, index) {
//               final ticket = tickets[index];
//               return Card(
//                 margin: const EdgeInsets.only(bottom: 16),
//                 child: ListTile(
//                   leading: const Icon(Icons.confirmation_number),
//                   title: Text('${ticket.ticketType.toUpperCase()} Ticket'),
//                   subtitle: Text('Event ID: ${ticket.eventId}'),
//                   trailing: Chip(
//                     label: Text(ticket.status),
//                     backgroundColor: _getStatusColor(ticket.status),
//                   ),
//                   onTap: () => _showTicketDetails(context, ticket),
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

//   Future<void> _createTestTicket(BuildContext context) async {
//     try {
//       await FirebaseFirestore.instance.collection('tickets').add({
//         'eventId': 'test-event',
//         'userId': userId,
//         'userName': 'Test User',
//         'userEmail': 'test@example.com',
//         'ticketType': 'regular',
//         'price': 100.0,
//         'status': 'valid',
//         'qrCode': 'TEST-${DateTime.now().millisecondsSinceEpoch}',
//         'purchaseDate': Timestamp.now(),
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Test ticket created!')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     }
//   }

//   void _showTicketDetails(BuildContext context, TicketModel ticket) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Ticket Details'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Type: ${ticket.ticketType}'),
//             Text('Status: ${ticket.status}'),
//             Text('Price: \$${ticket.price.toStringAsFixed(2)}'),
//             Text('Purchased: ${ticket.purchaseDate != null 
//     ? DateFormat.yMd().format(ticket.purchaseDate!) 
//     : 'Not available'}'),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }
// }