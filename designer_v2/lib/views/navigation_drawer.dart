import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_store.dart';

class NavigationDrawer extends StatefulWidget {
  final String title;

  NavigationDrawer({Key? key, required this.title}) : super(key: key);

  @override
  _NavigationDrawerState createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {
  int _selectedDestination = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final authService = Provider.of<AuthService>(context);

    return Drawer(
        width: 250.0,
        backgroundColor: theme.colorScheme.surface,
        child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: ListTileTheme(
                  selectedColor: theme.colorScheme.primary,
                  selectedTileColor: theme.colorScheme.primary.withOpacity(0.1),
                  child: ListView(
                    // Important: Remove any padding from the ListView.
                    padding: EdgeInsets.zero,
                    shrinkWrap: false,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: SelectableText(
                          widget.title,
                          style: textTheme.headline5
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ListTile(
                        hoverColor: theme.colorScheme.primaryContainer.withOpacity(0.4),
                        title: Text('My Studies', style: _selectedDestination == 0 ? TextStyle(fontWeight: FontWeight.bold) : null),
                        contentPadding: EdgeInsets.only(left: 48.0),
                        selected: _selectedDestination == 0,
                        onTap: () => selectDestination(0),
                      ),
                      ListTile(
                        hoverColor: theme.colorScheme.primaryContainer.withOpacity(0.4),
                        title: Text('Shared With Me', style: _selectedDestination == 1 ? TextStyle(fontWeight: FontWeight.bold) : null),
                        contentPadding: EdgeInsets.only(left: 48.0),
                        selected: _selectedDestination == 1,
                        onTap: () => selectDestination(1),
                      ),
                      Divider(
                        height: 1,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 24.0, bottom: 12.0, left: 32.0),
                        child: SelectableText(
                          'Study Registry',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ListTile(
                        hoverColor: theme.colorScheme.primaryContainer.withOpacity(0.4),
                        title: Text('Open Enrollment', style: _selectedDestination == 3 ? TextStyle(fontWeight: FontWeight.bold) : null),
                        contentPadding: EdgeInsets.only(left: 48.0),
                        selected: _selectedDestination == 3,
                        onTap: () => selectDestination(3),
                      ),
                      ListTile(
                        hoverColor: theme.colorScheme.primaryContainer.withOpacity(0.4),
                        title: Text('Open Results', style: _selectedDestination == 4 ? TextStyle(fontWeight: FontWeight.bold) : null),
                        contentPadding: EdgeInsets.only(left: 48.0),
                        selected: _selectedDestination == 4,
                        onTap: () => selectDestination(4),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 24.0),
                child: Column(children: <Widget>[
                  ListTile(
                    hoverColor: theme.colorScheme.primaryContainer.withOpacity(0.4),
                    title: Text('Change language'),
                    contentPadding: EdgeInsets.only(left: 48.0),
                  ),
                  ListTile(
                    hoverColor: theme.colorScheme.primaryContainer.withOpacity(0.4),
                    title: Text('Sign out'),
                    contentPadding: EdgeInsets.only(left: 48.0),
                    onTap: authService.logout,
                  ),
                ]),
              )
            ]
        )
    );
  }

  void selectDestination(int index) {
    setState(() {
      _selectedDestination = index;
    });
  }
}
