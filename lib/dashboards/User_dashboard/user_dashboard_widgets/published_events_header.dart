import 'package:flutter/material.dart';

class PublishedEventsHeader extends StatelessWidget {
  final int count;
  const PublishedEventsHeader({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      color: Colors.green[100],
      child: Text(
        'Found $count events',
        style: const TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
