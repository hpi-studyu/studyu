import 'package:flutter/material.dart';

abstract class DashboardTask extends StatefulWidget {
  final String title;
  final String description;
  final Icon icon;

  DashboardTask(this.title, this.description, {@required this.icon});
}
