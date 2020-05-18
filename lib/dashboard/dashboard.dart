import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../util/localization.dart';
import 'account_management.dart';
import 'task_overview_tab/task_overview.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<Widget> _screens = [
    ChangeNotifierProvider(
      create: (context) => TaskOverviewModel(),
      child: TaskOverview(),
    ),
    AccountManagement(),
    Scaffold(),
  ];
  int _currentIndex = 0;

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Nof1Localizations.of(context).translate('dashboard')),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text(Nof1Localizations.of(context).translate('home')),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title: Text(Nof1Localizations.of(context).translate('profile')),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.phone),
            title: Text(Nof1Localizations.of(context).translate('contact')),
          )
        ],
      ),
    );
  }
}
