import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GenericListScreen extends StatelessWidget {
  final String title;
  final CollectionReference<Map<String, dynamic>> collectionRef;
  final List<String> displayFields;
  final Widget Function(BuildContext context)? createScreenBuilder;
  final void Function(Map<String, dynamic> itemData, String docId)? onItemTap;

  const GenericListScreen({
    super.key,
    required this.title,
    required this.collectionRef,
    required this.displayFields,
    this.createScreenBuilder,
    this.onItemTap,
  });

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _fetchItems() async {
    final snapshot = await collectionRef.get();
    return snapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: FutureBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
        future: _fetchItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data ?? [];

          return Column(
            children: [
              if (createScreenBuilder != null)
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text('Create $title'),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: createScreenBuilder!));
                  },
                ),
              Expanded(
                child: items.isEmpty
                    ? const Center(child: Text('No items found'))
                    : ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final data = item.data();
                          final docId = item.id;
                          return Card(
                            margin: const EdgeInsets.all(8),
                            child: ListTile(
                              title: Text(data[displayFields[0]] ?? 'No Title'),
                              subtitle: Text(data[displayFields[1]] ?? 'No Description'),
                              onTap: () => onItemTap?.call(data, docId),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
