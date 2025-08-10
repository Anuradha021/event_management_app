import 'package:flutter/material.dart';

class UserBookTicketScreen extends StatelessWidget {
  const UserBookTicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Tickets"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Book Tickets Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
