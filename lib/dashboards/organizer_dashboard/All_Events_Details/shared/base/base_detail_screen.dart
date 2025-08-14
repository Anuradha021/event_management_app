import 'package:flutter/material.dart';
import '../widgets/detail_info_card.dart';
import '../widgets/action_button.dart';
import '../widgets/update_dialog.dart';

abstract class BaseDetailScreen<T> extends StatefulWidget {
  final String eventId;
  final Map<String, dynamic> initialData;

  const BaseDetailScreen({
    super.key,
    required this.eventId,
    required this.initialData,
  });
}

abstract class BaseDetailScreenState<T extends BaseDetailScreen> extends State<T> {
  Map<String, dynamic> _currentData = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentData = Map<String, dynamic>.from(widget.initialData);
  }

  String get screenTitle;
  IconData get screenIcon;
  Color get screenIconColor;
  String get itemName;
  String get itemDescription;
  List<UpdateDialogField> get updateFields;
  Future<void> refreshData();
  Future<void> updateData(Map<String, String> values);
  Future<void> deleteData();

  
  List<Widget> get additionalInfoWidgets => [];


  Future<void> _showUpdateDialog() async {
    await showDialog(
      context: context,
      builder: (context) => UpdateDialog(
        title: 'Update $screenTitle',
        fields: updateFields,
        onUpdate: _handleUpdate,
      ),
    );
  }

 
  Future<void> _handleUpdate(Map<String, String> values) async {
    try {
      await updateData(values);
      await refreshData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$screenTitle updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating $screenTitle: $e')),
        );
      }
      rethrow;
    }
  }

  
  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete $screenTitle'),
        content: Text('Are you sure you want to delete this .'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await deleteData();
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$screenTitle deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting $screenTitle: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: screenIconColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
        title: Text(
          screenTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
           
            DetailInfoCard(
              icon: screenIcon,
              iconColor: screenIconColor,
              title: itemName,
              description: itemDescription,
              additionalInfo: additionalInfoWidgets,
            ),

           
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  UpdateButton(
                    onPressed: _isLoading ? null : _showUpdateDialog,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 12),
                  DeleteButton(
                    onPressed: _isLoading ? null : _handleDelete,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
