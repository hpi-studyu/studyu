import 'package:flutter/material.dart';

abstract class DashboardTask extends StatefulWidget {
  final String title;
  final String description;

  DashboardTask(this.title, this.description);
}