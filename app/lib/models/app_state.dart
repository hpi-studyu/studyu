import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:studyu_core/core.dart';

import '../util/notifications.dart';

class AppState {
  Study selectedStudy;
  List<Intervention> selectedInterventions;
  StudySubject activeSubject;
  String inviteCode;
  List<String> preselectedInterventionIds;
  FlutterLocalNotificationsPlugin _notifications;
  BuildContext context;

  Future<FlutterLocalNotificationsPlugin> get notificationsPlugin async =>
      _notifications ??= (await Notifications.create(activeSubject, context)).flutterLocalNotificationsPlugin;

  AppState(this.context);
}
