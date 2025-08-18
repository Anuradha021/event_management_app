import 'package:event_management_app1/dashboards/User_dashboard/user_screens/book_tickit_all_data/book_tickit_screen.dart';
import 'package:event_management_app1/dashboards/User_dashboard/user_screens/user_home_screen.dart';
import 'package:event_management_app1/dashboards/User_dashboard/user_screens/user_profile_all_data/user_profile_screen.dart';
import 'package:event_management_app1/screens/user_tickits_all_data/user_tickets_overview_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class UserBottomNav extends StatefulWidget {
  const UserBottomNav({super.key});

  @override
  State<UserBottomNav> createState() => _UserBottomNavState();
}

class _UserBottomNavState extends State<UserBottomNav> {
  int _currentIndex = 0;
  late final List<Widget> _pages;
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _pages = [
      UserHomeScreen(),
       BookTicketScreen(),
      const UserTicketsOverviewScreen(),
      UserProfileScreen(userId: user?.uid ?? 'default_id'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF5E35B1),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_number), label: 'My Tickets'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}