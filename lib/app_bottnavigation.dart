import 'package:business_finder/src/pages/business_list_page.dart';
import 'package:business_finder/src/pages/map_page.dart';
import 'package:business_finder/src/pages/profile_page.dart';
import 'package:business_finder/src/pages/vendor_dashboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BottomNavBarScreen extends ConsumerStatefulWidget {
  const BottomNavBarScreen({super.key});

  @override
  _BottomNavBarScreenState createState() => _BottomNavBarScreenState();
}

class _BottomNavBarScreenState extends ConsumerState<BottomNavBarScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const MapPage(),
    const VendorDashboard(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex.clamp(0, _pages.length - 1), // Ensure valid index.
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        unselectedItemColor: Colors.black87,
        selectedItemColor: Colors.red,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        iconSize: 24,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.bag),
            label: 'Tender',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_circle),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
