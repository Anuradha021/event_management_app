// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class CreateSpaceScreen extends StatefulWidget {
//   final String eventId;
//   final String subEventId;
//   final String trackId;
//   final String zoneId;

//   const CreateSpaceScreen({
//     super.key,
//     required this.eventId,
//     required this.subEventId,
//     required this.trackId,
//     required this.zoneId,
//   });

//   @override
//   State<CreateSpaceScreen> createState() => _CreateSpaceScreenState();
// }

// class _CreateSpaceScreenState extends State<CreateSpaceScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _spaceTitleController = TextEditingController();
//   final TextEditingController _spaceDescController = TextEditingController();
//   bool _isSubmitting = false;

//   Future<void> _submitSpace() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isSubmitting = true);

//     try {
//       await FirebaseFirestore.instance
//           .collection('events')
//           .doc(widget.eventId)
//           .collection('subEvents')
//           .doc(widget.subEventId)
//           .collection('tracks')
//           .doc(widget.trackId)
//           .collection('zones')
//           .doc(widget.zoneId)
//           .collection('spaces')
//           .add({
//         'spaceTitle': _spaceTitleController.text.trim(),
//         'spaceDescription': _spaceDescController.text.trim(),
//         'createdAt': Timestamp.now(),
//       });

//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Space Created')));
//       Navigator.pop(context, true);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
//     } finally {
//       setState(() => _isSubmitting = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Create Space')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: _spaceTitleController,
//                 decoration: const InputDecoration(labelText: 'Space Title'),
//                 validator: (value) => value!.isEmpty ? 'Required' : null,
//               ),
//               const SizedBox(height: 10),
//               TextFormField(
//                 controller: _spaceDescController,
//                 decoration: const InputDecoration(labelText: 'Space Description'),
//                 maxLines: 3,
//                 validator: (value) => value!.isEmpty ? 'Required' : null,
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _isSubmitting ? null : _submitSpace,
//                 child: _isSubmitting ? const CircularProgressIndicator() : const Text('Create Space'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
