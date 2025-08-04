// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:qr_flutter/qr_flutter.dart';

// class CreateTicketScreen extends StatefulWidget {
//   final String eventId;
//   final String? sessionId;  

//   const CreateTicketScreen({
//     super.key,
//     required this.eventId,
//     this.sessionId,
//   });

//   @override
//   State<CreateTicketScreen> createState() => _CreateTicketScreenState();
// }

// class _CreateTicketScreenState extends State<CreateTicketScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final ticketTypeController = TextEditingController();
//   final priceController = TextEditingController();
//   final limitController = TextEditingController();

//   String? qrData;

//   Future<void> _createTicket() async {
//     if (_formKey.currentState!.validate()) {
//       final docRef = FirebaseFirestore.instance.collection('tickets').doc();
//       final String generatedQR = docRef.id; //Unique id of firestore doc.

//       await docRef.set({
//         'ticketType': ticketTypeController.text.trim(),
//         'price': double.tryParse(priceController.text) ?? 0.0,
//         'limit': int.tryParse(limitController.text) ?? 0,
//         'qrCodeData': generatedQR,
//         'eventId': widget.eventId,
//         'sessionId': widget.sessionId ?? '',
//         'createdAt': FieldValue.serverTimestamp(),
//       });

//       setState(() {
//         qrData = generatedQR;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Ticket Created Successfully!')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Create Ticket')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: SingleChildScrollView(
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 TextFormField(
//                   controller: ticketTypeController,
//                   decoration: const InputDecoration(labelText: 'Ticket Type (VIP, Regular)'),
//                   validator: (value) => value!.isEmpty ? 'Required' : null,
//                 ),
//                 const SizedBox(height: 10),
//                 TextFormField(
//                   controller: priceController,
//                   decoration: const InputDecoration(labelText: 'Price'),
//                   keyboardType: TextInputType.number,
//                   validator: (value) => value!.isEmpty ? 'Required' : null,
//                 ),
//                 const SizedBox(height: 10),
//                 TextFormField(
//                   controller: limitController,
//                   decoration: const InputDecoration(labelText: 'Limit'),
//                   keyboardType: TextInputType.number,
//                   validator: (value) => value!.isEmpty ? 'Required' : null,
//                 ),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: _createTicket,
//                   child: const Text('Create Ticket'),
//                 ),
//                 const SizedBox(height: 20),
//                 if (qrData != null)
//                   Column(
//                     children: [
//                       const Text('QR Code:', style: TextStyle(fontSize: 16)),
//                       const SizedBox(height: 10),
//                       QrImageView(
//                         data: qrData!,
//                         version: QrVersions.auto,
//                         size: 200.0,
//                       ),
//                     ],
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
