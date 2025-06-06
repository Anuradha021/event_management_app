import 'package:event_management_app1/features/screens/contact_form.dart';
import 'package:event_management_app1/features/screens/home.dart';
import 'package:event_management_app1/features/screens/profile_screen.dart';
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
  late ContactForm contactForm;
  late ProfileScreen profile;

  int currentTabIndex = 0;

  @override
  void initState() {
    home = Home();
    contactForm = ContactForm(); 
    profile = ProfileScreen();
    pages = [home, contactForm, profile]; // ✅ Set the order
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
          Icon(Icons.contact_mail_outlined, color: Colors.white, size: 30), // ✅ Contact icon
          Icon(Icons.person_outline, color: Colors.white, size: 30),
        ],
      ),
      body: pages[currentTabIndex],
    );
  }
}
