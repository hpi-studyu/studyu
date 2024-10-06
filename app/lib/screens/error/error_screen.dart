import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:studyu_app/models/app_error.dart';
import 'package:studyu_app/routes.dart';

class ErrorScreen extends StatelessWidget {
  final AppError error;
  const ErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.error,
              color: Theme.of(context).colorScheme.error,
              size: 100,
            ),
            Text(
              'An error occurred',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              error.message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: Icon(MdiIcons.wrench, size: 25),
              onPressed: () =>
                  Navigator.pushNamed(context, Routes.troubleshooting),
              label: Text(
                "Troubleshoot",
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
