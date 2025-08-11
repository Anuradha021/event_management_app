// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../../../models/ticket_model.dart';
// import '../../../services/ticket_service.dart';

// class SimpleTicketPurchaseWidget extends StatefulWidget {
//   final String eventId;
//   final String eventTitle;

//   const SimpleTicketPurchaseWidget({
//     super.key,
//     required this.eventId,
//     required this.eventTitle,
//   });

//   @override
//   State<SimpleTicketPurchaseWidget> createState() => _SimpleTicketPurchaseWidgetState();
// }

// class _SimpleTicketPurchaseWidgetState extends State<SimpleTicketPurchaseWidget> {
//   TicketConfig? _ticketConfig;
//   bool _isLoading = true;
//   bool _isPurchasing = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadTicketConfig();
//   }

//   Future<void> _loadTicketConfig() async {
//     setState(() => _isLoading = true);
//     try {
//       final config = await TicketService.getTicketConfig(widget.eventId);
//       if (mounted) {
//         setState(() => _ticketConfig = config);
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error loading tickets: $e')),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   Future<void> _purchaseTicket() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please log in to purchase tickets')),
//       );
//       return;
//     }

//     setState(() => _isPurchasing = true);

//     try {
//       final ticketId = await TicketService.purchaseTicket(
//         eventId: widget.eventId,
//         userId: user.uid,
//         userName: user.displayName ?? 'User',
//         userEmail: user.email ?? '',
//         ticketType: 'regular',
//         price: _ticketConfig!.regularTicket.price,
//       );

//       if (ticketId != null) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Ticket purchased successfully!'),
//               backgroundColor: Colors.green,
//             ),
//           );
          
//           // Refresh config to update remaining tickets
//           await _loadTicketConfig();
          
//           // Show success dialog
//           _showPurchaseSuccessDialog(ticketId);
//         }
//       } else {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Failed to purchase ticket. Please try again.'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e')),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isPurchasing = false);
//       }
//     }
//   }

//   void _showPurchaseSuccessDialog(String ticketId) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         title: const Row(
//           children: [
//             Icon(Icons.check_circle, color: Colors.green),
//             SizedBox(width: 8),
//             Text('Purchase Successful!'),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Your ticket for "${widget.eventTitle}" has been purchased successfully.'),
//             const SizedBox(height: 12),
//             Text('Ticket ID: $ticketId'),
//             const SizedBox(height: 8),
//             const Text('You can view your ticket with QR code in the "My Tickets" section.'),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Card(
//         margin: EdgeInsets.all(16),
//         child: Padding(
//           padding: EdgeInsets.all(32),
//           child: Center(child: CircularProgressIndicator()),
//         ),
//       );
//     }

//     if (_ticketConfig == null || !_ticketConfig!.isTicketingEnabled) {
//       return const Card(
//         margin: EdgeInsets.all(16),
//         child: Padding(
//           padding: EdgeInsets.all(20),
//           child: Center(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(Icons.info_outline, size: 48, color: Colors.grey),
//                 SizedBox(height: 12),
//                 Text(
//                   'Tickets not available',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.grey,
//                   ),
//                 ),
//                 SizedBox(height: 8),
//                 Text(
//                   'Ticketing is not enabled for this event',
//                   style: TextStyle(color: Colors.grey),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }

//     final ticket = _ticketConfig!.regularTicket;
//     final isAvailable = ticket.isEnabled && ticket.remainingQuantity > 0;

//     return Card(
//       margin: const EdgeInsets.all(16),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header
//             const Row(
//               children: [
//                 Icon(Icons.confirmation_number, color: Colors.blue, size: 28),
//                 SizedBox(width: 12),
//                 Text(
//                   'Purchase Ticket',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
            
//             const SizedBox(height: 20),
            
//             // Ticket info
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: isAvailable ? Colors.blue.shade50 : Colors.grey.shade100,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: isAvailable ? Colors.blue.shade200 : Colors.grey.shade300,
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.local_activity,
//                         color: isAvailable ? Colors.blue : Colors.grey,
//                         size: 24,
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text(
//                               'Event Ticket',
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               widget.eventTitle,
//                               style: TextStyle(
//                                 color: Colors.grey.shade600,
//                                 fontSize: 14,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Text(
//                         '₹${ticket.price.toStringAsFixed(2)}',
//                         style: TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: isAvailable ? Colors.green : Colors.grey,
//                         ),
//                       ),
//                     ],
//                   ),
                  
//                   const SizedBox(height: 16),
                  
//                   // Availability info
//                   Row(
//                     children: [
//                       Icon(
//                         isAvailable ? Icons.check_circle : Icons.cancel,
//                         color: isAvailable ? Colors.green : Colors.red,
//                         size: 16,
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         isAvailable 
//                             ? '${ticket.remainingQuantity} tickets available'
//                             : 'Sold out',
//                         style: TextStyle(
//                           color: isAvailable ? Colors.green : Colors.red,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
            
//             const SizedBox(height: 20),
            
//             // Purchase button
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: (isAvailable && !_isPurchasing) ? _purchaseTicket : null,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: _isPurchasing
//                     ? const SizedBox(
//                         height: 20,
//                         width: 20,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                         ),
//                       )
//                     : Text(
//                         isAvailable ? 'Purchase Ticket' : 'Sold Out',
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//               ),
//             ),
            
//             if (isAvailable) ...[
//               const SizedBox(height: 12),
//               Text(
//                 'Note: You will receive a QR code ticket that can be used for event entry.',
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey.shade600,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
