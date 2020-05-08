import 'package:flutter/material.dart';
import 'AccountManagement.dart';
import 'TaskOverviewTab/TaskOverview.dart';

class DashboardScreen extends StatefulWidget {
  @override
  createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Widget> _screens = [
    TaskOverview(),
    AccountManagement(),
    Scaffold(),
  ];
  int _currentIndex = 0;

  onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text("Home"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title: Text("Profile"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.phone),
            title: Text("Contact"),
          )
        ],
      ),
    );
  }
}