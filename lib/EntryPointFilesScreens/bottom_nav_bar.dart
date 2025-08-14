import 'package:event_management_app1/EntryPointFiles/entry_point_screen.dart';
import 'package:event_management_app1/EntryPointFilesScreens/home.dart';
import 'package:event_management_app1/EntryPointFilesScreens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  late List<Widget> pages;
  late Home home;
  late EntryPointScreen contactForm;
  late ProfileScreen profile;

  int currentTabIndex = 0;

  @override
  void initState() {
    home = Home();
    contactForm = EntryPointScreen();
    profile = ProfileScreen();
    pages = [home, contactForm, profile]; 
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        height: 65,
        backgroundColor: Colors.white,
        color: Colors.black,
        animationDuration: const Duration(milliseconds: 500),
        onTap: (int index) {
          setState(() {
            currentTabIndex = index;
          });
        },
        items: const [
          Icon(Icons.home_outlined, color: Colors.white, size: 30),
          Icon(Icons.contact_mail_outlined, color: Colors.white, size: 30), 
          Icon(Icons.person_outline, color: Colors.white, size: 30),
        ],
      ),
      body: pages[currentTabIndex],
    );
  }
}
