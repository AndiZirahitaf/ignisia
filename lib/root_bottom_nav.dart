import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:elearning/home.dart';
import 'package:elearning/mycourses.dart';
import 'package:elearning/profile.dart';

class RootWithBottomNav extends StatefulWidget {
  final int? initialIndex;
  const RootWithBottomNav({super.key, this.initialIndex});

  @override
  State<RootWithBottomNav> createState() => _RootWithBottomNavState();
}

class _RootWithBottomNavState extends State<RootWithBottomNav> {
  int _selectedIndex = 0;

  final List<Widget> _pages = <Widget>[Home(), MyCourses(), ProfilePage()];

  @override
  void initState() {
    super.initState();
    if (widget.initialIndex != null) {
      _selectedIndex = widget.initialIndex!;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w400,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w400,
          fontSize: 12,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.book),
            label: 'My Courses',
            activeIcon: Icon(CupertinoIcons.book_fill),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            label: 'Profile',
            activeIcon: Icon(CupertinoIcons.person_fill),
          ),
        ],
      ),
    );
  }
}
