// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class GenericListScreen extends StatelessWidget {
//   final String title;
//   final CollectionReference<Map<String, dynamic>> collectionRef;
//   final Query<Map<String, dynamic>>? query;
//   final List<String> displayFields;
//   final Widget Function(BuildContext context)? createScreenBuilder;
//   final void Function(Map<String, dynamic> itemData, String docId)? onItemTap;

//   const GenericListScreen({
//     super.key,
//     required this.title,
//     required this.collectionRef,
//     this.query,
//     required this.displayFields,
//     this.createScreenBuilder,
//     this.onItemTap,
//   });

//   Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _fetchItems() async {
//     final snapshot = await (query ?? collectionRef).get();
//     return snapshot.docs;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(title)),
//       floatingActionButton: createScreenBuilder != null
//           ? FloatingActionButton(
//               onPressed: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: createScreenBuilder!),
//               ),
//               child: const Icon(Icons.add),
//             )
//           : null,
//       body: FutureBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
//         future: _fetchItems(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }

//           final items = snapshot.data ?? [];

//           return items.isEmpty
//               ? const Center(child: Text('No items found'))
//               : ListView.builder(
//                   itemCount: items.length,
//                   itemBuilder: (context, index) {
//                     final item = items[index];
//                     final data = item.data();
//                     final docId = item.id;
//                     return Card(
//                       margin: const EdgeInsets.all(8),
//                       child: ListTile(
//                         title: Text(data[displayFields[0]] ?? 'No Title'),
//                         subtitle: displayFields.length > 1
//                             ? Text(data[displayFields[1]] ?? 'No Description')
//                             : null,
//                         onTap: () => onItemTap?.call(data, docId),
//                       ),
//                     );
//                   },
//                 );
//         },
//       ),
//     );
//   }
// }