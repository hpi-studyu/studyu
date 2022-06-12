import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_store.dart';
//import '../services/auth_store.dart';

class NavigationDrawer extends ConsumerStatefulWidget {
  final String title;

  const NavigationDrawer({Key? key, required this.title}) : super(key: key);

  @override
  NavigationDrawerState createState() => NavigationDrawerState();
}

class NavigationDrawerState extends ConsumerState<NavigationDrawer> {
  int _selectedDestination = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    //final authService = Provider.of<AuthService>(context);

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
                        hoverColor:
                            theme.colorScheme.primaryContainer.withOpacity(0.4),
                        title: Text('My Studies',
                            style: _selectedDestination == 0
                                ? const TextStyle(fontWeight: FontWeight.bold)
                                : null),
                        contentPadding: const EdgeInsets.only(left: 48.0),
                        selected: _selectedDestination == 0,
                        onTap: () => selectDestination(0),
                      ),
                      ListTile(
                        hoverColor:
                            theme.colorScheme.primaryContainer.withOpacity(0.4),
                        title: Text('Shared With Me',
                            style: _selectedDestination == 1
                                ? const TextStyle(fontWeight: FontWeight.bold)
                                : null),
                        contentPadding: const EdgeInsets.only(left: 48.0),
                        selected: _selectedDestination == 1,
                        onTap: () => selectDestination(1),
                      ),
                      const Divider(
                        height: 1,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(
                            top: 24.0, bottom: 12.0, left: 32.0),
                        child: SelectableText(
                          'Study Registry',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ListTile(
                        hoverColor:
                            theme.colorScheme.primaryContainer.withOpacity(0.4),
                        title: Text('Open Enrollment',
                            style: _selectedDestination == 3
                                ? const TextStyle(fontWeight: FontWeight.bold)
                                : null),
                        contentPadding: const EdgeInsets.only(left: 48.0),
                        selected: _selectedDestination == 3,
                        onTap: () => selectDestination(3),
                      ),
                      ListTile(
                        hoverColor:
                            theme.colorScheme.primaryContainer.withOpacity(0.4),
                        title: Text('Open Results',
                            style: _selectedDestination == 4
                                ? const TextStyle(fontWeight: FontWeight.bold)
                                : null),
                        contentPadding: const EdgeInsets.only(left: 48.0),
                        selected: _selectedDestination == 4,
                        onTap: () => selectDestination(4),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Column(children: <Widget>[
                  ListTile(
                    hoverColor:
                        theme.colorScheme.primaryContainer.withOpacity(0.4),
                    title: const Text('Change language'),
                    contentPadding: const EdgeInsets.only(left: 48.0),
                  ),
                  ListTile(
                    hoverColor:
                        theme.colorScheme.primaryContainer.withOpacity(0.4),
                    title: const Text('Sign out'),
                    contentPadding: const EdgeInsets.only(left: 48.0),
                    onTap: () =>
                        ref.read(authServiceProvider.notifier).signOut(),
                  ),
                ]),
              )
            ]));
  }

  void selectDestination(int index) {
    //setState(() {
    _selectedDestination = index;
    //});
  }
}
