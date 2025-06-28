import 'package:event_management_app1/dashboards/admin/create_event_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


void updateFilter(Function(String) setFilter, String filterValue) {
  setFilter(filterValue);
}

void updateSearchQuery(Function(String) setQuery, String query) {
  setQuery(query.toLowerCase());
}

void navigateToCreateEvent(BuildContext context, Map<String, dynamic> requestData) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CreateEventScreen(requestData: requestData),
    ),
  );
}

Future<void> updateRequestStatus(BuildContext context,String docId,String status) async {
  final url = Uri.parse('http://localhost:3000/reject-event');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'docId': docId}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event rejected successfully.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to reject event: ${response.body}")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error rejecting event: $e")),
    );
  }
}


Future<void> assignOrganizerAndApprove(BuildContext context, String docId) async {
  final url = Uri.parse('http://localhost:3000/approve-event');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'docId': docId}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Approved via backend')),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response.body}')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Server error: $e')),
    );
  }
}