import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/ticket.dart';

class DownloadButton extends StatelessWidget {
  final Ticket ticket;

  const DownloadButton({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("PDF download feature coming soon!"),
            backgroundColor:AppTheme.primaryColor,
          ),
        );
      },
      icon: const Icon(Icons.download),
      label: const Text("Download as PDF"),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
      ),
    );
  }
}
