import 'package:event_management_app1/core/theme/app_theme.dart';
import 'package:flutter/material.dart';


class ZoneDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String zoneName;

  const ZoneDetailAppBar({
    super.key,
    required this.zoneName,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor:AppTheme.primaryColor,
      iconTheme: const IconThemeData(color: Colors.white),
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Zone: $zoneName',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
