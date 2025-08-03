import 'package:flutter/material.dart';
import 'user_home_screen.dart';
import 'user_book_ticket_screen.dart';
import 'user_profile_screen.dart';

class UserBottomNav extends StatefulWidget {
  const UserBottomNav({super.key});

  @override
  State<UserBottomNav> createState() => _UserBottomNavState();
}

class _UserBottomNavState extends State<UserBottomNav> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    UserHomeScreen(),        
    UserBookTicketScreen(),  
    UserProfileScreen(),     
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Tickets'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
